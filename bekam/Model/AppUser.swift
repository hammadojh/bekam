//
//  User.swift
//  bekam
//
//  Created by Omar on 24/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation
import UIKit

/// App User Class. Used to hold the current loged in user.
public class AppUser {
    
    /// id of the user
    var id:String? {
        get { return self.id }
        set (newID) { if newID?.isEmpty ?? false {return} }
    }
    /// name of the user
    var name:String?
    /// email of the usre
    var email:String?
    /// mobile of the user
    var mobile:String?
    /// city of the user
    var city:String?
    /// profile image url of the user
    var profileImageURL:String?
    
    /// initializer by an id
    ///
    /// - Parameter id: the id of the user
    init(id:String){
        self.id = id
        self.profileImageURL = "\(Int.random(in: 1 ..< 7 ))" //default images number
    }
    
    /// Initializer from a dictionary object. It maps the fields of the dictionary to the properties of the object if they are found
    ///
    /// - Parameter dict: the dictionary that you want to copy from
    public init(dict:[String:Any]){
        
        if let id = dict["id"] as? String {
            self.id = id
        }
        
        if let name = dict["name"] as? String {
            self.name = name
        }
        
        if let email = dict["email"] as? String {
            self.email = email
        }
        
        if let mobile = dict["mobile"] as? String {
            self.mobile = mobile
        }
        
        if let city = dict["city"] as? String {
            self.city = city
        }
        
        if let imgURL = dict["profileImageURL"] as? String {
            self.profileImageURL = imgURL
        }
        
    }
    
    /// Creates a dictionary from the current object
    ///
    /// - Returns: a dictionary mapping the current fields and the name of the keys and the same as the variable names
    
    public func toDict() -> [String:Any] {
        
        var dict = [String:Any]()
        dict["name"] = self.name ?? ""
        dict["email"] = self.city ?? ""
        dict["mobile"] = self.mobile ?? ""
        dict["city"] = self.city ?? ""
        dict["profileImageURL"] = self.profileImageURL ?? Int.random(in: 1 ..< 7 )
        
        return dict
    }
    
    /// returns the profile image of the user.
    ///
    /// - Returns: the profile image of the user
    
    public func getImage() -> UIImage{
        
        // else check if there is a url
        
        guard let url = profileImageURL else {
            return UIImage()
        }
        
        // check if the url size is > 1
        
        guard url.count > 1 else {
            return UIImage(named: "default_user_img_\(url)")!
        }
        
        // load the full url
        
        return UIImage()
        
    }

    
}
