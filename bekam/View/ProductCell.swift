//
//  ProductCellCollectionViewCell.swift
//  bekam
//
//  Created by Omar on 01/10/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

class ProductCell: UICollectionViewCell {
    
    //observers
    var observer:ProductCellObserver?
    
    // ui
    @IBOutlet var image:UIImageView!
    @IBOutlet var chatButton:UIButton!
    @IBOutlet var priceLabel:PriceLabel!
    
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

/////////////////////// HELPING CLASSES /////////////////////////


class PriceLabelFactory {
    
    // get label
    
    public func getLabel(priceLabel:PriceLabel,price:Double,rent:Bool) -> PriceLabel {
        
        if price == 0 {
            return FreePriceLabel(frame:priceLabel.frame,price:price)
        }else if(rent){
            return RentPriceLabel(frame:priceLabel.frame,price:price)
        }else{
            return NormalPriceLabel(frame:priceLabel.frame,price:price)
        }
        
    }
    
    private static var instance:PriceLabelFactory?
    private init(){}
    
    // Get instance
    
    static func getInstance() -> PriceLabelFactory {
        
        if let inst = instance {
            return inst
        }else{
            instance = PriceLabelFactory()
            return instance!
        }
    }
    
    
    
}

// Super price label

class PriceLabel:UILabel {
    
    private var price:Double?
    
    init(frame: CGRect, price:Double) {
        super.init(frame: frame)
        self.price = price
        setText(text: "$\(Int(getPrice()))")
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setupLabel()
    }
    
    
    func setupLabel(){
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    func copy(priceLabel:PriceLabel){
        setText(text: priceLabel.text!)
        self.backgroundColor = priceLabel.backgroundColor
        self.textColor = priceLabel.textColor
    }
    
    func setText(text:String){
        self.text = " \(text) "
    }
    
    func getPrice() -> Double {
        return price!
    }
    
}


// FREE PRICE LABEL

class FreePriceLabel:PriceLabel {
    
    static let LABEL_TEXT = "😍 Free"
    static let LABEL_COLOR = UIColor.red
    
    override func setupLabel(){
        super.setupLabel()
        setText(text: FreePriceLabel.LABEL_TEXT)
        self.backgroundColor = FreePriceLabel.LABEL_COLOR
        self.textColor = UIColor.white
    }
    
    override func setText(text: String) {
        super.setText(text: FreePriceLabel.LABEL_TEXT)
    }
    
}

class NormalPriceLabel:PriceLabel {
    
    override func setupLabel(){
        super.setupLabel()
        self.backgroundColor = UIColor.white
        self.textColor = UIColor.black
    }
    
    override func setText(text: String) {
        //
    }
}

class RentPriceLabel:PriceLabel {
    
    override func setupLabel(){
        super.setupLabel()
        self.backgroundColor = UIColor.purple
        self.textColor = UIColor.white
    }
    
    override func setText(text: String) {
        //  
    }
}

