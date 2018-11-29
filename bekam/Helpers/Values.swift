//
//  Values.swift
//  bekam
//
//  Created by Omar on 01/10/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

let tabNames = ["store","notif","img","chat","profile"]
let screensTitles = ["Things","Alerts","","Chat","Profile"]
let primaryColor = UIColor(red: 128/255, green: 81/255, blue: 168/255, alpha: 1.0)
let primaryColorDark = UIColor(red: 95/255, green: 55/255, blue: 129/255, alpha: 1.0)
let primaryColorTrans = UIColor(red: 46/255, green: 26/255, blue: 63/255, alpha: 0.7)
let primaryColorHalfAlpha = UIColor(red: 128/255, green: 81/255, blue: 168/255, alpha: 0.5)
let greyColor_0 = UIColor(red: 212/255, green: 205/255, blue: 216/255, alpha: 1.0)
let greyColor_5 = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
let primaryBlack = UIColor(red: 37/255, green: 12/255, blue: 59/255, alpha: 1.0)
let bodyTextColor = UIColor(red: 129/255, green: 122/255, blue: 135/255, alpha: 1.0)
let DATE_FORMAT = "dd/MM/yyyy HH:mm:ss"
let IMG_NAME_DATE_FORMAT = "dd_MM_yyyy_HH_mm_ss"
let INNER_PADDING = "   "
let EMAIL_KEY = "EMAIL"
let PASS_KEY = "PASS"

struct Const {
    
    /// Image height/width for Large NavBar state
    static let ImageSizeForLargeState: CGFloat = 36
    
    /// Margin from right anchor of safe area to right anchor of Image
    static let ImageRightMargin: CGFloat = 16
    
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Large NavBar state
    static let ImageBottomMarginForLargeState: CGFloat = 12
    
    /// Margin from bottom anchor of NavBar to bottom anchor of Image for Small NavBar state
    static let ImageBottomMarginForSmallState: CGFloat = 6
    
    /// Image height/width for Small NavBar state
    static let ImageSizeForSmallState: CGFloat = 24
    
    /// Height of NavBar for Small state. Usually it's just 44
    static let NavBarHeightSmallState: CGFloat = 44
    
    /// Height of NavBar for Large state. Usually it's just 96.5 but if you have a custom font for the title, please make sure to edit this value since it changes the height for Large state of NavBar
    static let NavBarHeightLargeState: CGFloat = 96.5
}


