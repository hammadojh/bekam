//
//  File.swift
//  bekam
//
//  Created by Omar on 01/10/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation



/// Product Class
/// used to hold products

public class Product {
    
    /// Id of the product
    var id:String?{
        get { return self.id }
        set (newID) { if newID?.isEmpty ?? false {return} }
    }
    /// Id of the user that posted the product
    var userId:String?
    /// name of the product. Might be empty
    var name:String?
    /// price of the product
    var price:Double?
    /// city that the product is located in
    var city:String?
    /// urls for the different images of the product
    var imagesURLS:[String?]?
    /// date product was added
    var addedDate : Date?
    /// weather it is available or not
    var available : Bool?
    /// different categories of the product
    var categories : [String?]?
    /// the description of the product
    var description: String?
    
    /// Default initializer
    
    public init() {
        name = ""
        price = 0
        city = ""
        imagesURLS = []
        addedDate = Date()
        available = true
        categories = []
        description = ""
    }
    
    
    
    /// Copy initializer from another product
    ///
    /// - Parameter from: the other product that you want to copy from
    
    public init(from:Product){
       
        name = from.name
        price = from.price
        city = from.city
        imagesURLS = from.imagesURLS
        addedDate = from.addedDate
        available = from.available
        categories = from.categories
        description = from.name
        userId = from.userId
        id = from.id
        
    }
    
    /// Initializer from a dictionary object. It maps the fields of the dictionary to the properties of the object if they are found
    ///
    /// - Parameter dict: the dictionary that you want to copy from
    
    public init( dict:[String:Any] ){
        
        if let name = dict["name"] as? String {
            self.name = name
        }

        if let description = dict["description"] as? String{
            self.description = description
        }
        
        if let price = dict["price"] as? Double {
            self.price = price

        } else if let price = dict["price"] as? String {
            
            if let parsedPrice = Double(price) {
                self.price = parsedPrice
            }else{
                self.price = 0
            }
            
        }
        
        if let addedDate = dict["addedDate"] as? String {
            setDate(dateString: addedDate)
        }
        
        if let av = ["available"] as? Bool {
            self.available = av
            
        }
        
        if let imgsURLs = dict["imagesURLS"] as? [String] {
            self.imagesURLS = imgsURLs
        }
        
        if let uid = dict["userid"] as? String {
            self.userId = uid
        }
        
        if let id = dict["id"] as? String {
            self.id = id
        }
        
        
    }
    
    /// Sets the date using a string formatted date
    ///
    /// - Parameter dateString: The formatted date string.
    private func setDate(dateString:String){
        self.addedDate = Date.createDateFromString(stringDate: dateString)
    }
    
    

}
