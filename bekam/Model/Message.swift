//
//  Message.swift
//  bekam
//
//  Created by Omar on 24/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation
import UIKit

/// Message Class. Used to hold a user message.
public class Message {
    
    /// ID of the message
    var id:String?{
        get { return self.id }
        set (newID) { if newID?.isEmpty ?? false {return} }
    }
    /// ID of the sender user
    var senderId:String?
    /// timestamp of the time the message was sent
    var timeSent:Double?
    /// weather the message is new of read
    var isNew:Bool?
    /// contents of the message.
    /// - SeeAlso: MessageContent
    private var contents = MessageContents()
    
    /// Returns all the contents of the message
    ///
    /// - Returns: All the message contents
    public func getAllContents() -> [MessageContent] {
        
        return contents.getAll()
        
    }
    
    /// Adds a string to the message content
    ///
    /// - Parameter string: The string to add
    public func add(string:String){
        contents.string = StringContent(string: string)
    }
    
    /// Adds an image to the content
    ///
    /// - Parameter imageURL: the image url to add
    public func add(imageURL:String){
        contents.image = ImageContent(url: imageURL)
    }
    
    /// adds a location to the content
    ///
    /// - Parameter location: the location to add
    public func add(location:String){
        contents.location = LocationContent(location: location)
    }
    
    /// initializer with text
    ///
    /// - Parameter text: the text to initialize the message with
    init(text:String){
        
        self.senderId = firUser?.uid
        self.timeSent = Date().timeIntervalSince1970
        
        print("from init \(timeSent)")
        
        self.isNew = true
        self.contents = MessageContents(text: text)
        
    }
    
    /// Creates a dictionary from the current object
    ///
    /// - Returns: a dictionary mapping the current fields and the name of the keys and the same as the variable names
    
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
    
    /// Returns the text of the content. this method is used in normal cases to get the message text
    ///
    /// - Returns: the text of the message
    public func getSummaryText() -> String {
        
        return contents.getSummaryText()
        
    }
    
    /// Initializer from a dictionary object. It maps the fields of the dictionary to the properties of the object if they are found
    ///
    /// - Parameter dict: the dictionary that you want to copy from
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
