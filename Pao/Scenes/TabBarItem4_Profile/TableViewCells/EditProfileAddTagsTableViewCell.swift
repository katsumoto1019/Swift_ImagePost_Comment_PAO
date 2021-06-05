//
//  EditProfileAddTagsTableViewCell.swift
//  Pao
//
//  Created by Exelia Technologies on 06/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class EditProfileAddTagsTableViewCell: UITableViewCell {
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var instructionsLabel: UILabel!

    private var plusButtonTouchedInside: (() -> Void)?;
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        let edgeInsets = UIEdgeInsets(top: 0, left: contentView.layoutMargins.left, bottom: 0, right: contentView.layoutMargins.right);
        contentView.frame.inset(by: edgeInsets);
    }
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        plusLabel.textAlignment = .center
        plusLabel.contentMode = .center;
        plusLabel.text = "+"
        plusLabel.set(fontSize: UIFont.sizes.veryLarge);
        plusLabel.backgroundColor = UIColor.clear;

        //plusButton.backgroundColor = ColorName.accent.color;
        plusButton.backgroundColor = ColorName.accent.color;
        plusButton.makeCornerRound(cornerRadius: 5.0);
        
        let gradient = CAGradientLayer();
        gradient.frame =  CGRect(origin: .zero, size: plusButton.frame.size);
        gradient.colors = [ColorName.gradientTop.color.cgColor, ColorName.gradientBottom.color.cgColor];
        gradient.cornerRadius = 5;
        plusButton.layer.insertSublayer(gradient, at: 0);
        plusButton.layer.opacity = 0.82;
        
        instructionsLabel.textColor = UIColor.lightGray;
        instructionsLabel.text = L10n.EditProfileAddTagsTableViewCell.instructionsLabel;
    }
    
    func set(plusButtonTouchedInside: @escaping () -> Void) {
        self.plusButtonTouchedInside = plusButtonTouchedInside;
    }
    
    @IBAction func plusButtonTouchedInside(_ sender: UIButton) {
        plusButtonTouchedInside?();
    }
}
