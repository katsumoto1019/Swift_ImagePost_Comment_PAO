//
//  RoundCornerButton.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class RoundCornerButton: UIButton {
    var cornerRadius: CGFloat! {
        didSet {
            layer.cornerRadius = cornerRadius;
        }
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
        cornerRadius = 5;
    }
}
