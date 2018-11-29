//
//  File.swift
//  bekam
//
//  Created by Omar on 01/10/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation

public class Product {
    
    var name:String?
    var imageName:String?
    var price:Double?
    var city:String?
    var imagesURLS:[String?]?
    var addedDate : Date?
    var available : Bool?
    var categories : [String?]?
    var description: String?
    var userId:String?
    var id:String?
    
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
    
    private func calculateDistance() -> Double {
        //TODO: Complete
        return 10
    }
    
    private func getImagesURLs() -> [String]{
        //TODO: Complete
        return ["kalifa"]
    }
    
    private func setDate(dateString:String){
        self.addedDate = Date.createDateFromString(stringDate: dateString)
    }
    
    

}
