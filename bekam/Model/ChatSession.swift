//
//  ChatSession.swift
//  bekam
//
//  Created by Omar on 24/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation

/// Chat Session Class. Used to hold the chat sessions between two users.
public class ChatSession {
    
    /// The id of the session
    var id:String?{
        get { return self.id }
        set (newID) { if newID?.isEmpty ?? false {return} }
    }
    /// The buyer id
    var buyerId:String?
    /// The product id that is related to the session
    var productId:String?
    /// List of messages in this session
    var messages = [Message]()
    
    /// Copy initializer from another session
    ///
    /// - Parameter from: the other session that you want to copy from
    
    init(dict:[String:Any]){
        
        if let id = dict["sessionId"] as? String {
            self.id = id
        }
        
        if let buyerId = dict["buyerId"] as? String {
            self.buyerId = buyerId
        }
        
        if let productId = dict["productId"] as? String {
            self.productId = productId
        }
        
    }
    
    /// Creates a dictionary from the current object
    ///
    /// - Returns: a dictionary mapping the current fields and the name of the keys and the same as the variable names
    
    public func toDict() -> [String:Any] {
        
        let sessionDict = [
            "buyerId" : self.buyerId,
            "productId" : self.productId
        ]
        
        return sessionDict
        
    }
    
    /// Initializer by the id, owner id and product id
    ///
    /// - Parameters:
    ///   - id: id of the product
    ///   - ownerId: user id that owns the session
    ///   - productId: product id that is related to the session
    init(id:String, ownerId:String, productId:String){
        self.id = id
        self.buyerId = ownerId
        self.productId = productId
    }

    
    /// Adds a message to the session
    ///
    /// - Parameter msg: The message to add
    public func addMessage(msg:Message){
        messages.append(msg)
    }
    
    /// if the session has messages
    ///
    /// - Returns: a boolen value to indicate weather the session has messages or not
    public func hasMessages() -> Bool {
        
        if messages.count == 0 {
            return false
        }
        
        return true
        
    }
    
    /// gets the number of new messages
    ///
    /// - Returns: number of new messages
    public func getNumOfNewMessages() -> Int {
        
        var new = 0
        
        for msg in messages {
            
            if let isNew = msg.isNew {
                
                if isNew { new += 1 }
                
            }
            
        }
        
        return new
        
    }
    
    /// Returns the last message added to the chat
    ///
    /// - Returns: last message added to the chat
    public func getLastMessage() -> String {
        
        guard messages.count > 0 else {
            return ""
        }
        
        return messages[messages.count-1].getSummaryText()
        
    }
    
}
