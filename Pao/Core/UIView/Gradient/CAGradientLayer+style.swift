//
//  CAGradientLayer+style.swift
//  Pao
//
//  Created by Podkladov Anatoliy Olegovich on 20.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

extension CAGradientLayer {
    static func buttonGradient(style: ApplicationStyle) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.contentsScale = UIScreen.main.scale
        gradient.colors = GradientColors.colorsForSyle(style)
        gradient.startPoint = CGPoint(x: -0.2, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        return gradient
    }
    
    static func horizontalGradient(style: ApplicationStyle) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.contentsScale = UIScreen.main.scale
        gradient.colors = GradientColors.colorsForSyle(style)
        gradient.startPoint = CGPoint(x: -0.2, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        return gradient
    }
    
    static func verticalGradient(style: ApplicationStyle) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        gradient.contentsScale = UIScreen.main.scale
        gradient.colors = GradientColors.colorsForSyle(style)
        gradient.locations = [0.3, 1.1]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        
        return gradient
    }

	static func customDirectionGradient(
		style: ApplicationStyle,
		startPoint: CGPoint = .init(x: 0, y: 0),
		endPoint: CGPoint = .init(x: 0, y: 1),
		locations: [NSNumber] = [0, 1]) -> CAGradientLayer {

        let gradient = CAGradientLayer()
        gradient.contentsScale = UIScreen.main.scale
        gradient.colors = GradientColors.colorsForSyle(style)
        gradient.locations = locations
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint

        return gradient
    }
}
