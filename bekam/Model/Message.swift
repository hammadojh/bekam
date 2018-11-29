//
//  Message.swift
//  bekam
//
//  Created by Omar on 24/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation
import UIKit

public class Message {
    
    var id:String?
    var senderId:String?
    var timeSent:Double?
    var isNew:Bool?
    var contents = MessageContents()
    
    public func getAllContents() -> [MessageContent] {
        
        return contents.getAll()
        
    }
    
    public func add(string:String){
        contents.string = StringContent(string: string)
    }
    
    public func add(imageURL:String){
        contents.image = ImageContent(url: imageURL)
    }
    
    public func add(location:String){
        contents.location = LocationContent(location: location)
    }
    
    init(text:String){
        
        self.senderId = firUser?.uid
        self.timeSent = Date().timeIntervalSince1970
        
        print("from init \(timeSent)")
        
        self.isNew = true
        self.contents = MessageContents(text: text)
        
    }
    
    func toDict() -> [String:Any] {
        
        let msgDictionary:[String:Any] = [
            
            "messageID":id,
            "messageUser":senderId,
            "messageTime":timeSent,
            "isNew":isNew,
            "messageText": contents.toDict()
        ]
        
        return msgDictionary
        
    }
    
    public func getSummaryText() -> String {
        
        return contents.getSummaryText()
        
    }
    
    init(dict:[String:Any]){
                
        if let id = dict["messageID"] as? String {
            self.id = id
        }
        
        if let senderId = dict["messageUser"] as? String {
            self.senderId = senderId
        }
        
        if let timeSent = dict["messageTime"] as? Double {
            self.timeSent = TimeInterval(timeSent)
        }
        
        if let isNew = dict["isNew"] as? Bool {
            self.isNew = isNew
        }
        
        if let contents = dict["messageText"] as? [String:Any] {
            self.contents = MessageContents(dict: contents)
        }
    }
    
    
    
}
