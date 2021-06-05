//
//  UISegmentedControlExtensions.swift
//  Pao
//
//  Created by Exelia Technologies on 27/06/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import UIKit

extension UISegmentedControl {
    // REF: https://stackoverflow.com/questions/31651983/how-to-remove-border-from-segmented-control
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor!, alpha: 0.0), for: .normal, barMetrics: .default);
        setBackgroundImage(imageWithColor(color: tintColor!), for: .selected, barMetrics: .default);
        
        setDividerImage(imageWithColor(color: UIColor.clear, alpha: 0.0), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default);
    }
    
    private func imageWithColor(color: UIColor, alpha: CGFloat = 1.0) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0);
        
        UIGraphicsBeginImageContext(rect.size);
        
        let context = UIGraphicsGetCurrentContext();
        context!.setFillColor(color.withAlphaComponent(alpha).cgColor);
        context!.fill(rect);
        
        let image = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return image!;
    }
}
