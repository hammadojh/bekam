//
//  User.swift
//  bekam
//
//  Created by Omar on 24/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation
import UIKit

public class AppUser {
    
    var id:String?
    var name:String?
    var email:String?
    var mobile:String?
    var city:String?
    var profileImageURL:String?
    
    init(id:String){
        self.id = id
        self.profileImageURL = "\(Int.random(in: 1 ..< 7 ))" //default images number
    }
    
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
    
    public func toDict() -> [String:Any] {
        
        var dict = [String:Any]()
        dict["name"] = self.name ?? ""
        dict["email"] = self.city ?? ""
        dict["mobile"] = self.mobile ?? ""
        dict["city"] = self.city ?? ""
        dict["profileImageURL"] = self.profileImageURL ?? Int.random(in: 1 ..< 7 )
        
        return dict
    }
    
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
