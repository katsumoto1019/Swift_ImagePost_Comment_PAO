//
//  UnderlineTextField.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class UnderlineTextField: UITextField {
   
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
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        initialize();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        initialize();
    }
    
    private func initialize() {
        style();
    }
    
    private func style() {
        self.textAlignment = .center;
        self.textColor = UIColor.white;
        self.set(placeholderColor: ColorName.placeholder.color)
        
        self.borderStyle = .none;
        
        NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 48).isActive = true;
    }
}
