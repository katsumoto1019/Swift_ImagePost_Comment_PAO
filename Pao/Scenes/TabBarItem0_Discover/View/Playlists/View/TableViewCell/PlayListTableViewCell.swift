//
//  PlayListTableViewCell.swift
//  Pao
//
//  Created by OmShanti on 24/02/21.
//  Copyright © 2021 Exelia. All rights reserved.
//

import UIKit
import Payload

class PlayListTableViewCell: UITableViewCell, Consignee {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }
    
    // MARK: - Internal methods

    func set(_ playlist: PlayList) {
        layoutIfNeeded()
    }
    
    // MARK: - Private methods
    
    private func applyStyle() {
        backgroundColor = .clear
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        titleLabel.textColor = .white
        titleLabel.font = UIFont.appHeavy.withSize(UIFont.sizes.sectionTitle)
    }
    
}
