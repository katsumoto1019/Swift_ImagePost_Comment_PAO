//
//  CoachMarkOverlayView.swift
//  Pao
//
//  Created by Waseem Ahmed on 25/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Instructions

// Custom coach mark body (with the finger tip icon)
class CoachMarkOverlayView: UIView, CoachMarkBodyView {
    
    var nextControl: UIControl?
    
    var highlighted: Bool = false
    
    var hintLabel = UITextView()
    
    var iconImageView = UIImageView()
    
    weak var highlightArrowDelegate: CoachMarkBodyHighlightArrowDelegate? = nil
    
    var clickedCallback :(() -> Void)?
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    // MARK: - Initialization
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        applyStyles();
        setupInnerViewHierarchy()
        constraints();
        drawDashedBorder(color: ColorName.accent.color)
        
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapHandler(gesture:))))
    }
    
        // MARK: - Private methods
    fileprivate func applyStyles(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = ColorName.background.color.withAlphaComponent(0.6)
        
        self.clipsToBounds = true
        
        self.hintLabel.backgroundColor = .clear
        self.hintLabel.textColor = ColorName.accent.color
        self.hintLabel.font = UIFont.app.withSize(15.0)
        self.hintLabel.isScrollEnabled = false
        self.hintLabel.textAlignment = .center
        self.hintLabel.layoutManager.hyphenationFactor = 1.0
        self.hintLabel.isEditable = false
        
        self.hintLabel.translatesAutoresizingMaskIntoConstraints = false
        self.hintLabel.isUserInteractionEnabled = false
        
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
    }

    fileprivate func setupInnerViewHierarchy() {
        self.addSubview(iconImageView)
        self.addSubview(hintLabel)
      }
    
    fileprivate func constraints () {
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: frame.width + 20),
            heightAnchor.constraint(equalToConstant: frame.height),
            iconImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20),
            hintLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            hintLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8)
            ])
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[hintLabel]-(20)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0),metrics: nil, views: ["hintLabel": hintLabel]))
    }
    
    @objc func tapHandler(gesture: UITapGestureRecognizer) {
        clickedCallback?()
    }
}
