//
//  CGFloatExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
        }
    }
