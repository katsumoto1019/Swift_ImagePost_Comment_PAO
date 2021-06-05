//
//  TagCollectionViewCell.swift
//  Pao
//
//  Created by Exelia Technologies on 05/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tagLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        layer.cornerRadius = 7.5;
        backgroundColor = UIColor.white.withAlphaComponent(0.05);
    }
    
    func set(tag: String) {
        tagLabel.text = tag;
        self.contentView.setNeedsLayout();
    }
}
