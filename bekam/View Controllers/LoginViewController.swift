//
//  LoginViewController.swift
//  bekam
//
//  Created by Omar on 27/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, UITextFieldDelegate, KeyboardPusherDelegate {
    
    // ui
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var forgetBtn: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var laterBtn: UIButton!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    var nameField:UITextField?
    
    // state
    var state:loginScreenState!
    
    //pushing the KB
    var pusher:KeyboardTextFieldPusher!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //check cached login info
        checkCachedLoginInfo()
        
        //setupui
        setupUI()
        
        // set state
        state = LoginState(vc: self)
        
        // delegates
        emailTF.delegate = self
        password.delegate = self
        
        // pusher
        pusher = KeyboardTextFieldPusher(delegate: self)
        
    }
    
    func setupUI(){
    }
    
    func hideViews(_ hide:Bool){
        
        let subviews = view.subviews
        
        for sub in subviews {
            
            sub.isHidden = hide
            
        }
        
    }
    
    func checkCachedLoginInfo(){
        
        print("checking defs")
        let defaults = UserDefaults.standard
        
        guard let email = defaults.string(forKey: EMAIL_KEY) else{
            print("no emaoil")
            return
        }
        
        guard let pass = defaults.string(forKey: PASS_KEY) else {
            print("np pass")
            return
        }
        
        login(email: email, password: pass)

        
    }
    
    func saveUserInfoToCache(email:String,pass:String){
        
        print("saving to defs ")
        
        let defaults = UserDefaults.standard
        
        defaults.set(email, forKey: EMAIL_KEY)
        defaults.set(pass, forKey: PASS_KEY)
        
        if !defaults.synchronize() {
            print("not saved ..")
        }
        
    }
    
    func addKeyboardObservers() {
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector:
            #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        pusher.keyboardWillShow(notification)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        pusher.keyboardWillHide(notification)
    }
    
    
    func getContainer() -> UIViewController {
        return self
    }
    
    func getExtraPush() -> CGFloat {
        return 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        
        case nameField:
            emailTF.becomeFirstResponder()
        case emailTF:
            password.becomeFirstResponder()
        default:
            goClicked()
        }
        
        keyboardWillShow(Notification(name: UIResponder.keyboardWillShowNotification))
        return true
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        keyboardWillShow(Notification(name: UIResponder.keyboardWillShowNotification))
        return true
    }
    
    func goClicked(){
        state.goClicked()
    }
    
    func goLoginClicked(){
        
        // check fields
        
        if !checkField(emailTF) {
            return
        }
       
        if !checkField(password){
            return
        }
        
        // get text
        
        let email = emailTF.text!
        let pass = password.text!
        
        // login
        login(email: email, password: pass)
        
    }
    
    func checkField(_ tf:UITextField) -> Bool {
        guard !(tf.text ?? "").isEmpty else{
            showError(tf)
            return false
        }
        return true
    }
    
    func goSignupClicked(){
        
        // check fields
        
        if !checkField(emailTF) {
            return
        }
        
        if !checkField(password){
            return
        }
        
        if !checkField(nameField!){
            return
        }
        
        // get texts
        
        let name = nameField?.text!
        let email = emailTF.text!
        let pass = password.text!
        
        // signup
        
        signup(name: name!, email: email, password: pass)
        
    }
    
    func showError(_ tf:UITextField){
        
        let duration = 0.2
        let shaking:CGFloat = 20
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            
            tf.setX(value: tf.frame.minX + shaking)
            
        }, completion: nil)
        
        UIView.animate(withDuration: duration, delay: duration, usingSpringWithDamping: 4, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            
            tf.setX(value: tf.frame.minX - shaking)
            
        }, completion: nil)
    }
    
    // actions
    
    @IBAction func laterClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func noAcctClicked(_ sender: Any) {
        state.switchClicked()
    }
    
    public func switchToLogin(){
        
        // change state
        
        state = LoginState(vc: self)
        
        // show tf
        
        UIView.animate(withDuration: 0.5, animations: {
            
            self.nameField?.alpha = 0
            
        }) { (bool) in
            
            self.nameField?.removeFromSuperview()
            self.nameField = nil
            
        }
        
        // change label text
        
        signupBtn.setTitle(state.getSwitchLabel(), for: .normal)
        
        // remove hide button
        
        forgetBtn.isHidden = false
        
        
    }
    
    public func switchToSignup(){
        
        // change state
        
        state = RegisterState(vc: self)
        
        // show tf
        
        if ( nameField == nil ) {
            nameField = copyTF(from: emailTF)
            nameField!.placeholder = "You Name"
            nameField?.delegate = self
        }
        
        self.view.addSubview(self.nameField!)
        nameField?.alpha = 0
        
        UIView.animate(withDuration: 0.5) {
            
            self.view?.addConstraint(NSLayoutConstraint(item: self.nameField!, attribute: .bottom, relatedBy: .equal, toItem: self.emailTF, attribute: .top, multiplier: 1, constant: -16))
            self.nameField?.alpha = 1
            
        }
        
        // change label text
        
        signupBtn.setTitle(state.getSwitchLabel(), for: .normal)
        
        // remove hide button
        
        forgetBtn.isHidden = true
        
        
    }
    
    func copyTF(from:UITextField) -> UITextField{
        
        let newTF = UITextField(frame: from.frame)
        
        newTF.font = from.font
        newTF.keyboardType = from.keyboardType
        newTF.textAlignment = .center
        newTF.background = from.background
        newTF.backgroundColor = from.backgroundColor
        newTF.textColor = from.textColor
        newTF.returnKeyType = from.returnKeyType
        newTF.borderStyle = from.borderStyle
        
        return newTF
        
    }
    
    // private helping methods
    
    private func login(email:String, password:String){
        
        showProgress(true)
        
        Auth.auth().signIn(withEmail: email, password: password) { (usr, error) in
            
            if let error = error {
                print("error login user .. ")
                print(error.localizedDescription)
                self.showProgress(false)
                return
            }
            
            if let u = usr {
                firUser = u
                self.getAppUser()
                // save user info to cache
                self.saveUserInfoToCache(email: email, pass: password)
            }
            
            
        }
    }
    
    private func signup(name:String, email:String, password:String){
        
        self.showProgress(true)
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
            guard let authUser = result else {
                print("no auth user .. ")
                self.showProgress(false)
                return
            }
            
            // create a new App user and post it
            
            firUser = authUser
            appUser = AppUser(id:authUser.uid)
            appUser?.name = name
            appUser!.email = authUser.email
            
            ApiServices.getInstance().addNewUser(user: appUser!, userId: appUser!.id!, completion: { (uRef, err) in
                
                if err != nil {
                    print("cannot add user .. ")
                    self.showProgress(false)
                    return
                }
                
                // success sign in
    
                self.login(email: email, password: password)
                
                
            })
            
        }
    }
    
    private func getAppUser(){
        
        guard let userId = firUser?.uid else {
            return
        }
        
        ApiServices.getInstance().getUser(id: userId) { (snapshot, error) in
            
            guard error == nil else {
                self.showProgress(false)
                print("error getting user")
                return;
            }
            
            guard let user = snapshot?.value as? [String:Any] else {
                self.showProgress(false)
                print("user cannot be a dictionary")
                return;
            }
            
            // success
            
            appUser = AppUser(dict:user)
            appUser?.id = firUser!.uid
            
            // dismiss
            
            DispatchQueue.main.async {
                self.showProgress(false)
                self.dismiss(animated: true, completion: nil)
            }
            
        }
        
    }
    
    private func showProgress(_ show:Bool){
        self.progress.isHidden = !show
        self.hideViews(show)
    }
    
}

protocol loginScreenState {
    var vc:LoginViewController! { set get }
    init(vc:LoginViewController)
    func goClicked()
    func switchClicked()
    func getSwitchLabel() -> String
}

class LoginState:loginScreenState {
    
    var vc: LoginViewController!
    
    required init(vc:LoginViewController){
        self.vc = vc
    }
    
    func goClicked() {
        vc.goLoginClicked()
    }
    
    func getSwitchLabel() -> String{
        return "No Account ? Signup Now"
    }
    
    func switchClicked() {
        vc.switchToSignup()
    }
    
}

class RegisterState:loginScreenState {
    
    var vc: LoginViewController!
    
    required init(vc:LoginViewController){
        self.vc = vc
    }
    
    func goClicked()  {
        vc.goSignupClicked()
    }
    
    func getSwitchLabel() -> String{
        return "Already have an account ? Login Now"
    }
    
    func switchClicked() {
        vc.switchToLogin()
    }
    
}


