//
//  BoardSlideDataSource.swift
//  Pao
//
//  Created by OmShanti on 10/09/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

class BoardSlideDataSource: NSObject, UICollectionViewDataSource {
    
    //Timer used to scroll collectionView with specific timeinterval without userintraction
     var scrollTimer: Timer?
        
    lazy var images:[String] = {
        var list: [String] = [String]()
        for index in 0..<21 {
           list.append("location\(index + 1)")
        }
        return list
    }()
    
    lazy var collectionLayout = {
        return MyCollectionLayout(delegate:self)
    }()
    
    lazy var itemSize: CGSize = {
        let columns: CGFloat = 3 // Number of columns in a row
        let spacing: CGFloat = 1 // inter space between cell
        let cellWidth = (UIScreen.main.bounds.width - spacing * columns-3) / columns
        return CGSize(width: cellWidth, height: cellWidth)
        
    }()
    
    func attatch(to collectionView: UICollectionView) {
        collectionView.register(BoardCollectionViewCell.self)
        collectionView.dataSource = self
        reload()
    }
    
    func reload() {
        collectionLayout.collectionView?.reloadData()
        startAutoScroll()
    }
    
    func startAutoScroll() {
        scrollTimer?.invalidate()
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) {[weak self] (timer) in
            guard let self = self else { timer.invalidate(); return}
            if let collectionView = self.collectionLayout.collectionView {
                let offset = collectionView.contentOffset
                if (offset.y - collectionView.bounds.height) <= 0 {
                    collectionView.contentOffset =  CGPoint.init(x: 0, y: collectionView.contentSize.height - collectionView.bounds.height)
                } else {
                    collectionView.contentOffset =  CGPoint.init(x: offset.x, y: offset.y - 0.6)
                }
            }
        }
    }
    
    //Mark - collectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 150
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCollectionViewCell.reuseIdentifier, for: indexPath) as! BoardCollectionViewCell
        cell.thumbnailImageView.image = UIImage(named: images[indexPath.row % images.count])
        cell.titleLabel.text = "" //locations[indexPath.row % locations.count]
        cell.gradientView.isHidden = true
        return cell
    }
}

//Mark - MyLayoutDelegate
extension BoardSlideDataSource: MyLayoutDelegate {
    func padding(_ collectionView: UICollectionView) -> CGFloat {
        return 0
    }
    
    func numberofColumns(_ collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return itemSize.height
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return itemSize.width
    }
}

class MyCollectionLayout: UICollectionViewLayout {
    
    private let defaultItemSize = CGSize.init(width: 80, height: 80)
    
    weak var delegate: MyLayoutDelegate?
    
    init(delegate: MyLayoutDelegate) {
        super.init()
        
        self.delegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var cacheAttr = [UICollectionViewLayoutAttributes]()
    var contentSize = CGSize.zero
    
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var contentWidth: CGFloat = 0
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard cacheAttr.isEmpty == true, let collectionView = collectionView  else {
            return
        }
        //Following background thread is because it was causing to freez the screen for a while. so to make it smooth.
        let items = collectionView.numberOfItems(inSection: 0)
        DispatchQueue.global(qos: .background).async {
            self.initialize(numberOfItems: items)
            
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
                self.collectionView?.scrollToItem(at: IndexPath(item: items - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    private func initialize(numberOfItems: Int) {
        
        guard cacheAttr.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        let numberOfColumns = delegate?.numberofColumns(collectionView) ?? 3
        let cellPadding:CGFloat = 1
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        var xOffset:CGFloat = 0
        
        for item in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let itemWidth = delegate?.collectionView(collectionView, widthForPhotoAtIndexPath: indexPath) ?? defaultItemSize.width
            let itemHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath) ?? defaultItemSize.height
            
            let height:CGFloat = cellPadding * 2 + CGFloat(itemHeight)
            let width:CGFloat = cellPadding * 2 + CGFloat(itemWidth)
            let origin = getOrigin(forXoffset: xOffset, yOffset: yOffset[column], index: item, width: itemWidth)
            let frame = CGRect(x: origin.x, y: origin.y, width: width, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cacheAttr.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            contentWidth = max(contentWidth, frame.maxX)
            yOffset[column] = yOffset[column] + height
            xOffset = frame.maxX
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
            xOffset = column == 0 ? 0 : xOffset
        }
    }
    
    private func getOrigin(forXoffset xOffset: CGFloat, yOffset: CGFloat, index: Int, width: CGFloat) -> CGPoint {
        var point = CGPoint(x: xOffset, y: yOffset)
        let marginVertical:CGFloat = 0
        let marginHorizontal:CGFloat = 0
        point.x -= marginHorizontal
        point.y += marginVertical
        return point
    }
 
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for (attributes) in cacheAttr {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cacheAttr[indexPath.row]
    }
}

protocol MyLayoutDelegate: class {
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
    func collectionView(_ collectionView:UICollectionView, widthForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
    func numberofColumns(_ collectionView:UICollectionView) -> Int
}
