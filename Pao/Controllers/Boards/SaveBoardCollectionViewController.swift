//
//  SaveBoardCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class SaveBoardCollectionViewController: UploadBoardCollectionViewController {
    
    private var emptyView:UIView = {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center;
        paragraphStyle.lineSpacing = 6;
        
        let attributedText = NSMutableAttributedString(string: L10n.SaveBoardCollectionViewController.emptyViewText)
        attributedText.setAttributes([.paragraphStyle:paragraphStyle,.foregroundColor: UIColor.lightGray,.font: UIFont.app.withSize(UIFont.sizes.normal)], range: NSMakeRange(0, attributedText.length));
        
        let label = UILabel();
        label.numberOfLines = 0;
        label.attributedText = attributedText;
        label.font = UIFont.app.withSize(UIFont.sizes.normal)
        label.textColor = .gray
        return label;
    }()
    
    override func viewDidLoad() {
        searchPlaceholder = L10n.SaveBoardCollectionViewController.searchPlaceholder;
        
        super.viewDidLoad();
        
        if userId == DataContext.cache.user?.id {
            collectionView.backgroundView = emptyView;
        }
    }
    
    override func showNestedBoards(board: Board) {
        let viewController = NestedSaveBoardCollectionViewController(userId: userId, parentBoardId: board.id ?? "")
        self.navigationController?.pushViewController(viewController, animated: true);
    }
    
}
