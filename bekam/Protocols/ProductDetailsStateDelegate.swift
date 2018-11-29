//
//  Details.swift
//  bekam
//
//  Created by Omar on 21/11/2018.
//  Copyright © 2018 Omar. All rights reserved.
//

import Foundation
import UIKit

protocol ProductDetailsStateDelegate {
    var vc:ProductDetailsController { get set }
    init(viewController: ProductDetailsController)
    func setupUI()
    func setupTitle()
    func setupDescription()
    func actionButtonClicked()
    func setupInteractions()
    func keyboardWillShow(_ notificaiton:Notification)
    func keyboardWillHide(_ notification:Notification)
    func getActionButtonTitleString()->String
}
