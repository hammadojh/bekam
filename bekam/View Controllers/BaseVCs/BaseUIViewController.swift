//
//  BaseUIViewController.swift
//  bekam
//
//  Created by Omar on 30/09/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

class BaseUIViewController: UIViewController{
    
    var tabImageName: String = "";

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title
        if let title = title {
            navigationItem.title = title
        }else{
            navigationItem.title = "Untitled"
        }
        
    }
    
    public func setTabItem(){
        // tab
        tabBarItem = CreateTabItem(tabName: tabImageName)
    }

}
