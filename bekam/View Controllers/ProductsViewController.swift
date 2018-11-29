//
//  ViewController.swift
//  bekam
//
//  Created by Omar on 28/09/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

class ProductsViewController: BaseUIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource,LiquidLayoutDelegate, ProductCellObserver {

    
    //model
    var products:[Product] = []
    var selectedIndex:Int?
    
    let images = ["home","note","car","phone"]

    // ui
    @IBOutlet weak var collectionView: UICollectionView!
    
    //constants
    let margins = 15
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tab bar
        setupTabItems()
        
        // search bar
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // collectionView
        
        let layout = LiquidCollectionViewLayout()
        layout.delegate = self        
        collectionView.collectionViewLayout = layout
        collectionView.delegate = self
        
        collectionView.register(UINib(nibName: "ProductCell", bundle: nil), forCellWithReuseIdentifier: "productCell")

        
        //setups
        setupNav()
        
        //load products
        loadProducts()
        
        //show login
        showLogin()
        
        
    }
    
    func showLogin(){
        let screen = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(screen, animated: false, completion: nil)
    }

    
    //////////////////// COLLECTION VIEW DELEGATE ////////////////////////////
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return products.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "productCell", for: indexPath) as! ProductCell
        
        let product = products[indexPath.item]
        cell.product = product
        cell.observer = self
        
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

        if (products[indexPath.item].userId == firUser?.uid ) {
            nextVC.state = MyProductDetailsState(viewController: nextVC)
            registerDismissObserver()
            print("My")
        }else {
            nextVC.state = OtherProductDetailsState(viewController: nextVC)
            print("Other")
        }
        
        selectedIndex = indexPath.item
        nextVC.product = products[indexPath.item]
        
        let nav = UINavigationController(rootViewController: nextVC)
        nav.isNavigationBarHidden = false
        
        self.present(nav, animated: true, completion: nil)
        
    }
    
    func registerDismissObserver(){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(detialsDismissed),
            name: Notification.Name.detailsDismissed,
            object: nil
        )
        
    }
    
    @objc func detialsDismissed(_ notification:Notification){
        
        guard let newProduct = notification.object as? Product else { print("no object from notif"); return }
        guard let index = selectedIndex else { return }
        products[index] = newProduct
        self.collectionView.reloadData()
        
    }


    
    /////////////// HELPER FUNCTIONS //////////////
    
    private func setupNav(){
        
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .white
        
        //left button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "filter_icn")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(navItemClicked))
        
        //right button
        let cityButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 28))
        let buttonText = "Khobar"
        let attributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
        cityButton.setAttributedTitle(NSAttributedString(string: buttonText, attributes: attributes), for: .normal)
        cityButton.setTitleColor(primaryBlack, for: .normal)
        cityButton.backgroundColor = .white
        cityButton.layer.cornerRadius = 18
        cityButton.layer.borderWidth = 1
        cityButton.layer.borderColor = greyColor_5.cgColor
        
        cityButton.frame.size = CGSize(width: getSizeOfText(text: (cityButton.titleLabel?.text)!, fontSize: 20).width + 8, height: cityButton.frame.height)
        
        cityButton.addTarget(self, action: #selector(cityButtonClicked), for: .touchUpInside)
        
        // add the button
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cityButton)
        
        
    }
    
    @objc private func navItemClicked(){
        print("clicked")
    }
    
    @objc private func cityButtonClicked(){
        print("city")
    }
    
    @objc private func cityButtonPressed(){
        print("city")
    }
    
    
    private func setupTabItems(){
        
        for (i,name) in tabNames.enumerated() {
            
            let basename = "tab_icn"
            let activeExtention = "active"
            
            self.tabBarController?.tabBar.items?[i].title = screensTitles[i]
            self.tabBarController?.tabBar.tintColor = primaryColor
            self.tabBarController?.tabBar.unselectedItemTintColor = greyColor_0
            self.self.tabBarController?.tabBar.items?[i].image = UIImage(named: "\(basename)_\(name)")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            self.self.tabBarController?.tabBar.items?[i].selectedImage = UIImage(named:"\(basename)_\(name)_\(activeExtention)")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            
            if i == 2 { // img icon
                
                // set the image tab item
                
                if let tabBar = self.tabBarController?.tabBar {
                    let bgColor = primaryColor
                    let itemWidth = tabBar.frame.width / CGFloat(tabBar.items!.count)
                    let bgView = UIView(frame: CGRect(x: itemWidth*CGFloat(i), y: 0, width: itemWidth, height: itemWidth))
                    //bgView.center = tabBar.center
                    //bgView.center.y = tabBar.frame.maxY
                    bgView.backgroundColor = bgColor
                    bgView.layer.cornerRadius = itemWidth/2
                    bgView.center.y -= itemWidth/4
                    tabBar.insertSubview(bgView, at: 0)
                }
                
            }
        }
    }
    
    //////////////////// API ///////////////////////
    
    
    func loadProducts(){
        
        ApiServices.getInstance().loadProducts{ (snapshot, error) in
            
            if(error != nil){
                print(error!.localizedDescription)
                return
            }
            
            if let dict = snapshot!.value as? [String:Any]{
                
                let product = Product(dict: dict)
                product.id = snapshot?.key
                self.products.insert(product, at: 0)
                self.collectionView.reloadData()
                
            }
            
        }
        
    }
    
    //////////////////// NAV //////////////////////
    
    func notfiy(product: Product) {
        
        guard checkLogin(self,goBack: false) else{
            return
        }
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        secondViewController.chatSession = ChatSession(id: "", ownerId: firUser?.uid ?? "", productId: product.id ?? "")
        
        secondViewController.product = product
        navigationController?.pushViewController(secondViewController, animated: true)
        
    }
    
   
    
}


// OTHER VIEW CONTROLLERS

class NotificationsViewController:BaseUIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // check loging
        checkLogin(self)
        
    }
    
}
