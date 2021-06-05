//
//  EmojiTableViewCell.swift
//  Pao
//
//  Created by Ajay on 05/08/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

class EmojiTableViewCell: UITableViewCell {

    @IBOutlet weak var lblStunning: UILabel!
    @IBOutlet weak var lblMajorHiddenGem: UILabel!
    @IBOutlet weak var lblOmgNeed: UILabel!
    @IBOutlet weak var lblKudos: UILabel!
    @IBOutlet weak var lblHereToo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblStunning.set(fontSize: UIFont.sizes.small);
        lblMajorHiddenGem.set(fontSize: UIFont.sizes.small);
        lblOmgNeed.set(fontSize: UIFont.sizes.small);
        lblKudos.set(fontSize: UIFont.sizes.small);
        lblHereToo.set(fontSize: UIFont.sizes.small);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
