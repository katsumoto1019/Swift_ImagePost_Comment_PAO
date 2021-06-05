//
//  MosaicCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 13/11/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class MosaicCollectionViewController: UICollectionViewController, PinterestLayoutDelegate {
    private var scrollTimer: Timer!;
    private var animator: UIViewPropertyAnimator?

    var shouldAutoScroll = true {
        didSet{
            if shouldAutoScroll == false {
                self.stopAutoScroll();
            } else {
                self.startAutoScroll();
            }
        }
    }
    
    lazy var images:[String] = {
        var list = [String]()
        for index in 0..<45 {
            list.append("login\(index + 1)")
        }
        return list;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        collectionView.register(ImageCollectionViewCell.self);
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
        view.backgroundColor = .black;
        
        let layout = PinterestLayout();
        layout.delegate = self;
        collectionView?.collectionViewLayout = layout;
        collectionView.reloadData();
        startAutoScroll();
        
        //This line is to make collectionView  scroll fluidly rather than dissapear at the top
        self.collectionView.frame = CGRect.init(x: 0, y: -100, width: self.view.frame.size.width, height: self.view.frame.size.height + 100);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated);
        
        stopAutoScroll();
    }
}

//Mark - aniamte auto-scroll
extension MosaicCollectionViewController {
   private func startAutoScroll() {
        animateScroll();
        scrollTimer?.invalidate();
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { [weak self](timer) in
            guard let self = self else { timer.invalidate(); return;}
            if let collectionView = self.collectionView, (collectionView.contentOffset.y + collectionView.bounds.height) > collectionView.contentSize.height {
                self.collectionView?.contentOffset.y = 0.0;
            }
                
            if self.shouldAutoScroll {
                self.animateScroll();
            }
        }
    }
    
   private func stopAutoScroll() {
        animator?.stopAnimation(true);
        scrollTimer?.invalidate();
    }
    
   private func animateScroll() {
        animator = UIViewPropertyAnimator(duration: 4.0, curve: .linear, animations: {
            if self.shouldAutoScroll, let offset = self.collectionView?.contentOffset {
                self.collectionView?.contentOffset.y = offset.y + 40.0;
            }
        })
        animator?.startAnimation()
    }
}

//Mark - CollectionView DataSource
extension MosaicCollectionViewController {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return indexPath.item == 1 ? 70 : 140;
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count * 2;
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell;
        cell.thumbnailImageView.image = UIImage(named: images[indexPath.row % images.count])
        
        return cell
    }
}


protocol PinterestLayoutDelegate: AnyObject {
    // 1. Method to ask the delegate for the height of the image
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    weak var delegate: PinterestLayoutDelegate!
    
    fileprivate var numberOfColumns = 3
    fileprivate var cellPadding: CGFloat = 6
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        // 1. Only calculate once
        guard cache.isEmpty == true, let collectionView = collectionView else {
            return
        }
        // 2. Pre-Calculates the X Offset for every column and adds an array to increment the currently max Y Offset for each column
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        // 3. Iterates through the list of items in the first section
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            // 4. Asks the delegate for the height of the picture and the annotation and calculates the cell frame.
            let photoHeight = delegate.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // 5. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // 6. Updates the collection view content height
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
}

