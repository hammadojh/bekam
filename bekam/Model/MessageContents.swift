//
//  MessageContents.swift
//  bekam
//
//  Created by Omar on 25/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation

public class MessageContents {
    
    var string:StringContent?
    var image:ImageContent?
    var location:LocationContent?
    
    init(){
    }
    
    init(text:String){
        self.string = StringContent(string:text)
    }
    
    init( dict:[String:Any] ){
                
        if let stringContent = dict["string"] as? String {
            self.string = StringContent(string:stringContent)
        }
        
        if let imgContent = dict["imgURL"] as? String {
            self.image = ImageContent(url:imgContent)
        }
        
        if let locationContent = dict["location"] as? String {
            self.location = LocationContent(location:locationContent)
        }
        
    }
    
    public func toDict() -> [String:Any] {
        
        var dict = [String:Any]()
        
        if let string = self.string {
            dict.merge(dict: string.toDict())
        }
        
        if let image = self.image {
            dict.merge(dict: image.toDict())
        }
        
        if let location = self.location {
            dict.merge(dict: location.toDict())
        }
        
        return dict

    }
    
    public func getSummaryText() -> String {
        
        if hasStringContent() {
            return string!.getTextSummary()
        }else if hasImageContent() {
            return image!.getTextSummary()
        }else if hasLocationContent() {
            return location!.getTextSummary()
        }else{
            return ""
        }
        
    }
    
    public func hasStringContent() -> Bool {
        return string != nil
    }
    
    public func hasImageContent() -> Bool {
        return image != nil
    }
    
    public func hasLocationContent() -> Bool {
        return location != nil
    }
    
    public func getAll() -> [MessageContent] {
        
        var contents = [MessageContent]()
        
        if hasStringContent(){
            contents.append(string! )
        }
        
        if hasLocationContent() {
            contents.append(location!)
        }
        
        if hasImageContent() {
            contents.append(image!)
        }
        
        return contents
        
    }
    
    
    
}

