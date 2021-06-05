//
//  UIImageExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/5/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageWithColor(_ color: UIColor, size: CGSize, frame: CGRect) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(frame)
        let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return image
    }
    
    func image(withAlpha alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

	func resize(for size: CGSize) -> UIImage? {
		let renderer = UIGraphicsImageRenderer(size: size)
		return renderer.image { (context) in
			self.draw(in: CGRect(origin: .zero, size: size))
		}
	}
}
