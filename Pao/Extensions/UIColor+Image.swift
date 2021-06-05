//
//  UIColor+Image.swift
//  Pao
//
//  Created by Podkladov Anatoliy Olegovich on 18.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit


extension UIColor {
    func image(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}
