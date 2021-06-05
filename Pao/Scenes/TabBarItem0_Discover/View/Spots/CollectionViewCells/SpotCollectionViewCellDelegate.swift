//
//  SpotCollectionViewCellDelegate.swift
//  Pao
//
//  Created by kant on 19.04.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

protocol SpotCollectionViewCellDelegate: class {
    func showProfile(user: User?)
    func showGo(spot: Spot)
    func edit(spot: Spot)
	
    func spotDataDidUpdate(updatedSpot: Spot)

	func showEmojies(emojies: [Emoji: EmojiItem], selectedEmojies: Emoji?, savedBy: [User])

    func showComments(spot: Spot?)
    
    func deleteUploadingSpot(spot: Spot)
    
    func retryUpload(spot: Spot)
    
    func didSelect(indexPath: IndexPath)

    func cellWillDisplay(indexPath: IndexPath, cell: UICollectionViewCell)
}

extension SpotCollectionViewCellDelegate {
    func didSelect(indexPath: IndexPath) {}
}
