//
//  ProfileCounterViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 13/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class ProfileCounterViewController:  SwipeMenuViewController {
    
    var viewControllers: [UITableViewController]!
    var userID: String!
    lazy var titles = [
        DataContext.cache.user.id == userID ? L10n.Common.titleYourPeople : L10n.Common.titleTheirPeople,
        L10n.Common.titleCities,
        L10n.Common.titleCountries
    ]
    
    private let tabIndex: Int    
    private var name: ScreenNames {
        let countries: ScreenNames = swipeMenuView.currentIndex == 2 ? .visitedCountries : .followedPeople
        return swipeMenuView.currentIndex == 1 ? .visitedCities : countries
    }
    
    init(userId: String, tabIndex: Int = 0, userObject : User) {
        self.tabIndex = tabIndex;
        self.userID = userId
        super.init(nibName: nil, bundle: nil);
        
        viewControllers = [
            FollowingsTableViewController(userId: userId, userObject: userObject),
            CitiesTableViewController(userId: userId),
            CountriesTableViewController(userId: userId)
        ]
    }
    
    required init?(coder aDecoder: NSCoder) {
        tabIndex = 0;
        
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewControllers.forEach({
//            $0.tableView.rowHeight = 65;
            addChild($0);
            $0.didMove(toParent: self);
        })
        setupSwipe();
        swipeMenuView.jump(to: 1, animated: false);
        swipeMenuView.jump(to: tabIndex, animated: false);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirbaseAnalytics.trackScreen(name: name)
    }
    
    private func setupSwipe() {
        var options = SwipeMenuViewOptions();
        options.tabView.style = .segmented;
        options.tabView.additionView.backgroundColor = UIColor.white;
        options.tabView.backgroundColor = ColorName.navigationBarTint.color
        options.tabView.itemView.selectedTextColor = .white;
        swipeMenuView.reloadData(options: options);
    }
    
    // MARK - SwipeMenuViewDataSource
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return viewControllers.count;
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return titles[index];
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let viewController = viewControllers[index]
        return viewController
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        FirbaseAnalytics.trackScreen(name: name)
    }
}

extension ProfileCounterViewController: PullUpPresentationControllerDelegate {
    var canDismiss: Bool {
        return true
    }
}
