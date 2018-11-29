//
//  ProductDetailsController.swift
//  bekam
//
//  Created by Omar on 01/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

/// Product details controller
class ProductDetailsController: UIViewController {
    
    // state
    var state:ProductDetailsStateDelegate?
    
    
    // models
    var product:Product?
    var bgImage:UIImage?
    
    // ui
    @IBOutlet weak var sellerImageView: UIImageView!
    @IBOutlet weak var priceLabel: PriceLabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var kmLabel: UILabel!
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var bottomContainerView: UIScrollView!
    
    // action button
    var actionButton:UIButton?
    let buttonPaddingLeft = "           "
    let buttonPaddingRight = "   "
    
    // temps
    var kbheight:CGFloat?
    var pushAmount:CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        setupUI()
        setupInteractions()
        setupObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    // pushing the kb
    
    fileprivate func setupObserver(){
        
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
    
    @objc func keyboardWillShow(_ notification : Notification){
        
        // push content
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                kbheight = keyboardSize.height
                pushAmount = getPushAmount(kbheight:kbheight!)
                self.view.frame.origin.y -= pushAmount!
            }
        }
        
        state?.keyboardWillShow(notification)
    }
    @objc func keyboardWillHide(_ notification : Notification){
        
        // push content
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                kbheight = keyboardSize.height
                self.view.frame.origin.y += pushAmount ?? 0
            }
        }
        
        state?.keyboardWillHide(notification)

    }
    func getPushAmount(kbheight:CGFloat) -> CGFloat{
        
        guard let item = view.firstResponder else {
            return 0
        }
        
        let safeLine = view.frame.maxY - kbheight - 50
        let itemY = item.frame.minY + item.superview!.frame.minY
        
        let offset = itemY - safeLine + item.frame.height + 16
        
        if( offset < 0 ){
            return 0
        }
        
        return offset
        
    }
    
    public func setupData(){
        
        if let product = self.product {
            
            // bg view
            if let image = bgImage {
                productImageView.image = image
            }else{
                loadBGImage()
            }
            
            // user img
            sellerImageView.image = UIImage(named: "default")
            loadUserImage()
            
            //price
            priceLabel.text = getPriceLabelString(price:product.price!)
            
            //title
            if !(product.name ?? "").isEmpty{
                productTitle.text = product.name
            }
            state?.setupTitle()
            
            // Description
            if !(product.description ?? "").isEmpty{
                productDescription.text = product.description
            }
            state?.setupDescription()
            
            // city
            self.cityLabel.text = getCity() // TODO:Change later
            
            //  kms
            self.kmLabel.text = getHowFar()
            
        }
        
    }
    
    public func setupUI(){
        
        //navigationController?.isNavigationBarHidden = true
        
        // action button
        actionButton = UIButton(frame: CGRect(x: sellerImageView.frame.minX, y: sellerImageView.frame.minY, width: 0, height: sellerImageView.frame.height))
        actionButton?.backgroundColor = primaryColor
        guard let state = state else {return}
        let actionTitle = NSAttributedString(string: state.getActionButtonTitleString(), attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold),
            NSAttributedString.Key.foregroundColor:UIColor.white])
        actionButton?.setAttributedTitle(actionTitle, for: .normal)
        actionButton?.setImage(UIImage(color: primaryColorDark), for: .highlighted)
        actionButton?.layer.cornerRadius = 20
        actionButton?.widthToFit()
        actionButton?.addTarget(self, action: #selector(actionButtonClicked), for: .touchUpInside)
        view.insertSubview(actionButton!, belowSubview: sellerImageView)
        
        // profile image
        sellerImageView.layer.cornerRadius = sellerImageView.frame.height/2
        sellerImageView.layer.masksToBounds = true
        
        // map view
        mapImageView.layer.cornerRadius = 15
        mapImageView.backgroundColor = greyColor_0
        
        state.setupUI()
    }
    
    @objc func actionButtonClicked(){
        
        print("in clicked")
        
        guard checkLogin(self,goBack: false) else{
            print("no login .. ")
            return
        }
        
        if let state = self.state {
            state.actionButtonClicked()
        }
        
        
    }
    
    public func letsChatClicked(){
        
        guard checkLogin(self,goBack: false) else{
            print("no login")
            return
        }
        
        print("in chat .. ")
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        secondViewController.chatSession = ChatSession(id: "", ownerId: firUser?.uid ?? "", productId: product?.id ?? "")
        secondViewController.product = product
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.pushViewController(secondViewController, animated: true)
        
    }
    
    public func markAsSoldClicked(){
        
        
        
    }
    
    func setupInteractions(){
        state?.setupInteractions()
    }
    
    @IBAction func closeClicked(_ sender: Any) {
        dismissMe()
    }
    
    func dismissMe(){
        
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name.detailsDismissed, object: self.product)
        }
    }
    
    
    ////////////////////// PRIVATE HELPING FUNCTIONS ////////////////////
    
    
    fileprivate func loadBGImage(){
        
        guard let url = product?.imagesURLS?[0]! else {
            print("no url")
            return
        }
        
        ApiServices.getInstance().loadImage(url: url) { (data, error) in
            
            if(error == nil){
                
                let image = UIImage(data: data!)
                self.productImageView.image = image
                
            }else{
                print(error)
            }
            
        }
        
    }
    
    fileprivate func loadUserImage(){
        
        guard let url = product?.imagesURLS?[0]! else{
            print("no url")
            return
        }
        
        ApiServices.getInstance().loadImage(url: (product?.imagesURLS?[0])!) { (data, error) in
            
            if(error == nil){
                
                let image = UIImage(data: data!)
                self.productImageView.image = image
                
            }else{
                print(error)
            }
            
        }
        
    }
    
    func getPriceLabelString(price:Double) -> String {
        
        if price == 0 {
            return "  😍Free  "
        }else{
            return "$\(Int(price))"
        }
        
    }
    
    func removeDescription(){
        
    }
    
    func removeTitle(){
        
    }
    
    fileprivate func getCity() -> String {
        return "Boulder"
    }
    
    fileprivate func getHowFar() -> String {
        return "15KM away"
    }
    
    
}


