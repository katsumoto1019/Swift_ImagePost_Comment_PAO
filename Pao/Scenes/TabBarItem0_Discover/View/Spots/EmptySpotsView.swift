//
//  EmptySpotsView.swift
//  Pao
//
//  Created by Waseem Ahmed on 19/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class EmptySpotsView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var constraintDotsWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintDotsBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintDotsTop: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyStyle()
        set(title: L10n.EmptySpotsView.title)
        set(subtitle: L10n.EmptySpotsView.subTitle)

        constraintDotsWidth.constant = UIScreen.main.bounds.width - 56
        constraintDotsTop.constant = 20 + 20 //20: time label height
        constraintDotsBottom.constant = 110
     
        updateConstraints()
        layoutIfNeeded()
    }
    
    func applyStyle() {
        backgroundColor = UIColor.clear
        containerView.backgroundColor = backgroundColor
        
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.appMedium.withSize(UIFont.sizes.popUpTitle)
        subtitleLabel.font = UIFont.appMedium.withSize(UIFont.sizes.large)
    }
    
    func set(title:String) {
        titleLabel.text = title
    }
    
    func set(subtitle: String) {
        subtitleLabel.text = subtitle
        subtitleLabel.setLineSpacing(lineSpacing: 6.0)
        subtitleLabel.textAlignment = .center
    }
}
