//
//  HelperFunction.swift
//  bekam
//
//  Created by Omar on 30/09/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

public func CreateTabItem(tabName:String) -> UITabBarItem {
    
    let basename = "tab_icn"
    let activeExtention = "active"
    
    let tabItem = UITabBarItem(title: tabName, image: UIImage(named: "\(basename)_\(tabName)"), selectedImage: UIImage(named:"\(basename)_\(tabName)_\(activeExtention)"))
    
    return tabItem
    
    
}

public func getSizeOfText(text:String,fontSize:Int) -> CGSize { 

    
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height:0))
    label.text = text
    label.font = UIFont.boldSystemFont(ofSize: CGFloat(fontSize))
    label.sizeToFit()
    
    return CGSize(width: label.frame.width, height: label.frame.height)
    
}

public func calculateKeyboardHeight(notification : Notification) -> CGFloat {
    
    if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
        let keyboardRectangle = keyboardFrame.cgRectValue
        let height = keyboardRectangle.height
        return height
    }
    
    return 0
}

public func stringFromTimeInterval(interval: TimeInterval) -> NSString {
    
    let ti = NSInteger(interval)
    
    print(ti)
    
    let minutes = (ti / 60) % 60
    let hours = (ti / 3600) 
    
    return NSString(format: "%0.2d:%0.2d",hours,minutes)
}

public func checkLogin(_ viewController:UIViewController, goBack:Bool = true) -> Bool{
    
    guard firUser != nil else{
        let loginVC = viewController.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        viewController.present(loginVC, animated: true) {
            if goBack {
                viewController.tabBarController!.selectedIndex = 0
            }
        }
        return false
    }
    
    return true
    
}
