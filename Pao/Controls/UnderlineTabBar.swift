//
//  UnderlineTabBar.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/5/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class UnderlineTabBar: UITabBar {
    
    override func didMoveToSuperview() {
        setStyle()
    }
    
    // MARK: - Private methods
    
    private func setStyle() {
        
        guard let items = items else { return }
        
        // Underline
        let count = items.count
        let itemsCount = CGFloat(count)
        let width = frame.width / itemsCount
        let itemSize = CGSize(width: width, height: frame.height)
        let y = itemSize.height - 5
        let colorFrame = CGRect(x: 0, y: y, width: itemSize.width, height: 5)
        let image = UIImage.imageWithColor(ColorName.background.color, size: itemSize, frame: colorFrame)
        selectionIndicatorImage = image.resizableImage(withCapInsets: .zero)
        
        // Font
        let attributes = [NSAttributedString.Key.font: UIFont.app.withSize(UIFont.sizes.small)]
        for tabBarItem in items {
            tabBarItem.setTitleTextAttributes(attributes, for: UIControl.State())
            tabBarItem.titlePositionAdjustment.vertical = -4
        }
        
        itemPositioning = .centered
        itemSpacing = 10
    }
}
