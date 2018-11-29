//
//  ProductDetailsController.swift
//  bekam
//
//  Created by Omar on 01/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

class ProductDetailsController: UIViewController {
    
    //model
    var product:Product?
    
    // ui
    @IBOutlet weak var sellerImageView: UIImageView!
    @IBOutlet weak var priceLabel: PriceLabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var bottomContainerView: UIScrollView!
    
    // action button
    var actionButton:UIButton?
    let buttonPaddingLeft = "           "
    let buttonPaddingRight = "   "
    
    // state
    var state:ProductDetailsStateDelegate?
    
    // temps
    var kbheight:CGFloat?
    var pushAmount:CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        setupInteractions()
        setupObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // pushing the kb
    
    fileprivate func setupObserver(){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector:
            #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)

        
    }
    @objc func keyboardWillShow(_ notification : Notification){
        
        // push content
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                kbheight = keyboardSize.height
                pushAmount = getPushAmount(kbheight:kbheight!)
                self.view.frame.origin.y -= pushAmount!
            }
        }
        
        state?.keyboardWillShow(notification)
    }
    @objc func keyboardWillHide(_ notification : Notification){
        
        // push content
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                kbheight = keyboardSize.height
                self.view.frame.origin.y += pushAmount ?? 0
            }
        }
        
        state?.keyboardWillHide(notification)

    }
    func getPushAmount(kbheight:CGFloat) -> CGFloat{
        
        guard let item = view.firstResponder else {
            return 0
        }
        
        let safeLine = view.frame.maxY - kbheight - 50
        let itemY = item.frame.minY + item.superview!.frame.minY
        
        let offset = itemY - safeLine + item.frame.height + 16
        
        if( offset < 0 ){
            return 0
        }
        
        return offset
        
    }
    
    public func setupData(){
        
        if let product = self.product {
            
            // bg view
            productImageView.image = UIImage(named: "home")
            loadBGImage()
            
            // user img
            sellerImageView.image = UIImage(named: "default")
            loadUserImage()
            
            //price
            priceLabel.text = getPriceLabelString(price:product.price!)
            
            //title
            if !(product.name ?? "").isEmpty{
                productTitle.text = product.name
            }
            state?.setupTitle()
            
            // Description
            if !(product.description ?? "").isEmpty{
                productDescription.text = product.description
            }
            state?.setupDescription()
            
            // city
            self.cityLabel.text = getCity() // TODO:Change later
            
            //  kms
            self.kmLabel.text = getHowFar()
            
        }
        
    }
    
    public func setupUI(){
        
        //navigationController?.isNavigationBarHidden = true
        
        // action button
        actionButton = UIButton(frame: CGRect(x: sellerImageView.frame.minX, y: sellerImageView.frame.minY, width: 0, height: sellerImageView.frame.height))
        actionButton?.backgroundColor = primaryColor
        guard let state = state else {return}
        let actionTitle = NSAttributedString(string: state.getActionButtonTitleString(), attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold),
            NSAttributedString.Key.foregroundColor:UIColor.white])
        actionButton?.setAttributedTitle(actionTitle, for: .normal)
        actionButton?.setImage(UIImage(color: primaryColorDark), for: .highlighted)
        actionButton?.layer.cornerRadius = 20
        actionButton?.widthToFit()
        actionButton?.addTarget(self, action: #selector(actionButtonClicked), for: .touchUpInside)
        view.insertSubview(actionButton!, belowSubview: sellerImageView)
        
        // profile image
        sellerImageView.layer.cornerRadius = sellerImageView.frame.height/2
        sellerImageView.layer.masksToBounds = true
        
        // map view
        mapImageView.layer.cornerRadius = 15
        mapImageView.backgroundColor = greyColor_0
        
        state.setupUI()
    }
    
    @objc func actionButtonClicked(){
        
        print("in clicked")
        
        guard checkLogin(self,goBack: false) else{
            print("no login .. ")
            return
        }
        
        if let state = self.state {
            print("state here")
            state.actionButtonClicked()
        }
        
        
    }
    
    public func letsChatClicked(){
        
        guard checkLogin(self,goBack: false) else{
            print("no login")
            return
        }
        
        print("in chat .. ")
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        secondViewController.chatSession = ChatSession(id: "", ownerId: firUser?.uid ?? "", productId: product?.id ?? "")
        secondViewController.product = product
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.pushViewController(secondViewController, animated: true)
        
    }
    
    public func markAsSoldClicked(){
        
        
        
    }
    
    func setupInteractions(){
        state?.setupInteractions()
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        dismissMe()
    }
    
    func dismissMe(){
        
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name.detailsDismissed, object: self.product)
        }
    }
    
    
    ////////////////////// PRIVATE HELPING FUNCTIONS ////////////////////
    
    
    fileprivate func loadBGImage(){
        
        guard let url = product?.imagesURLS?[0]! else {
            print("no url")
            return
        }
        
        ApiServices.getInstance().loadImage(url: url) { (data, error) in
            
            if(error == nil){
                
                let image = UIImage(data: data!)
                self.productImageView.image = image
                
            }else{
                print(error)
            }
            
        }
        
    }
    
    fileprivate func loadUserImage(){
        
        guard let url = product?.imagesURLS?[0]! else{
            print("no url")
            return
        }
        
        ApiServices.getInstance().loadImage(url: (product?.imagesURLS?[0])!) { (data, error) in
            
            if(error == nil){
                
                let image = UIImage(data: data!)
                self.productImageView.image = image
                
            }else{
                print(error)
            }
            
        }
        
    }
    
    func getPriceLabelString(price:Double) -> String {
        
        if price == 0 {
            return "  😍Free  "
        }else{
            return "$\(Int(price))"
        }
        
    }
    
    func removeDescription(){
        
    }
    
    func removeTitle(){
        
    }
    
    fileprivate func getCity() -> String {
        return "Boulder"
    }
    
    fileprivate func getHowFar() -> String {
        return "15KM away"
    }
    
    
}

