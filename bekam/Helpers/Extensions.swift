//
//  Extensions.swift
//  bekam
//
//  Created by Omar on 01/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    
    func numberOfDays(fromDate:Date , toDate:Date) -> Int{
        
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day], from: fromDate, to: toDate)
        
        return components.day!
    }
    
    static func createDateFromString(stringDate:String) -> Date{
        let fm = DateFormatter()
        if let date = fm.date(from: stringDate){
            return date
        }
        return Date()
    }
    
    func getString(formatString:String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        let dateString = formatter.string(from: self)
        return dateString
        
    }
    
    static func getString(interval:TimeInterval, format:String)->String{
        
        let date = Date(timeIntervalSince1970: interval)
        let formatter = DateFormatter()
        formatter.dateFormat = format // "a" prints "pm" or "am"
        let hourString = formatter.string(from: date) // "12 AM"
        return hourString
        
    }
}


extension UIImage {
    
    func getImageSize() -> Double{
    
        let imgData: NSData = NSData(data: self.pngData()!)
        let imageSize: Int = imgData.length
        
        return Double(imageSize) / 1024.0
        
    }
    
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        return result
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        return result
    }
    
    func resizeToBeLessThan(maxSizeInKB:Double) -> UIImage{
        
        let currentSize = self.getImageSize()
        let reduceAmount = 1.0 / ( currentSize / maxSizeInKB )
        
        return self.resizeWithPercent(percentage: CGFloat(reduceAmount))!
        
    }
}

extension UIView {
    
    func setX(value:CGFloat){
        self.frame = CGRect(x: value, y: frame.minY, width: frame.width, height: frame.height)
    }
    
    func setY(value:CGFloat){
        self.frame = CGRect(x: frame.minX, y: value, width: frame.width, height: frame.height)
    }
    
    func setWidth(value:CGFloat){
        self.frame.size = CGSize(width: value, height: frame.height)
    }
    
    func setHeight(value:CGFloat){
        self.frame.size = CGSize(width: frame.width, height: value)
    }
    
    func widthToFit(){
        let oldSize = frame.size
        sizeToFit()
        setHeight(value: oldSize.height)
    }
    
    func heightToFit(){
        let oldSize = frame.size
        sizeToFit()
        setWidth(value: oldSize.width)
    }
    
    var firstResponder: UIView? {
        guard !isFirstResponder else { return self }

        for subview in subviews {
            if let firstResponder = subview.firstResponder {
                return firstResponder
            }
        }
        
        return nil
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    
}

public extension UIImage {
    
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        
        self.init(cgImage: cgImage)
    }
}

extension Notification.Name {
    
    static let detailsDismissed = Notification.Name("detailsDismissed")
    static let captureDismissed = Notification.Name("captureDismissed")
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension UILabel {
    var optimalHeight : CGFloat {
        get
        {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            label.numberOfLines = 0
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.font = self.font
            label.text = self.text
            label.sizeToFit()
            return label.frame.height
        }
        
    }
}
