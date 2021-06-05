//
//  UISearchBar+Extensions.swift
//  Pao
//
//  Created by Rybolovleva Olga Viktorovna on 28.06.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

extension UISearchBar {

    private var textField: UITextField? {
        let subViews = subviews.flatMap { $0.subviews }
        return (subViews.filter { $0 is UITextField }).first as? UITextField
    }

    func setTextFieldBorder(
        width: CGFloat = 0.5,
        color: UIColor = ColorName.grayBorder.color,
        cornerRadius: CGFloat = 16) {
        if #available(iOS 13.0, *) {
            self.searchTextField.layer.borderWidth = width
            self.searchTextField.layer.borderColor = color.cgColor
            self.searchTextField.layer.cornerRadius = cornerRadius
        } else {
            self.textField?.layer.borderWidth = width
            self.textField?.layer.borderColor = color.cgColor
            self.textField?.layer.cornerRadius = cornerRadius
        }
    }
}
