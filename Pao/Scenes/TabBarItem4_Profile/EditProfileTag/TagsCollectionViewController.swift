//
//  ProfileEditTagsCollectionViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 23/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class TagsCollectionViewController: UICollectionViewController {
    
    var tags: NSMutableArray = []
    
    init(tags: NSMutableArray, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout);
        
        self.tags = tags;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func loadView() {
        super.loadView();
        
        self.collectionView = EditTagCollectionView(frame: CGRect.zero, collectionViewLayout: self.collectionViewLayout);
        self.view = self.collectionView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.contentInset = UIEdgeInsets.init(top: 0, left: 20, bottom: 0, right: 20);

        (self.collectionView as! EditTagCollectionView).tags = self.tags;

        self.collectionView.becomeFirstResponder()
        collectionView.keyboardDismissMode = .interactive;
    }
    
    func append(tag: String) {
        (self.collectionView as! EditTagCollectionView).append(tag: tag);
    }

    func remove(tag: String) {
        (self.collectionView as! EditTagCollectionView).remove(tag: tag);
    }
}
