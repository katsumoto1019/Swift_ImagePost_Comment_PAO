//
//  GoAboutTableViewCell.swift
//  Pao
//
//  Created by Waseem Ahmed on 03/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class GoAboutTableViewCell: GoBaseTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        setupLabels();
    }
    
    private func setupLabels() {
        titleLabel.textColor = ColorName.textWhite.color
        titleLabel.font = UIFont.app;
    }
    
    override func set(spot: Spot, placeDetails: PlaceDetailsResult?) {
         titleLabel.text = spot.location?.about;
    }
}
