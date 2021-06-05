//
//  UnderlineLabel.swift
//  Pao
//
//  Created by Parveen Khatkar on 08/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class UnderlineLabel: UILabel {

    override func draw(_ rect: CGRect) {
        super.draw(rect);
        let startingPoint   = CGPoint(x: rect.minX, y: rect.maxY)
        let endingPoint     = CGPoint(x: rect.maxX, y: rect.maxY)
        
        let path = UIBezierPath()
        
        path.move(to: startingPoint)
        path.addLine(to: endingPoint)
        path.lineWidth = 2.0
        
        UIColor.white.setStroke()
        
        path.stroke()
    }
}
