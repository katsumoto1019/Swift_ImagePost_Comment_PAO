//
//  GradientView.swift
//  Pao
//
//  Created by Parveen Khatkar on 24/05/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class GradientView: UIView {
    var gradientColors: [UIColor]? {
        didSet {
            gradientLayer.colors = gradientColors?.map({$0.cgColor});
        }
    }
    
    var gradientLocations: [NSNumber]? {
        didSet {
            gradientLayer.locations = gradientLocations;
        }
    }
    
    private let gradientLayer: CAGradientLayer = CAGradientLayer()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize();
    }
    
    private func initialize() {
        self.layer.insertSublayer(gradientLayer, at: 0);
    }
    
    override func layoutSubviews() {
        superview?.layoutSubviews();
        gradientLayer.frame.size = self.frame.size
    }
}
