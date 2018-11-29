//
//  PriceLabelFactory.swift
//  bekam
//
//  Created by Omar on 01/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

class PriceLabelFactory {
    
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
}

class RentPriceLabel:PriceLabel {
    
    override func setupLabel(){
        super.setupLabel()
        self.backgroundColor = UIColor.purple
        self.textColor = UIColor.white
    }
}