///////////////////////////// STATES ///////////////////////////////////



/// MyProductDetailsState Controller. Used to controll the prdoduct is owned by him.

public class MyProductDetailsState : NSObject, ProductDetailsStateDelegate, UITextFieldDelegate {
    
    var priceTF:UITextField?
    var titleTF:UITextField?
    var descTF:UITextField?
    
    //temps
    var currentEditedTF:UITextField?
    var currentLabel:UILabel?
    var currentModel:String?
    var actionButtonsView:UIView?
    
    var vc: ProductDetailsController
    
    required init(viewController: ProductDetailsController) {
        self.vc = viewController
    }
    
    func setupTitle() {
        //
    }
    
    func setupDescription() {
        //
    }
    
    func actionButtonClicked() {
        vc.markAsSoldClicked()
    }
    
    func viewTapped(view: UIView) {
        print("view tapped")
    }
    
    
    
    func setupUI() {
        
        // chat button
        vc.actionButton!.setTitle("  💰 Mark as Sold", for: .normal)
        vc.sellerImageView.isHidden = true
        
        // make the title transparent if there is nothing
        if (vc.product?.name ?? "").isEmpty {
            vc.productTitle.textColor = primaryColorHalfAlpha
        }
        
        // make the description transparent if there is nothing
        if (vc.product?.description ?? "").isEmpty {
            vc.productDescription.textColor = primaryColorHalfAlpha
        }
        
        
    }
    
    func setupInteractions() {
        addTapRecognizer(view: vc.priceLabel)
        addTapRecognizer(view: vc.productTitle)
        addTapRecognizer(view: vc.productDescription)
    }
    
