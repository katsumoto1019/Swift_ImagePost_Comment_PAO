//
//  EditProfileTagsTableViewCell.swift
//  Pao
//
//  Created by Exelia Technologies on 06/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class EditProfileTagsTableViewCell: UITableViewCell {
    @IBOutlet weak var addTagCollectionView: AddTagCollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        self.addTagCollectionView.collectionViewLayout = CollectionViewLeftAlignFlowLayout()
        self.addTagCollectionView.isScrollEnabled = true;
    }
    override func layoutSubviews() {
        super.layoutSubviews();
        
        let edgeInsets = UIEdgeInsets(top: 0, left: contentView.layoutMargins.left, bottom: 0, right: contentView.layoutMargins.right);
        contentView.frame.inset(by: edgeInsets);
        
//        addTagCollectionView.contentInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 4, right: 8);
    }
    
    func set(tags: [String], isCurrentUser: Bool = true, plusButtonTouchedInside: @escaping () -> Void) {
        addTagCollectionView.isCurrentUser = isCurrentUser;
        addTagCollectionView.tags = NSMutableArray.init(array: tags);
        addTagCollectionView.plusButtonTouchedInside = plusButtonTouchedInside;
        
        self.addTagCollectionView.layoutIfNeeded();
        self.contentView.layoutIfNeeded();
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        addTagCollectionView.frame = CGRect.init(x: 0, y: 0, width: targetSize.width - 32, height:   10000);
//        self.addTagCollectionView.layoutIfNeeded();
        return self.addTagCollectionView.collectionViewLayout.collectionViewContentSize;
    }
}
