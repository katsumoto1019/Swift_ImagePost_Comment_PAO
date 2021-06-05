//
//  LabelTableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 17/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class LabelTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.set(fontSize: UIFont.sizes.small);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(title: String?) {
        titleLabel.text = title;
    }
    
    func underline() {
        titleLabel.attributedText = NSAttributedString(string: titleLabel.text!, attributes:
            [.underlineStyle: NSUnderlineStyle.single.rawValue]);
    }
}