    private func addTapRecognizer(view:UIView){
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapGesture)
        view.isUserInteractionEnabled = true
        
    }
    
    @objc func tapped(sender: UITapGestureRecognizer){
        
        if(currentLabel != nil){
            endEditing()
        }
        
        // setup lable thing
        currentLabel = sender.view as! UILabel
        
        switch currentLabel {
        case vc.productTitle:
            // title
            titleTF = UITextField()
            currentEditedTF = titleTF;
            currentModel = vc.product?.name
            replaceLabelWithCurrentTextField()
        case vc.priceLabel:
            // price
            priceTF = UITextField()
            currentEditedTF = priceTF;
            currentModel = "\(vc.product?.price)"
            replaceLabelWithCurrentTextField()
            currentEditedTF!.keyboardType = .numberPad
            currentEditedTF!.text = ""
        case vc.productDescription:
            // description
            descTF = UITextField()
            currentEditedTF = descTF;
            currentModel = vc.product?.description
            replaceLabelWithCurrentTextField()
        default:
            print("something else tapped")
        }
        
        
    }
    
    func endEditing(){
        
        currentEditedTF?.resignFirstResponder()
        currentEditedTF?.isHidden = true
        currentLabel?.isHidden = false
        currentLabel = nil
        currentEditedTF = nil
        
    }
    
    @objc func doneClicked(){
        
        guard let tf = currentEditedTF else {
            endEditing()
            return
        }
        
        let newValue = tf.text!
        
        if !isValid(newValue:newValue) {
            vc.view.resignFirstResponder()
            return
        }
        
        // upload to db if valid value
        let newProduct = createNewProductFromNewValues(newValue: newValue)
        updateProduct(newProduct: newProduct, newValue: newValue)
        
    }
    
    func createNewProductFromNewValues(newValue:String) -> Product{
        
        let product = Product(from: vc.product!)
        
        switch currentLabel {
        case vc.priceLabel:
            product.price = Double(newValue)
        case vc.productTitle:
            product.name = newValue
        case vc.productDescription:
            product.description = newValue
        default:
            print("no current label")
        }
        
        
        
        return product
        
    }
    
    func isValid(newValue: String) -> Bool {
        
        if newValue == ""{
            return false
        }
        
        if currentEditedTF == priceTF {
            return Int(newValue) != nil
        }
        
        return true
        
    }
    
    @objc func cancelClicked(){
        endEditing()
    }
    
    func getKBHeight(_ notification: Notification) -> CGFloat {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            return keyboardSize.height
        }
        
        return 0
        
    }
    
    func getActionButtonsView() -> UIView {
        
        // container view
        let actionButtonsView:UIView = UIView(frame: CGRect(x: 0, y: vc.view.frame.maxY , width: vc.view.frame.width, height: 50))
        actionButtonsView.alpha = 0
        
        // done button
        let doneBtn = UIButton(frame: CGRect(x: 0, y: 0, width: self.vc.view.frame.width/2, height: 50))
        let doneTitle = NSAttributedString(string: "APPLY", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold),
            NSAttributedString.Key.foregroundColor:UIColor.white])
        doneBtn.backgroundColor = primaryColor
        doneBtn.setAttributedTitle(doneTitle, for: UIControl.State.normal)
        doneBtn.addTarget(self, action: #selector(doneClicked) , for: UIControl.Event.touchUpInside)
        doneBtn.setImage(UIImage(color: primaryColorDark), for: UIControl.State.highlighted)
        actionButtonsView.addSubview(doneBtn)
        
        // cancel button
        let cancelBtn = UIButton(frame: CGRect(x: doneBtn.frame.maxX, y: 0, width: self.vc.view.frame.width/2, height: 50))
        let cancelTitle = NSAttributedString(string: "CANCEL", attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16, weight: .bold),
            NSAttributedString.Key.foregroundColor:UIColor.red])
        cancelBtn.backgroundColor = .white
        cancelBtn.setAttributedTitle(cancelTitle, for: UIControl.State.normal)
        cancelBtn.addTarget(self, action: #selector(cancelClicked) , for: UIControl.Event.touchUpInside)
        cancelBtn.setImage(UIImage(color: greyColor_0), for: UIControl.State.highlighted)
        actionButtonsView.addSubview(cancelBtn)
        
        vc.view.addSubview(actionButtonsView)
        return actionButtonsView
        
    }
    
    func keyboardWillShow(_ notification : Notification) {
        
        
        actionButtonsView = getActionButtonsView()
        let KBHeight = getKBHeight(notification)
        let pushAmount = vc.pushAmount ?? 0
        let actionButtonsY = self.vc.view.frame.maxY - KBHeight - actionButtonsView!.frame.height + ( pushAmount * 2 )
        
        actionButtonsView!.alpha = 1
        actionButtonsView!.setY(value: actionButtonsY)
        
    }
    
    func keyboardWillHide( _ notification:Notification ){
        
        print("Hiding .. ")
        
        if actionButtonsView != nil {
            
            print("\(actionButtonsView?.frame.minY)")
            
            actionButtonsView?.removeFromSuperview()
        }
        
        actionButtonsView = nil
        
    }
    
    
    func replaceLabelWithCurrentTextField(){
        
        guard let tf = currentEditedTF else {
            return
        }
        
        guard let label = currentLabel else {
            return
        }
        
        
        tf.frame = label.frame
        tf.text = label.text
        tf.textAlignment = label.textAlignment
        tf.textColor = label.textColor
        tf.font = label.font
        label.isHidden = true
        
        print("current modal value \(currentModel)")
        
        if((currentModel ?? "").isEmpty){
            currentEditedTF!.text = ""
        }
        
        if currentEditedTF == priceTF {
            vc.view.addSubview(tf)
        }else{
            vc.bottomContainerView.addSubview(tf)
        }
        
        currentEditedTF?.becomeFirstResponder();
        
    }
    
    func productUpdatedSuccessfully(newProduct:Product, newValue: String){
        
        vc.product = newProduct
        currentLabel?.text = currentEditedTF?.text
        
        if currentLabel == vc.priceLabel {
            if let price = Double(newValue) {
                currentLabel?.text = vc.getPriceLabelString(price: price)
            }
        }
        
        endEditing();
        
    }
    
    func updateProduct(newProduct:Product, newValue: String){
        
        ApiServices.getInstance().updateProduct(product: newProduct) { (ref, error) in
            
            guard error == nil else {
                print(error)
                self.endEditing()
                return
            }
            
            print("product updated")
            self.productUpdatedSuccessfully(newProduct: newProduct, newValue: newValue)
            
        }
    }
    
    func getActionButtonTitleString() -> String {
        return vc.buttonPaddingRight + "💰 Mark as sold" + vc.buttonPaddingRight
    }
    
    
}

