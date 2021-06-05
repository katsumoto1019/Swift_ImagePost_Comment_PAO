//
//  UITextViewExtentions.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/23/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
// FIXME: Solution to this problem?
extension UITextView {
    func set(fontSize: CGFloat) {
        font = font?.withSize(fontSize)
    }
    
    func hasReturnPressed(newText:String) -> Bool {
     if (newText as NSString).rangeOfCharacter(from: CharacterSet.newlines, options: .backwards).location != NSNotFound {
        return true
    }
        return false
    }
}

extension UITextField {
    func set(fontSize: CGFloat) {
        font = font?.withSize(fontSize)
    }
}

extension UILabel {
    func set(fontSize: CGFloat) {
        font = font?.withSize(fontSize)
    }
}

extension UITextField {
    func set(placeholderColor: UIColor) {
        // HACK: Private api
        if #available(iOS 13.0, *), let placeholder = placeholder {
            let placeHolderMutableString = NSMutableAttributedString(string: placeholder)
            placeHolderMutableString.addAttribute(
                .foregroundColor,
                value: placeholderColor,
                range: NSRange(location:0, length: placeholder.count))
            attributedPlaceholder = placeHolderMutableString
        }
        else {
            self.setValue(placeholderColor, forKeyPath: "_placeholderLabel.textColor")
        }
    }
}
