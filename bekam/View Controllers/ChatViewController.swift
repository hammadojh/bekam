//
//   Do any additional setup after loading the view.swift
//  bekam
//
//  Created by Omar on 25/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    // model
    var chatSession:ChatSession? // if from products id is null .. if from chats id is known
    var product:Product? // always here !!
    var otherUser:AppUser?
    
    //ui
    var activity:UIActivityIndicatorView?
    var profileImageView:UIImageView!
    var profileImage:UIImage?
    var emptyLabel:UILabel?
    var kbView:UIView?
    
    //outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var addAttachmentBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ui
        navigationController?.isNavigationBarHidden = true
        addBackButton()
        setupResizableImageTitle()
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = product?.name ?? "Untitled Product"
        
        // data
        loadSeller() // then loadSessions() then loadChat()
        tableView.isHidden = true
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64.0
        
        //setup keyboard
        setupKeyboard()
        
        // reset model
        if (chatSession?.hasMessages() ?? false) {
            chatSession?.messages = [Message]()
        }
        
    }
    
    func setupKeyboard(){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        textField.delegate = self
        tableView.keyboardDismissMode = .onDrag
        self.hideKeyboard()
    }
    
    @IBAction func sendPressed(_ sender: Any) {
        
        sendMessage(message:textField.text)
        textField.resignFirstResponder()
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendPressed(textField)
        return true
    }
    
    func sendMessage(message:String?){
    
        guard !((message ?? "").isEmpty) else {
            return
        }
        
        let newMessage = Message(text: message!)
        ApiServices.getInstance().sendMessage(message: newMessage, sessionId: chatSession!.id!) { (ref, err) in
            
            if err != nil {
                // error
                print("not sent")
                return
            }
            
            
            
        }
        
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        
        print("KB WILL SHOW")
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            let height = keyboardRectangle.height
            
            guard kbView == nil else{
                return
            }
            
            kbView = UIView(frame: CGRect(x: 0, y: view.frame.maxY - height, width: view.frame.width, height: height))
            
            UIView.animate(withDuration: 0.5) {
                self.view.addSubview(self.kbView!)
                self.view.addConstraint(NSLayoutConstraint(item: self.bottomView, attribute: .bottom, relatedBy: .equal, toItem: self.kbView, attribute: .top, multiplier: 1, constant: 0))
                self.view.layoutIfNeeded()
                
            }
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification){
        
        print("KB WILL HIDE")

        UIView.animate(withDuration: 0.5, animations: {
            self.kbView?.setY(value: self.view.frame.maxY)
            self.view.layoutIfNeeded()
        }) { (bool) in
            self.kbView?.removeFromSuperview()
            self.kbView = nil
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        profileImageView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        profileImageView.isHidden = false
    }
    
    func setupResizableImageTitle(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // image view
        profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        profileImageView.image = profileImage
        profileImageView.layer.cornerRadius = 18
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        // Initial setup for image for Large NavBar state since the the screen always has Large NavBar once it gets opened
        guard let navigationBar = self.navigationController?.navigationBar else { return }
        
        navigationBar.addSubview(profileImageView)
        profileImageView.layer.cornerRadius = Const.ImageSizeForLargeState / 2
        profileImageView.clipsToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            profileImageView.rightAnchor.constraint(equalTo: navigationBar.rightAnchor, constant: -Const.ImageRightMargin),
            profileImageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -Const.ImageBottomMarginForLargeState),
            profileImageView.heightAnchor.constraint(equalToConstant: Const.ImageSizeForLargeState),
            profileImageView.widthAnchor.constraint(equalTo: profileImageView.heightAnchor)
        ])
    }
    
    func addProfileImage() {
        
        // title view
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 36))
        
        // image
        profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        profileImageView.image = #imageLiteral(resourceName: "phone")
        profileImageView.layer.cornerRadius = 18
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileImageClicked)))
        
        // title
        let titleLabel = UILabel(frame: CGRect(x: 36, y: 0, width: view.frame.width - 36, height: 36))
        titleLabel.text = self.title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = primaryBlack
        
        
        // add to title
        titleView.addSubview(profileImageView)
        titleView.addSubview(titleLabel)
        
        // add to nav
        navigationItem.titleView = titleView
    }
    
    @objc func profileImageClicked(){
        
        print("tapped")
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "profile") as! ProfileViewController
        
        guard let seller = self.otherUser else{
            return
        }
        
        nextVC.user = seller
        navigationController?.pushViewController(nextVC, animated: true)
        
    }
    
    func loadSeller(){
        
        // start progress
        activity = UIActivityIndicatorView(style: .whiteLarge)
        activity?.color = primaryColor
        activity?.center = view.center
        activity?.startAnimating()
        view.addSubview(activity!)
        
        // if come from chats you have a seller
        
        if( otherUser != nil ){
            loadUserImage()
            loadSessions()
            return
        }
        
        ApiServices.getInstance().getUser(productId: product!.id!) { (snap, err) in
            
            if err != nil {
                return;
            }
            
            guard let userSnap = snap?.value as? [String:Any] else{ return }
            
            let user = AppUser(dict: userSnap)
            user.id = snap?.key
            
            self.otherUser = user
            
            self.loadUserImage()
            self.loadSessions()

        }
        
    }
    
    func loadUserImage(){
        
        guard let user = self.otherUser else{
            return
        }
        
        // if the image is there just put it
        
        guard self.profileImage == nil else {
            profileImageView.image = profileImage
            return
        }
        
        // else check if there is a url
        
        guard let url = self.otherUser?.profileImageURL else {
            
            let number = Int.random(in: 0 ..< 7)
            self.otherUser?.profileImageURL = "\(number)"
            profileImageView.image = UIImage(named: "default_user_img_\(number)")
            return
            
        }
        
        // check if the url size is > 1
        
        guard url.count > 1 else {
            if let number = self.otherUser?.profileImageURL {
                profileImageView.image = UIImage(named: "default_user_img_\(number)")
            }else{
                let number = Int.random(in: 0 ..< 7)
                self.otherUser?.profileImageURL = "\(number)"
                profileImageView.image = UIImage(named: "default_user_img_\(number)")
            }
            return
        }

        
        ApiServices.getInstance().loadImage(url: url) { (data, err) in
            
            if err != nil {
                return
            }
            
            let image = UIImage(data: data!)
            
            DispatchQueue.main.async {
                self.profileImageView.image = image
            }
            
        }
        
    }
    
    func loadSessions(){
        
        // if the session == nil go back ??
        
        guard let chatSession = self.chatSession else {
            goBack()
            return
        }
        
        // if the session id == null it means we came from the products .. continue
        // if the session id != null then we came from the chats .. so no need to load the session
        
        if chatSession.id != nil && chatSession.id != "" {
            
            let sessionId = chatSession.id!
            self.loadChat(sessionId:sessionId)
            return
            
        }
        
        // check if the session exists
        
        ApiServices.getInstance().getSession(buyerId: firUser!.uid, productId: product!.id!) { (snap, err) in
            
            if err != nil {
                print("not found creating new one ..")
                self.createNewChat()
                return
            }
            
            // if the value is nil create a new one
            
            guard let _ = snap?.value as? [String:Any] else {
                print("not found creating new one ..")
                self.createNewChat()
                return
            }
            
            // here it is found
            
            guard let sessionDict = snap?.value as? [String:Any] else{
                print("no session id")
                return
            }
            
            // get the id
            let sessionId = sessionDict.keys.max()
            
            // id is there
            print("session id from chat \(sessionId!)")
            
            self.chatSession?.id = sessionId
            self.loadChat(sessionId:sessionId!)
            
        }
        
    }
    
    func loadChat(sessionId:String) {
        
        activity?.removeFromSuperview()
        showEmptyView()
        
        //  for sure it is there
        ApiServices.getInstance().loadChat(sessionId:sessionId){ (snap, err) in
            
            if err != nil {
                return
            }
            
            guard let message = snap?.value as? [String:Any] else { return }
            
            let msg = Message(dict:message)
            msg.id = snap?.key
            
            print("adding message to chat session .. ")
            self.chatSession?.addMessage(msg: msg)
            print(self.chatSession?.messages.count)
            
            // do whatever in the table view
            DispatchQueue.main.async {
                self.chatLoaded()
            }
            
        }
        
    }
    
    func chatLoaded() {
        
        if(chatSession!.hasMessages()){
            showMessages()
        }else{
            showEmptyView()
        }
        
    }
    
    func showMessages(){
        
        emptyLabel?.removeFromSuperview()
        
        if(tableView.isHidden){
            
            tableView.isHidden = false
            tableView.delegate = self
            tableView.dataSource = self
            
        }
        
        tableView.reloadData()
        
        
        
    }
    
    func showEmptyView() {
        
        guard emptyLabel == nil else {
            view.addSubview(emptyLabel!)
            return
        }
    
        emptyLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: 20))
        emptyLabel!.center = view.center
        emptyLabel!.text = "No Messages Yet"
        emptyLabel?.textAlignment = .center
        emptyLabel?.textColor = bodyTextColor
        emptyLabel!.font = UIFont.boldSystemFont(ofSize: 18)
        
        view.addSubview(emptyLabel!)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = chatSession?.messages[indexPath.item]
        let senderId = message?.senderId
        let userId = firUser?.uid
        
        var cell:MessageCell?
        
        switch senderId {
            
        case userId:
            cell = tableView.dequeueReusableCell(withIdentifier: "SenderMessageCell", for: indexPath) as! SenderMessageCell
            cell?.user = appUser!
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "ReciverMessageCell", for: indexPath) as! ReciverMessageCell
            cell?.user = otherUser!
        }
        
        cell?.message = message
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatSession!.messages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        print("num of sections \(1)")
        
        return 1
    }
    
    
    func createNewChat() {
        
        guard let chatSession = self.chatSession else {
            goBack()
            return
        }
        
        guard let sellerId = self.otherUser?.id else {
            print("seller id is not here")
            return
        }
        
        // for sure it is not there
        
        ApiServices.getInstance().postSession(session: chatSession, sellerId: sellerId) { (ref, err) in
            
            if err != nil {
                self.goBack()
                return
            }
            
            chatSession.id = ref?.key
            
            // must be in main queue
            DispatchQueue.main.async {
                self.chatLoaded()
            }
            
        }
        
        
    }
    
    func addBackButton(){
        
        self.navigationItem.backBarButtonItem = nil
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        let backbutton = UIButton(type: .custom)
        backbutton.setImage(#imageLiteral(resourceName: "back_btn"), for: .normal)
        backbutton.addTarget(self, action: #selector(backpressed), for: .touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
        
        
    }
    
    @objc func backpressed(){
        goBack()
    }
    
    func goBack(){
        navigationController?.popViewController(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let height = navigationController?.navigationBar.frame.height else { return }
        moveAndResizeImage(for: height)
    }
    
    private func moveAndResizeImage(for height: CGFloat) {
        
        let coeff: CGFloat = {
            let delta = height - Const.NavBarHeightSmallState
            let heightDifferenceBetweenStates = (Const.NavBarHeightLargeState - Const.NavBarHeightSmallState)
            return delta / heightDifferenceBetweenStates
        }()
        
        let factor = Const.ImageSizeForSmallState / Const.ImageSizeForLargeState
        
        let scale: CGFloat = {
            let sizeAddendumFactor = coeff * (1.0 - factor)
            return min(1.0, sizeAddendumFactor + factor)
        }()
        
        // Value of difference between icons for large and small states
        let sizeDiff = Const.ImageSizeForLargeState * (1.0 - factor) // 8.0
        let yTranslation: CGFloat = {
            /// This value = 14. It equals to difference of 12 and 6 (bottom margin for large and small states). Also it adds 8.0 (size difference when the image gets smaller size)
            let maxYTranslation = Const.ImageBottomMarginForLargeState - Const.ImageBottomMarginForSmallState + sizeDiff
            return max(0, min(maxYTranslation, (maxYTranslation - coeff * (Const.ImageBottomMarginForSmallState + sizeDiff))))
        }()
        
        let xTranslation = max(0, sizeDiff - coeff * sizeDiff)
        
        profileImageView.transform = CGAffineTransform.identity
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: xTranslation, y: yTranslation)
    }
    
}


