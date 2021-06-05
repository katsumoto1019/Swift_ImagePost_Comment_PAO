//
//  TagCollectionView.swift
//  Pao
//
//  Created by Exelia Technologies on 06/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import UIKit

class TagCollectionView: UICollectionView {
    private var shouldReload = true;
    var tags: NSMutableArray = [] {
        didSet {
            if (shouldReload) { reloadData(); }
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout);
        initialize();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        initialize();
    }
    
    private func initialize() {
        dataSource = self;
        delegate = self;
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout;
        flowLayout.estimatedItemSize = CGSize(width: 80.0, height: 30.0);
        
        registerCells();
    }
    
    func registerCells() {
        register(TagCollectionViewCell.self);
    }
    
    func append(tag: String) {
        shouldReload = false;
        tags.add(tag);
        shouldReload = true;
        
        insertItems(at: [IndexPath(item: tags.count - 1, section: 0)]);
    }
    
    func remove(tag: String) {
        let tagIndex = tags.index(of: tag);
        shouldReload = false;
        tags.removeObject(at: tagIndex);
        shouldReload = true;
        
        deleteItems(at: [IndexPath(item: tagIndex, section: 0)]);
    }
}

extension TagCollectionView: UICollectionViewDataSource ,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.reuseIdentifier, for: indexPath) as! TagCollectionViewCell;
        cell.set(tag: tags[indexPath.item] as! String);
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,minimumLineSpacingForSectionAt section: Int) -> CGFloat{
        return 10;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard indexPath.row < tags.count else {
            return CGSize.init(width: 80, height: 30);
        }
        return calcualteSize(text: tags[indexPath.row] as! String, maxWidth: self.frame.size.width - 16);
    }
    
}

//Mark - Helper functions for Calculating Size of Item
extension TagCollectionView {
    
     func calcualteSize(text: String, maxWidth: CGFloat) -> CGSize {
        let font = UIFont.app;
        var width = text.widthOfString(usingFont:  UIFont.app) + 24; // 24: padding horizontal
        if(width > maxWidth){
            width = maxWidth;
        }
        var height:CGFloat = heightForLabel(text: text, font: font, width: width)
        height = height  + 16; //16: padding vertical
        if height < 30 {
            height = 30;
        }
        
        return  CGSize.init(width: width, height: height);
    }
    
  private  func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel.init(frame: CGRect.init(x:0, y:0, width:width, height:9999))
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font;label.text = text;
        
        label.sizeToFit()
        return label.frame.height
    }
}
