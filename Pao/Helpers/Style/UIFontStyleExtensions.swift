//
//  UIFontStyleExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/21/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

extension UIFont {
    static var app: UIFont { return UIFont(name: "Avenir-Light", size: 13)! }
    static var appNormal: UIFont { return UIFont(name: "Avenir", size: 13)! }
    static var appLight: UIFont { return UIFont(name: "Avenir-Light", size: 13)! }
    static var appMedium: UIFont { return UIFont(name: "Avenir-Medium", size: 13)! }
    static var appHeavy: UIFont { return UIFont(name: "Avenir-Heavy", size: 13)! }
    static var appOblique: UIFont { return UIFont(name: "Avenir-LightOblique", size: 13)! }
    static var appBold: UIFont { return UIFont(name: "Avenir-Black", size: 13)!}
    static var appBook: UIFont { return UIFont(name: "Avenir-Book", size: 19)!}

    
    class sizes {
        
        static let tiny: CGFloat = 10
        static let verySmall: CGFloat = 12
        static let small: CGFloat = 15
        static let sectionTitle: CGFloat = 16.5
        static let normal: CGFloat = 17
        static let medium: CGFloat = 18
        static let large: CGFloat = 20
        static let headerTitle: CGFloat = 22
        static let popUpTitle: CGFloat = 28
        static let veryLarge: CGFloat = 30
        static let huge: CGFloat = 40
        
        static let tabBarItem: CGFloat = 12
        static let barButtonItem: CGFloat = 17
    }
}
