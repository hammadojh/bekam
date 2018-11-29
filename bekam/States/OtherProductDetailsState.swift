import Foundation
import UIKit

public class OtherProductDetailsState : ProductDetailsStateDelegate {
    
    
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
