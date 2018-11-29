//
//  ProductCellCollectionViewCell.swift
//  bekam
//
//  Created by Omar on 01/10/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    // ui
    @IBOutlet var image:UIImageView!
    @IBOutlet var chatButton:UIButton!
    @IBOutlet var priceLabel:PriceLabel!
    
    //observers
    var observer:ProductCellObserver?
    
    //model
    var product:Product! {
        didSet{
            setupImage()
            setupPriceLabel()
            setupChatButton()
        }
    }
    
    @IBAction func chatClicked(_ sender: Any) {
        
        print("start sesion .. ")
        observer?.notfiy(product: product!)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }
    
    fileprivate func setupChatButton(){
        
        guard let ownerId = product.userId else {
            return;
        }
        
        guard let buyerId = firUser?.uid else {
            return;
        }

        if ownerId == buyerId {
            chatButton.isHidden = true
        }else{
            chatButton.isHidden = false
        }
        
        self.bringSubviewToFront(chatButton)
        
    }
    
    fileprivate func setupPriceLabel() {
        
        // price label
        let price = product.price != nil ? product.price : 0
        let labelFactory = PriceLabelFactory.getInstance()
        let label = labelFactory.getLabel(priceLabel:priceLabel, price:price!, rent: false);
        priceLabel.copy(priceLabel: label)
    }
    
    fileprivate func setupImage(){
        
        // placeholder
        image.image = UIImage(named: "home")
        
        //download
        loadImage()
    }
    
    fileprivate func loadImage(){
        
        // to make it white :)
        self.image.image = nil
        
        if let urls = product.imagesURLS {
            
            if let url = urls[0] {
                
                ApiServices.getInstance().loadImage(url: url) { (data, error) in
                    
                    if error != nil {
                        print(error)
                    } else {
                        
                        DispatchQueue.main.async {
                            let imageData = UIImage(data: data!)
                            self.image.image = imageData
                        }
                        
                    }
                }
            }
        }
    }
    
}
