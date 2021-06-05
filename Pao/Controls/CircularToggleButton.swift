//
//  CircularToggleButton.swift
//  Pao
//
//  Created by Parveen Khatkar on 5/7/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class CircularToggleButton: RoundCornerButton {
    
    weak var delegate: ToggleButtonDelegate?
    var id: String?
    
    override var isSelected: Bool {
        didSet {
            self.layer.removeAllAnimations()
            UIView.animate(withDuration: self.isSelected ? 0.05 : 0.1) {
                self.backgroundColor = self.isSelected ? UIColor.white : self.secondarySelected ? ColorName.accent.color : UIColor.clear
            }
        }
    }
    
     var secondarySelected: Bool = false {
        didSet {
            self.layer.removeAllAnimations()
            UIView.animate(withDuration: self.isSelected ? 0.05 : 0.1) {
                self.backgroundColor = self.isSelected ? UIColor.white : self.secondarySelected ? ColorName.accent.color : UIColor.clear
            }
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
    
    override func layoutSubviews() {
        super.layoutSubviews();
        cornerRadius = bounds.size.width / 2;
    }
    
    private func initialize() {
        titleLabel?.textColor = ColorName.textWhite.color;
        titleLabel?.numberOfLines = 2
        titleLabel?.textAlignment = .center
        setTitleColor(ColorName.textWhite.color, for: .normal)
        setTitleColor(ColorName.textDarkGray.color, for: .selected)
        layer.borderWidth = 1;
        layer.borderColor = UIColor.white.cgColor;
        
        addTarget(self, action: #selector(toggle), for: .touchUpInside);
        addTarget(self, action: #selector(doubleClick), for: .touchDownRepeat);
    }
    
    @objc func toggle() {
        print("single click")
        isSelected = !isSelected;
        delegate?.toggled(self);
    }
    
    @objc func doubleClick() {
        print("double click")
    }
}

protocol ToggleButtonDelegate: class {
    func toggled(_ sender: UIButton);
}
