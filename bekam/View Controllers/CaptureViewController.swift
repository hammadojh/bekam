//
//  CaptureViewController.swift
//  bekam
//
//  Created by Omar on 10/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit
import AVFoundation

class CaptureViewController: UIViewController, AVCapturePhotoCaptureDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate{

    //ui
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var postNowButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var priceBottomTextView: UIView!
    @IBOutlet weak var howMuchLabel: UILabel!
    @IBOutlet weak var priceContainer: UIView!
    @IBOutlet weak var doneLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // captureing process
    let captureSession = AVCaptureSession()
    var backCam :AVCaptureDevice?
    var frontCam : AVCaptureDevice?
    var currentCam : AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturedImage:UIImage?
    
    //image picker
    var pickedImage:UIImage?
    let imagePicker = UIImagePickerController()
    
    //other
    var keyboardHeight:CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        initiateCamera()
    }
    
    
    @IBAction func captureClicked(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func pickClicked(_ sender: Any) {
        pickImage()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        if imageView.image != nil {
            imageView.image = nil
            hidePriceContainer()
        } else {
            dismissMe()
        }
    }
    
    
    @IBAction func postNowClicked(_ sender: Any) {
        
        // check loging
        guard checkLogin(self,goBack: false) else{
            return
        }
        
        postNowButton.isEnabled = false
        uploadNewProduct()
    }
    
    
    func showKeyboard(){
        
        self.priceTextField.becomeFirstResponder()
        
    }
    
    
    ///////////////////////// DELEGATE FUNCTIONS  //////////////////////

    
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        if let imageData = photo.fileDataRepresentation() {
            
            capturedImage = UIImage(data: imageData)
            pickedImage = capturedImage
            imageView.image = pickedImage
            showKeyboard()
            
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[.originalImage] as? UIImage {
            pickedImage = selectedImage
            imageView.image = pickedImage
            showKeyboard()
            
        }else{
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        picker.dismiss(animated: true)
        
    }
    
    
    
    ///////////////////////// PRIVATE HELPING FUNCTION //////////////////////
    
    
    fileprivate func uploadNewProduct(){
        
        guard pickedImage != nil else {
            print("No image was slected")
            return
        }
        
        let price = priceTextField.text == "" ? "0" : priceTextField.text
        
        startUploadingUIBehaviour()
        
        ApiServices.getInstance().postProduct(price: price!, image: pickedImage!) { (meta, error) in
            
            guard error == nil else {
                print("Error in uploading the image")
                return
            }
            
            self.setupAfterLoadedUI()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
                // Your code with delay
                self.priceTextField.resignFirstResponder()
                self.dismissMe()
            }
            
        }
        
    }
    
    func setupAfterLoadedUI(){
        
        DispatchQueue.main.async { [weak self] in
            self?.postNowButton.setTitle("Done", for: .normal)
            self?.doneLabel.alpha = 1
            self?.doneLabel.frame.offsetBy(dx: 0, dy: 24)
            
            UIView.animate(withDuration: 0.35, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
                
                self?.activityIndicator.alpha = 0
                self?.doneLabel.alpha = 1
                self?.doneLabel.frame.offsetBy(dx: 0, dy: -24)
                
            }, completion: nil)
        }
    }
    
    func startUploadingUIBehaviour(){
        
        // create a progress indication
        
        UIView.animate(withDuration: 0.35, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            
            //hide these
            self.howMuchLabel.alpha = 0
            self.priceTextField.alpha = 0
            self.currencyLabel.alpha = 0
            self.priceBottomTextView.alpha = 0
            
            //show this
            self.activityIndicator.alpha = 1
            
            //other stuff
            self.postNowButton.setTitle("Uploading ☁️ ..", for: .normal)
            self.postNowButton.isEnabled = false
            
        }, completion: nil)
        

        
    }
    
    
    func dismissMe(){
        dismiss(animated: true) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "captureDismissed"), object: nil)
        }
    }
    
    
    
    fileprivate func setupUI(){
        
        postNowButton.backgroundColor = primaryColor
        priceTextField.textColor = primaryColor
        priceTextField.tintColor = primaryColor
        priceContainer.alpha = 0
        priceContainer.frame.origin.y = view.frame.maxY - priceContainer.frame.height
        priceContainer.layer.cornerRadius = 20
        priceContainer.backgroundColor = primaryColorTrans
        doneLabel.alpha = 0
        activityIndicator.alpha = 0
        
        // getting the keyboard height
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(self, selector : #selector(kbDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        
        self.keyboardHeight = calculateKeyboardHeight(notification: notification)
        
        if (self.keyboardHeight) != nil {
            showPriceView()
        }

    }
    
    @objc func kbDidShow(){
        
        // show
        print("kb did show")
        
    }
    
    func showPriceView(){
        
        UIView.animate(withDuration: 0.35, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.priceContainer.frame.origin.y = self.view.frame.maxY - self.priceContainer.frame.height - self.keyboardHeight!
            self.priceContainer.alpha = 1.0
        }, completion: nil)
        
        
    }
    
    func hidePriceContainer(){
        priceTextField.resignFirstResponder();
        self.priceContainer.alpha = 0
    }
    
    fileprivate func initiateCamera(){
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        
    }
    
    fileprivate func setupCaptureSession(){
        captureSession.sessionPreset  = .photo
    }
    
    fileprivate func setupDevice(){
        
        let deviceDiscoverSession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .unspecified)
        
        let devices = deviceDiscoverSession.devices
        
        for device in devices {
            
            if device.position == .back {
                backCam = device
            } else if device.position == .front {
                frontCam = device
            }
            
        }
        
        currentCam = backCam
        
        
    }
    
    fileprivate func setupInputOutput(){
        
        do{
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCam!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            
        }catch{
            print(error)
        }
        
    }
    
    fileprivate func setupPreviewLayer(){
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
        
    }
    
    fileprivate func startRunningCaptureSession(){
        
        captureSession.startRunning()
        
    }
    
    
    fileprivate func pickImage(){
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    

}
