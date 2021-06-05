//
//  NumericExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 25/07/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import UIKit
// TODO: This should work, don't know why it isn't working, meanwhile moving on with below dup implements.
//extension Comparable where Self: Numeric {
//    func clamped<T: Numeric & Comparable>(max: T) -> T {
//        return self <= max ? self : max;
//    }
//    
//    func clamped<T: Numeric & Comparable>(min: T) -> T {
//        return self >= min ? self : min;
//    }
//}


extension CGFloat {
    func clamped(max: CGFloat) -> CGFloat {
        return self <= max ? self : max;
    }
    
    func clamped(min: CGFloat) -> CGFloat {
        return self >= min ? self : min;
    }
}

extension Int {
    func clamped(max: Int) -> Int {
        return self <= max ? self : max;
    }
    
    func clamped(min: Int) -> Int {
        return self >= min ? self : min;
    }
    
    func clamped(min: Int, max: Int) -> Int {
        return self.clamped(min: min).clamped(max: max);
    }

    var abbreviated: String {
        let abbrev = "KMBTPE"
        return abbrev.enumerated().reversed().reduce(nil as String?) { accum, tuple in
            let factor = Double(self) / pow(10, Double(tuple.0 + 1) * 3)
            let format = (factor.truncatingRemainder(dividingBy: 1)  == 0 ? "%.0f%@" : "%.1f%@")
            return accum ?? (factor > 1 ? String(format: format, factor, String(tuple.1)) : nil)
            } ?? String(self)
    }
}
