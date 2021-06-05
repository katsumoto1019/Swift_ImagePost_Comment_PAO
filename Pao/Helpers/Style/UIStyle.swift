//
//  UIStyle.swift
//  Pao
//
//  Created by Developer on 3/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class UIStyle {
    
    // Circular-styled button, 'unset' state
    class func CircularButton(button: UIButton, size: CGFloat = UIFont.sizes.normal) {
        
        // Font
        let font = UIFont.app.withSize(size)
        button.titleLabel?.font = font
        
        // Border
        button.layer.borderWidth = 1
        button.layer.cornerRadius = button.bounds.size.width / 2
        
        // Colors
        button.setTitleColor(ColorName.textWhite.color, for: .normal)
        
        button.layer.borderColor = ColorName.placeholder.color.cgColor
        button.backgroundColor = .clear
        
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = .center
    }
    
    // Circular-styled button, 'set' state
    class func CircularButtonSelected(button: UIButton, size: CGFloat = UIFont.sizes.normal) {
        
        // Font
        let font = UIFont.app.withSize(size);
        button.titleLabel?.font = font
        
        // Border
        button.layer.borderWidth = 1
        button.layer.cornerRadius = button.bounds.size.width / 2
        
        // Colors
        button.setTitleColor(ColorName.background.color, for: .normal)
        
        button.layer.borderColor = ColorName.placeholder.color.cgColor
        button.backgroundColor = ColorName.textWhite.color
        
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.numberOfLines = 2
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        button.titleLabel?.textAlignment = .center
    }
}
