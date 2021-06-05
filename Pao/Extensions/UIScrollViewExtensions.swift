//
//  UIScrollViewExtensions.swift
//  Pao
//
//  Created by Exelia Technologies on 31/08/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    var xPosition: CGFloat {
        return contentOffset.x - contentInset.left;
    }
    
    func scrollToLeft(animated: Bool, withDuration: TimeInterval, completion: ((Bool) -> Swift.Void)? = nil) {
        let leftOffset = CGPoint(x: -12.0, y: contentOffset.y);
        scrollToOffset(contentOffset: leftOffset, animated: animated, withDuration: withDuration, completion: completion);
    }
    
    private func scrollToOffset(contentOffset: CGPoint, animated: Bool, withDuration: TimeInterval, completion: ((Bool) -> Swift.Void)?) {
        if (!animated) {
            setContentOffset(contentOffset, animated: false);
            return;
        }
        
        UIView.animate(withDuration: withDuration, animations: {
            self.setContentOffset(contentOffset, animated: false);
        }, completion: completion);
    }
}
