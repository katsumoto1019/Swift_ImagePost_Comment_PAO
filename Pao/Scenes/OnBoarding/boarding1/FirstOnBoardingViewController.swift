//
//  FirstBoardingViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 20/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import Instructions

class FirstOnBoardingViewController: SwipeMenuViewController {

    var spots: [Spot]!
    
     init(spots: [Spot]) {
         super.init(nibName: nil, bundle: nil);
        
        self.spots = spots;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    var viewControllers = [UIViewController]();
    
    let titles = [
        L10n.Common.titleYourPeople,
        L10n.Common.titleTheWorld
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildControllers();
        setupSwipe();
        
        swipeMenuView.jump(to: 1, animated: false);
    }
   
    private func setupSwipe() {
        var options = SwipeMenuViewOptions();
        options.tabView.style = .segmented;
        options.tabView.additionView.backgroundColor = UIColor.white;
        options.tabView.backgroundColor = ColorName.navigationBarTint.color
        options.tabView.itemView.selectedTextColor = .white
        
        options.contentScrollView.isScrollEnabled = false;
        
        swipeMenuView.reloadData(options: options);
    }
    
    private func setupChildControllers() {
        viewControllers = [UIViewController(), OnBoardingSpotsViewController(spots: spots)];
        
        viewControllers.forEach({
            addChild($0);
            $0.didMove(toParent: self);
        })
    }
    
    // MARK - SwipeMenuViewDataSource
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return viewControllers.count;
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return titles[index];
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        return viewControllers[index]
    }
    
    
}
