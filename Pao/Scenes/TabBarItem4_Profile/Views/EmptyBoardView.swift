//
//  EmptyUpdateView.swift
//  Pao
//
//  Created by Waseem Ahmed on 19/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class EmptyBoardView: UIView {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = UIColor.clear;
        
        imageView.contentMode = .scaleAspectFit;
        messageLabel.numberOfLines = 0;
        messageLabel.textColor = UIColor.white;
        messageLabel.font = UIFont.app;
    }
    func set(labelMessage: NSAttributedString, image: UIImage?){
        messageLabel.attributedText = labelMessage;
        imageView.image = image;
    }
    
}
