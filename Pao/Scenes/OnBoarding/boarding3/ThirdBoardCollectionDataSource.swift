//
//  ThirdBoardCollectionDataSource.swift
//  Pao
//
//  Created by Waseem Ahmed on 16/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class ThirdBoardCollectionDataSource: NSObject, UICollectionViewDataSource {
    
    //Timer used to scroll collectionView with specific timeinterval without userintraction
     var scrollTimer: Timer?
        
    lazy var images:[String] = {
        var list = [String]()
        for index in 0..<27 {
           list.append("people\(index + 1)")
        }
        return list
    }()
    
    lazy var collectionLayout = {
        return MultiDimentionCollectionLayout(delegate:self)
    }()
    
    lazy var itemSize: CGSize = {
        let width = (UIScreen.main.bounds.width / 3.5) - 4 * 3
        return CGSize.init(width: width, height: width)
    }()
    
    func attatch(to collectionView: UICollectionView) {
        collectionView.register(ThirdBoardCollectionViewCell.self)
        collectionView.dataSource = self
    }
    
    func reload() {
        collectionLayout.collectionView?.reloadData()
        startAutoScroll()
    }
    
    func startAutoScroll() {
        scrollTimer?.invalidate()
        scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) {[weak self] (timer) in
            guard let self = self else { timer.invalidate(); return}
            if let collectionView = self.collectionLayout.collectionView, let offset =  self.collectionLayout.collectionView?.contentOffset {
                if (offset.x + collectionView.bounds.width) > collectionView.contentSize.width || (offset.y + collectionView.bounds.height) > collectionView.contentSize.height {
                    self.collectionLayout.collectionView?.contentOffset =  CGPoint.init(x: 0, y: 0)
                }else {
                self.collectionLayout.collectionView?.contentOffset =  CGPoint.init(x: offset.x + 0.6, y: offset.y + 0.6)
                }
            }
        }
    }
    
    //Mark - collectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 500
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThirdBoardCollectionViewCell.reuseIdentifier, for: indexPath) as! ThirdBoardCollectionViewCell
        cell.set(image: UIImage(named: images[indexPath.row % images.count]))
        return cell
    }
}

//Mark - MultiDimentionalLayoutDelegate
extension ThirdBoardCollectionDataSource: MultiDimentionalLayoutDelegate {
    func padding(_ collectionView: UICollectionView) -> CGFloat {
        return 8
    }
    
    func numberofColumns(_ collectionView: UICollectionView) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return itemSize.height
    }
    
    func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return itemSize.width
    }
}

class MultiDimentionCollectionLayout: UICollectionViewLayout {
    
    private let defaultItemSize = CGSize.init(width: 80, height: 80)
    
    weak var delegate: MultiDimentionalLayoutDelegate?
    
    init(delegate: MultiDimentionalLayoutDelegate) {
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
            }
        }
    }
    
    private func initialize(numberOfItems: Int) {
        
        guard cacheAttr.isEmpty == true, let collectionView = collectionView else {
            return
        }
        
        let numberOfColumns = delegate?.numberofColumns(collectionView) ?? 5
        let cellPadding:CGFloat = 8
        
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        var xOffset:CGFloat = 0
        
//        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
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
        let marginVertical:CGFloat = CGFloat(index % 2) * (width / 2)
        let marginHorizontal:CGFloat = CGFloat((index % 2) * 4)
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

protocol MultiDimentionalLayoutDelegate: class {
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
    func collectionView(_ collectionView:UICollectionView, widthForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
    func numberofColumns(_ collectionView:UICollectionView) -> Int
}
