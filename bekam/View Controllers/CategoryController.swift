//
//  CategoryController.swift
//  bekam
//
//  Created by Omar on 05/10/2018.
//  Copyright © 2018 Omar. All rights reserved.
//


import UIKit

class CategoriesController: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    //model
    var categories:[String] = ["  All Things","🛋 Home","🚙 Cars","👗 Clothes","📱 Tech","🛠 Tools"]
    
    // ui
    var collectionView:UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataSource = self
        delegate = self
        
        //setup shadow
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowOpacity = 1
        layer.shadowRadius = 10
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        let text = categories[indexPath.item]
        let estSize = getSizeOfText(text: text, fontSize: 20)
        
        return CGSize(width: estSize.width + 16, height: self.frame.height)
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categCell", for: indexPath) as! CategoryCell
        
        cell.category = categories[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print(categories[indexPath.item])
        
    }
    
    
}
