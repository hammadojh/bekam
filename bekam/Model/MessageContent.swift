//
//  MessageContent.swift
//  bekam
//
//  Created by Omar on 25/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation
import UIKit

public protocol MessageContent {
    func getValue() -> Any
    func getTextSummary() -> String
    func toDict() -> [String:Any]
}

class StringContent:MessageContent {
    
    var string:String?
    
    init(string:String){
        self.string = string
    }
    
    func getValue() -> Any{
        return string
    }
    
    func getTextSummary() -> String {
        return getValue() as! String
    }
    
    func toDict() -> [String : Any] {
        return ["string":string]
    }
}

class ImageContent:MessageContent {
    
    var image:UIImage?
    var imgURL:String?
    
    init(url:String){
        self.imgURL = url
    }
    
    func getValue() -> Any{
        return image
    }
    
    func getTextSummary() -> String {
        return image.debugDescription
    }
    
    func toDict() -> [String : Any] {
        return ["imgURL":imgURL]
    }
}

class LocationContent:MessageContent {
    
    var location:String?
    
    init(location:String){
        self.location = location
    }
    
    func getValue() -> Any{
        return location
    }
    
    func getTextSummary() -> String {
        return location!
    }
    
    func toDict() -> [String : Any] {
        return ["location":location]
    }
}
