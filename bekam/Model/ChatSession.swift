//
//  ChatSession.swift
//  bekam
//
//  Created by Omar on 24/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation

public class ChatSession {
    
    var id:String?
    var buyerId:String?
    var productId:String?
    var messages = [Message]()
    
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
    
    public func toDict() -> [String:Any] {
        
        let sessionDict = [
            "buyerId" : self.buyerId,
            "productId" : self.productId
        ]
        
        return sessionDict
        
    }
    
    init(id:String, ownerId:String, productId:String){
        self.id = id
        self.buyerId = ownerId
        self.productId = productId
    }
    
    init(){
        self.id = UUID().uuidString
        self.buyerId = firUser?.uid
    }
    
    public func addMessage(msg:Message){
        messages.append(msg)
    }
    
    public func hasMessages() -> Bool {
        
        if messages.count == 0 {
            return false
        }
        
        return true
        
    }
    
    public func getNumOfNewMessages() -> Int {
        
        var new = 0
        
        for msg in messages {
            
            if let isNew = msg.isNew {
                
                if isNew { new += 1 }
                
            }
            
        }
        
        return new
        
    }
    
    public func getLastMessage() -> String {
        
        guard messages.count > 0 else {
            return ""
        }
        
        return messages[messages.count-1].getSummaryText()
        
    }
    
}
