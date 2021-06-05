//
//  ProfileImageView.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/23/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class ProfileImageView: PickerImageView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        setStyle();
    }
    
    func setStyle() {
        self.layer.cornerRadius = self.frame.width / 2;
    }
}

class ProfileImageContainerView: UIView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        setStyle();
    }
    
    func setStyle() {
        self.backgroundColor = UIColor.clear;
        self.addShadow(offset: CGSize.init(width: 0, height: 0), color: UIColor.black, radius: 3.0, opacity: 0.5);
    }
}
