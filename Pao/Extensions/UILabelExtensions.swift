//
//  UILabelExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/23/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    convenience init(text: String?, font: UIFont? = UIFont.app, color: UIColor? = .white, textAlignment: NSTextAlignment? = .natural) {
        self.init()
        
        self.font = font
        self.text = text
        self.textColor = color
        self.numberOfLines = 0
        self.textAlignment = textAlignment != nil ? textAlignment! : .natural
    }
}