/// OtherProductDetailsState Class. Used to controll the prdoduct is not owned by him.

public class OtherProductDetailsState : ProductDetailsStateDelegate  {
    
    
    var vc: ProductDetailsController
    
    required init(viewController: ProductDetailsController) {
        self.vc = viewController
    }
    
    func setupUI() {
        
        
    }
    
    func setupTitle() {
        
        if let name = vc.product?.name {
            
            if name != "" {
                vc.productTitle.text = name
            }else{
                vc.removeTitle()
            }
            
        }else{
            vc.removeDescription()
        }
    }
    
    func setupDescription() {
        //
    }
    
    func actionButtonClicked() {
        vc.letsChatClicked()
    }
    
    func viewTapped(view: UIView) {
        //
    }
    
    func setupInteractions() {
        //
    }
    
    func keyboardWillShow(_ notificaiton: Notification) {
        //
    }
    
    func keyboardWillHide(_ notification: Notification) {
        //
    }
    
    func getActionButtonTitleString() -> String {
        return vc.buttonPaddingRight + "💬 Let's Chat" + vc.buttonPaddingRight
    }
    
    
}

/// Used to control the state of the product weather the product is owned by the curent user or not.

protocol ProductDetailsStateDelegate {
    /// The view controller or ( context ) that uses the state class.
    var vc:ProductDetailsController { get set }
    /// initialize the state providing the view controller that uses it
    ///
    /// - Parameter viewController: the view controller that uses it
    init(viewController: ProductDetailsController)
    /// setup the ui of the screen
    func setupUI()
    /// setup the title view of the product
    func setupTitle()
    /// setup the description view of the product
    func setupDescription()
    /// determinse what to do when the acion button of the screen is clicked
    func actionButtonClicked()
    /// set up the interaction with the user
    func setupInteractions()
    /// determines what to do when the keyboard shows
    func keyboardWillShow(_ notificaiton:Notification)
    /// determines what to do when the keyboard hides
    func keyboardWillHide(_ notification:Notification)
    /// return the action button title for each state
    func getActionButtonTitleString()->String
}

/// an observer class for the product cell. when someone clicks on it the cell. it notifies the observers.

protocol ProductCellObserver {
    func notfiy(product:Product)
}
