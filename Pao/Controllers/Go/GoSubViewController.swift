//
//  GoSwipableViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 03/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class GoSubViewController: SwipeMenuViewController {

    private var spot: Spot!
    
    lazy var viewControllers: [UIViewController] = [
        GoSpotInfoTableViewController(style: .grouped, spot: spot),
        GoPhotosCollectionViewController(spot: spot)
    ]
    
    let titles = [L10n.GoSubViewController.spotInfo, L10n.GoSubViewController.photos]
    
    init(spot: Spot) {
        super.init(nibName: nil, bundle: nil);
        
        self.spot = spot;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSwipe();
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        
        view.frame = view.superview!.bounds;
    }
    
    private func setupSwipe(){
        var options = SwipeMenuViewOptions();
        options.tabView.style = .segmented;
        options.tabView.additionView.backgroundColor = UIColor.white;
        options.tabView.backgroundColor = ColorName.navigationBarTint.color
        options.tabView.itemView.selectedTextColor = ColorName.textWhite.color
        options.tabView.itemView.textColor = ColorName.textGray.color
        options.tabView.itemView.font =  UIFont.app.withSize(UIFont.sizes.small);
        swipeMenuView.reloadData(options:options);
        
        viewControllers.forEach({
            addChild($0);
            $0.didMove(toParent: self);
        });
    }
    
// MARK: - SwipeMenuViewDataSource
    
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return titles.count;
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return titles[index];
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        return viewControllers[index];
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        FirbaseAnalytics.logEvent(toIndex == 0 ? .goPageInfo : .goPagePhotos)
        if toIndex == 1 { AmplitudeAnalytics.logEvent(.goPhotoTab, group: .spot) }

    }
}
