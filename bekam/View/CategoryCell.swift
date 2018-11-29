//
//  CategoryCell.swift
//  bekam
//
//  Created by Omar on 05/10/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import UIKit

class CategoryCell: UICollectionViewCell {
    
    //model
    var category:String! {
        
        didSet{
            categoryLabel.text = category
            categoryLabel.sizeToFit()
        }
    }
    
    // ui
    @IBOutlet var categoryLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    
    
    
}
