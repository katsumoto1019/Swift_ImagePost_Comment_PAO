//
//  LocationHeaderView.swift
//  Pao
//
//  Created by OmShanti on 01/12/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

class LocationHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var lblWhatsHappening: UILabel!
    @IBOutlet weak var lblCity: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var leftAlignConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        self.lblWhatsHappening.text = L10n.LocationHeaderView.lblWhatsHappening
        self.lblWhatsHappening.font = UIFont.appMedium.withSize(UIFont.sizes.headerTitle)
        self.lblCity.font = UIFont.appHeavy.withSize(UIFont.sizes.small)
        self.lblCity.textColor = ColorName.accent.color
        gradientView.gradientColors = [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(1)]
    }
}
