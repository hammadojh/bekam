import Foundation
import UIKit

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
