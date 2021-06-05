//
//  GlobalPlayListHeaderCollectionViewCell.swift
//  Pao
//
//  Created by MACBOOK PRO on 07/10/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit

class GlobalPlayListHeaderCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var labelHead: UILabel!
    @IBOutlet weak var labelSubHeading: UILabel!
    
    // MARK: - Lifecycle

    override func layoutSubviews() {
        setupLabels()
    }
    
    // MARK: - Private methods
    
    private func setupLabels() {
        labelHead.font = UIFont.appBold.withSize(UIFont.sizes.large)
        labelHead.text = L10n.GlobalPlayListHeaderCollectionViewCell.title
        
        labelSubHeading.font = UIFont.appNormal.withSize(UIFont.sizes.small)
        labelSubHeading.text = L10n.GlobalPlayListHeaderCollectionViewCell.subTitle
    }
}
