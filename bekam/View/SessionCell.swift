//
//  ChatListCell.swift
//  bekam
//
//  Created by Omar on 24/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit
import Firebase

class SessionCell: UITableViewCell {
    
    //ui
    @IBOutlet weak var numOfNewMessagesLabel: UILabel!
    @IBOutlet weak var reciverImageView: UIImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var reciverNameLabel: UILabel!
    
    //model
    var otherUser:AppUser?
    var product:Product?
    var session:ChatSession! {
        didSet{
            setupNumLabel()
            setupLastMessage()
            getProduct()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // profile image
        reciverImageView.layer.cornerRadius = reciverImageView.frame.height/2
        reciverImageView.layer.masksToBounds = true
        
        // reviver name label
        reciverNameLabel.textColor = primaryBlack
        
        // last message
        lastMessageLabel.textColor = bodyTextColor
        
        //numbers
        numOfNewMessagesLabel.layer.cornerRadius = numOfNewMessagesLabel.frame.height/2
        
    }
    
    private func setupLastMessage(){
        
        // if the message is stored locally
        
        guard (session.getLastMessage() ?? "").isEmpty else {
            lastMessageLabel.text = session.getLastMessage()
            print("there is a last message ")
            return
        }
        
        // make sure there is a session id
        
        guard let sessionId = self.session?.id else {
            print("No session id")
            return
        }
        
        // if not locally get it from the server
 
        ApiServices.getInstance().getLastMessage(sessionId: sessionId) { (snap, err) in
            
            if err != nil {
                print("no message \(snap)")
                return
            }
            
            DispatchQueue.main.async {
                
                for aSnap in snap!.children {
                    
                    guard let msgSnap = aSnap as? DataSnapshot else { return }
                    guard let msgDict = msgSnap.value as? [String:Any] else { return }
                    
                    let msg = Message(dict: msgDict)
                    self.lastMessageLabel!.text = msg.getSummaryText()
                                    
                }
                
                
            }
            
        }
        
        
        
    }
    
    private func setupNumLabel(){
        
        let num = session.getNumOfNewMessages()

        if(num == 0){
            numOfNewMessagesLabel.isHidden = true
            return
        }

        numOfNewMessagesLabel.text = "\(num)"
        
    }
    
    private func getProduct(){
        
        guard let productId = session.productId else {
            reciverNameLabel.text = "No product Id"
            return;
        }
        
        ApiServices.getInstance().loadProduct(productId: productId) { (snapshot, error) in
            
            guard error == nil else {
                self.reciverNameLabel.text = "product not found"
                return;
            }
            
            let product = Product(dict: snapshot!.value as! [String:Any])
            
            self.product = product
            
            if let productName = product.name {
                self.reciverNameLabel.text = productName
            }else{
                self.reciverNameLabel.text = "Unnamed Product"
            }
            
            self.getOtherUser()
            
        }
        
    }
    
    private func getOtherUser(){
        
        let sellerId = product?.userId
        let buyerId = session.buyerId
        
        var getUserId = ""
        
        if firUser?.uid == buyerId {
            getUserId = sellerId!
        } else {
            getUserId = buyerId!
        }
        
        ApiServices.getInstance().getUser(id: getUserId) { (snapshot, error) in
            
            guard error == nil else {
                return;
            }
            
            guard let user = snapshot?.value as? [String:Any] else {
                return;
            }
            
            self.otherUser = AppUser(dict:user)
            
            // set name and get image
            self.setupProfileImage()
        }
    
    }
    
    private func setupProfileImage(){
        
        // check if there is a url
        
        guard let url = self.otherUser?.profileImageURL else {
            return
        }
        
        // check if the url size is > 1
        
        guard url.count > 1 else {
            if let number = self.otherUser?.profileImageURL {
                reciverImageView.image = UIImage(named: "default_user_img_\(number)")
            }
            return
        }
        
        // url exist get image
        
        ApiServices.getInstance().loadImage(url: url) { (data, error) in
            
            guard error == nil else {
                return
            }
            
            let image = UIImage(data: data!)
            self.reciverImageView.image = image
            
        }
        
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
        // Configure the view for the selected state
    }

}
