//
//  CameraViewController.swift
//  
//
//  Created by Omar on 10/11/2018.
//



import UIKit


class CameraViewController: BaseUIViewController {
    
    let imagePicker = UIImagePickerController()
    var pickedImage:UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        presentViewController(id: "captureViewController") { () -> (Void) in
            self.navigateToTab(index: 0)
        }
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ////////////////////////////////////// PRIVATE HELPING FUNCTIONS ///////////////////////////
    
    fileprivate func navigateToTab(index:Int){
        
        if let tabBarController = self.tabBarController as? UITabBarController {
            tabBarController.selectedIndex = index
        }
        
    }
    
    fileprivate func presentViewController(id:String, completion: @escaping ()->(Void)) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let captureViewController = storyBoard.instantiateViewController(withIdentifier: id) as! CaptureViewController
        self.present(captureViewController, animated: true, completion: completion)
    }

    
    
}
