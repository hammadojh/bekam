//
//  MessageContent.swift
//  bekam
//
//  Created by Omar on 25/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation
import UIKit

/// Message Content protocol. Any Message content type should conform to this protocol. String, Img, Location, URL .. etc
public protocol MessageContent {
    func getTextSummary() -> String
    func toDict() -> [String:Any]
}

/// String Contenet class. Used to hold the string content of a message.
class StringContent:MessageContent {
    
    /// The string content
    var string:String?
    
    /// initialize it with a string
    ///
    /// - Parameter string: the text to initialize the object with
    init(string:String){
        self.string = string
    }
    
    /// returns the text of the string
    ///
    /// - Returns: the string value
    func getTextSummary() -> String {
        return string ?? ""
    }
    
    /// Creates a dictionary from the current object
    ///
    /// - Returns: a dictionary mapping the current fields and the name of the keys and the same as the variable names
    func toDict() -> [String : Any] {
        return ["string":string]
    }
}

/// Image Content Class. used to hold the images of the messages
class ImageContent:MessageContent {
    
    /// the image
    var image:UIImage?
    /// the image url
    var imgURL:String?
    
    /// initialize from a url
    ///
    /// - Parameter url: the url of the image
    init(url:String){
        self.imgURL = url
    }
    
    /// returns a description of the image
    ///
    /// - Returns: the image description
    func getTextSummary() -> String {
        return image.debugDescription
    }
    
    /// Creates a dictionary from the current object
    ///
    /// - Returns: a dictionary mapping the current fields and the name of the keys and the same as the variable names
    func toDict() -> [String : Any] {
        return ["imgURL":imgURL]
    }
}

/// Location Content Class. Used to the hold the location content of the message.
class LocationContent:MessageContent {
    
    /// the location
    var location:String?
    
    /// initialie using a location string
    ///
    /// - Parameter location: the location string in this format "lat,long"
    init(location:String){
        self.location = location
    }
    
    /// returns a summay text of the location in
    ///
    /// - Returns: the location in this format "lat,long"
    func getTextSummary() -> String {
        return location!
    }
    
    /// Creates a dictionary from the current object
    ///
    /// - Returns: a dictionary mapping the current fields and the name of the keys and the same as the variable names
    func toDict() -> [String : Any] {
        return ["location":location]
    }
}

/// Messsage contents class. used to hold the contents of a message.
public class MessageContents {
    
    /// the string content
    var string:StringContent?
    /// the image content
    var image:ImageContent?
    /// the location content
    var location:LocationContent?
    
    /// empty initializer
    init(){}
    
    /// initializer using a text
    ///
    /// - Parameter text: the text to init the contents
    init(text:String){
        self.string = StringContent(string:text)
    }
    
    /// Initializer from a dictionary object. It maps the fields of the dictionary to the properties of the object if they are found
    ///
    /// - Parameter dict: the dictionary that you want to copy from
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
    
    /// Creates a dictionary from the current object
    ///
    /// - Returns: a dictionary mapping the current fields and the name of the keys and the same as the variable names
    
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
    
    /// Returns a summary text of all the contents of the message
    ///
    /// - Returns: a string of all the contents
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
    
    /// has a string content or not
    ///
    /// - Returns: a boolean of waether it has a string content or not
    public func hasStringContent() -> Bool {
        return string != nil
    }
    
    /// has a image content or not
    ///
    /// - Returns: a boolean of waether it has a image content or not
    public func hasImageContent() -> Bool {
        return image != nil
    }
    
    /// has a location content or not
    ///
    /// - Returns: a boolean of waether it has a location content or not
    public func hasLocationContent() -> Bool {
        return location != nil
    }
    
    /// Returns an array of all the available contents
    ///
    /// - Returns: an array of all the contents
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

