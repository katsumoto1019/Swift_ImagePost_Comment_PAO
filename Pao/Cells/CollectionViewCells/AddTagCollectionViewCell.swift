//
//  AddTagCollectionViewCell.swift
//  Pao
//
//  Created by Exelia Technologies on 06/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class AddTagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var plusLabel: UILabel!
    
    private var plusButtonTouchedInside: (() -> Void)?;
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        plusButton.layer.cornerRadius = 7.5;
        plusLabel.set(fontSize: UIFont.sizes.veryLarge);
        plusLabel.text = "+";
        plusLabel.textAlignment = .center
        plusButton.backgroundColor = ColorName.accent.color
        
        let gradient = CAGradientLayer();
        gradient.frame =  CGRect(origin: .zero, size: CGSize(width: 40,height: 30));
        gradient.colors = [ColorName.gradientTop.color.cgColor, ColorName.gradientBottom.color.cgColor]
        gradient.cornerRadius = 5;
        plusButton.layer.insertSublayer(gradient, at: 0);
        plusButton.layer.opacity = 0.82;
    }
    
    func set(plusButtonTouchedInside: (() -> Void)?) {
        self.plusButtonTouchedInside = plusButtonTouchedInside;
    }
    
    @IBAction func plusButtonTouchedInside(_ sender: UIButton) {
        plusButtonTouchedInside?();
        self.contentView.setNeedsLayout();
    }
}
