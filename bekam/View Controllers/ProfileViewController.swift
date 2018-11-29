//
//  ProfileViewController.swift
//  bekam
//
//  Created by Omar on 27/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ProfileViewController:BaseUIViewController,UICollectionViewDelegate, UICollectionViewDataSource,LiquidLayoutDelegate, ProductCellObserver{
    
    //model
    var products:[Product] = []
    var user:AppUser?
    var selectedIndex:Int?
    
    //constants
    let margins = 15
    
    // ui
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    var profileImageView:UIImageView!
    var signoutBtn:UIButton!
    
    //flags
    var loaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // check loging
        guard checkLogin(self) else {
            return
        }
        
        // set user
        if user == nil {
            print("user is nil i will set it to the app user")
            user = appUser!
        }
        
        // ui
        setupNav()
        setupResizableImageTitle()

        // collectionView
        let layout = LiquidCollectionViewLayout()
        layout.delegate = self
        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "productCell")
        
        // load items
        loadProducts()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // check loging
        guard checkLogin(self) else {
            return
        }
        
        if !loaded {
            loadProducts()
        }
    }
    
    func setupNav(){
        
        title = appUser?.name
        
        //left button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter_icn")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(navItemClicked))
        
        //right
        signoutBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 28))
        let buttonText = "Signout"
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        signoutBtn.setAttributedTitle(NSAttributedString(string: buttonText, attributes: attributes), for: .normal)
        signoutBtn.setTitleColor(primaryColor, for: .normal)
        signoutBtn.frame.size = CGSize(width: getSizeOfText(text: (signoutBtn.titleLabel?.text)!, fontSize: 20).width + 8, height: signoutBtn.frame.height)
        signoutBtn.addTarget(self, action: #selector(signoutClicked), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: signoutBtn)
    }
    
    @objc func navItemClicked(){
        
    }
    
    @objc func signoutClicked(){
        signout()
    }
    
    func signout(){
        
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
            return
        }
        
        // success
        
        clearCachedInfo()
        resetTabbarViewControllers()
        goToLoginScreen()
        
    }
    
    func clearCachedInfo(){
        
        firUser = nil
        appUser = nil
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: EMAIL_KEY)
        defaults.removeObject(forKey: PASS_KEY)
        
        defaults.synchronize()
        
    }
    
    func resetTabbarViewControllers(){
        
        let viewControllersNames = ["things","notifs","image","chats","profile"]
        
        for i in 0...4 {
            print(i)
            tabBarController?.viewControllers![i] = (storyboard?.instantiateViewController(withIdentifier: viewControllersNames[i]))!
        }
        
        tabBarController?.selectedIndex = 0
    }
    
    func goToLoginScreen(){
        
        let loginScreen = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        present(loginScreen, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        print("CELLLL")
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCell
        
        let product = products[indexPath.item]
        cell.product = product

        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // layout height
    
    func collectionView(collectionView: UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        
        let heights:[CGFloat] = [200, 100, 150]
        return heights[ indexPath.item % 3]
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let id = "productDetailsController"
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyBoard.instantiateViewController(withIdentifier: id) as! ProductDetailsController
        
        nextVC.state = MyProductDetailsState(viewController: nextVC)
        
        selectedIndex = indexPath.item
        nextVC.product = products[indexPath.item]
        
        self.present(nextVC, animated: true, completion: nil)
        
    }
    
    func loadProducts(){
        
        guard let userId = user?.id else { return }
        
        loaded = true
        
        ApiServices.getInstance().loadProducts(userId:userId){ (snapshot, error) in
            
            if(error != nil){
                print(error!.localizedDescription)
                return
            }
            
            if let dict = snapshot!.value as? [String:Any]{
                
                let product = Product(dict: dict)
                product.id = snapshot?.key
                self.products.insert(product, at: 0)
                
                DispatchQueue.main.async {
                    self.removeEmptyView()
                    self.collectionView.reloadData()
                }
                
            }
            
        }
        
    }
    
    func removeEmptyView(){
        self.emptyLabel.isHidden = true
    }
    
    func setupResizableImageTitle(){
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // image view
        profileImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        profileImageView.layer.cornerRadius = 18
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        
        profileImageView.image = user?.getImage()
        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let height = navigationController?.navigationBar.frame.height else { return }
        
        moveAndResizeImage(for: height)
        removeSignoutButtonOnScroll(height:height)
 
    }
    
    func removeSignoutButtonOnScroll(height:CGFloat){
        
        let ratio = ( height / Const.NavBarHeightLargeState )
        let alpha = ratio * 2 - 1
        
        print("alpha = ")
        
        signoutBtn.alpha = alpha
        
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
    
    func notfiy(product: Product) {
        print("notified")
    }
    
    
    
}
