//
//  BoardingSpotsViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 20/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//
import UIKit
import Payload


class OnBoardingSpotsViewController: SpotCollectionViewController {
    
    var spots : [Spot]!
    var currentSpot : Spot!
    
    var spotTimer: Timer?
    var mediaTimer: Timer?
    
    var mediaItemIndex = 0
    var animationInterval = TimeInterval(0.7)
    var animationBreakInterval = TimeInterval(1)
    
    init(spots: [Spot]) {
        super.init()
        
        self.spots = spots
        
        if(self.spots.count > 0){
            currentSpot = self.spots[0]
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {        
        super.viewDidLoad()
        
        if let carouselFlowLayout = collectionView?.collectionViewLayout as? UPCarouselFlowLayout {
            carouselFlowLayout.itemSize.width = (UIScreen.main.bounds.width * 0.90) - 56
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centerSpinnerView?.stopAnimating()
        stopAnimations()
        startAnimations()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Invalidate these timers are important else these will cause memory leak and will keep viewController in memory.
        stopAnimations()
    }
    
    override func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        completionHandler(spots)
        return nil
    }
}

//Mark - animations
extension OnBoardingSpotsViewController {
    func startAnimations() {
        
        if (spots.count > 0){
            currentSpot = spots[0]
        }
        
        self.scrollTo(indexPath: IndexPath.init(row: 0, section: 0), animated: false)
        spotTimer = Timer.scheduledTimer(withTimeInterval: animationBreakInterval + animationInterval, repeats: true, block: { [weak self](timer) in
            /*
             UIView.animate(withDuration: self.animationInterval, animations: {
             self.scrollTo(indexPath: self.nextIndex, animated: false)
             }, completion: { (status) in
             self.currentSpot = self.spots[self.nextIndex.row]
             timer.fireDate = timer.fireDate.addingTimeInterval(TimeInterval(self.animateMedia()))
             })*/
            guard let self = self else { timer.invalidate(); return}
            
            self.scrollTo(indexPath: self.nextIndex, animated: true)
            self.currentSpot = self.spots![(self.nextIndex.row)]
            timer.fireDate = timer.fireDate.addingTimeInterval(TimeInterval((self.animateMedia())))
        })
    }
    
    func stopAnimations() {
        spotTimer?.invalidate()
        mediaTimer?.invalidate()
    }
    
    func animateMedia() -> Double {
        
        guard let mediaCount = self.currentSpot?.mediaCount, mediaCount > 1 else {
            return animationBreakInterval + animationInterval
        }
        
        mediaItemIndex = 0
        self.scrollMediaToIndex(index: 0, animate: false)
        
        mediaTimer = Timer.scheduledTimer(withTimeInterval: animationBreakInterval + animationInterval, repeats: true, block: {[weak self] (timer) in
            guard let self = self else { timer.invalidate(); return}
            
            self.mediaItemIndex = self.mediaItemIndex + 1
            guard self.mediaItemIndex < self.currentSpot.mediaCount! else {
                timer.invalidate()
                return
            }
            self.scrollMediaToIndex(index: self.mediaItemIndex, animate: true)
        })
        
        return Double(mediaCount) * (animationBreakInterval + animationInterval)
    }
    
    func scrollMediaToIndex(index: Int, animate: Bool = true) {
        /*  UIView.animate(withDuration:  animate ? self.animationInterval : 0, animations: { [unowned self] in
         (self.collectionView?.cellForItem(at: self.currentIndex) as! SpotCollectionViewCell).imageCollectionViewController.collectionView?.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredVertically, animated: false)
         })
         */
        
        (self.collectionView?.cellForItem(at: self.currentIndex) as? SpotCollectionViewCell)?.imageCollectionViewController.collectionView?.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredVertically, animated: animate)
        
        //        (self.collectionView?.cellForItem(at: self.currentIndex) as! SpotCollectionViewCell).imageCollectionViewController.collectionView?.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredVertically, animated: animate)
    }
    
    var currentIndex:IndexPath {
        return IndexPath.init(row: self.spots.firstIndex(of: self.currentSpot)!, section: 0)
    }
    
    var nextIndex:IndexPath {
        return IndexPath.init(row: (self.spots.firstIndex(of: self.currentSpot)! + 1) % self.spots.count, section: 0)
    }
}
