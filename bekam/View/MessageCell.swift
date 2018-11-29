//
//  SenderMessageCell.swift
//  bekam
//
//  Created by Omar on 26/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell{
    
    // constants
    let TIME_FORMAT = "hh:mm a"
    
    var message:Message?{
        didSet{messageDidSet()}
    }
    
    var user:AppUser?{
        didSet{userDidSet()}
    }
    
    func messageDidSet(){}
    func userDidSet(){}

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    enum Side {
        case right
        case left
    }

    
    func setupMessageLabel(label:UILabel){
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
    }
    
    func setMessageText(messageLabel:UILabel){
        let messageText = message?.getSummaryText()
        messageLabel.text = messageText!
    }
    
    func setupImageView(imageView:UIImageView){
        imageView.layer.cornerRadius = 16
        imageView.layer.masksToBounds = true
    }
    
    func setProfileImage(imageView:UIImageView){
        
        imageView.image = user!.getImage()
        
    }

    
    func setTime(timeLabel:UILabel){
        
        let timeInSeconds = TimeInterval(message?.timeSent! ?? 0)
        let timeString = Date.getString(interval: timeInSeconds, format: TIME_FORMAT)
        timeLabel.text = timeString as String
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: false)
    }
    

}

class SenderMessageCell: MessageCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func messageDidSet(){
        setMessageText(messageLabel: messageLabel)
        setTime(timeLabel: timeLabel)
    }
    
    override func userDidSet() {
        setProfileImage(imageView: profileImageView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView(imageView: profileImageView)
        setupMessageLabel(label: messageLabel)
        messageLabel.backgroundColor = primaryColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setupMessageLabel(label: UILabel) {
        super.setupMessageLabel(label: label)
        label.layer.maskedCorners = [ .layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }

    
}

class ReciverMessageCell: MessageCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func messageDidSet(){
        setMessageText(messageLabel: messageLabel)
        setTime(timeLabel: timeLabel)
    }
    
    override func userDidSet() {
        setProfileImage(imageView: profileImageView)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupImageView(imageView: profileImageView)
        setupMessageLabel(label: messageLabel)
        messageLabel.layer.borderWidth = 0.2
        messageLabel.layer.borderColor = primaryColorHalfAlpha.cgColor
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func setupMessageLabel(label: UILabel) {
        super.setupMessageLabel(label: label)
        label.layer.maskedCorners = [ .layerMinXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
    }
    
    
    
}
