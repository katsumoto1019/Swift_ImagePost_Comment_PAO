//
//  DiscoverViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/1/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift
import Instructions

class DiscoverViewController: SwipeMenuViewController {
    
    // MARK: - Dependencies
    
    lazy var spotsViewController = SpotsViewController()
    private lazy var playListViewController = PlayListCollectionViewController()
    
    lazy var viewControllers: [UIViewController] = []
    
    // MARK: - Internal properties
    
    var coachMarksController = CoachMarksController()
    
    // MARK: - Private properties
    
    private let titles = [
        L10n.Common.titleYourPeople,
        L10n.Common.titleTheWorld
    ]
    private var isLoaded = false
    private var isLoading = false
    private var isVisible = false
    var currentTabIndex = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildControllers()
        setupSwipe()
        
        navigationController?.navigationBar.isHidden = true
        
        spotsViewController.isFeed = true

        checkIsNewUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FirbaseAnalytics.trackScreen(name: titles[currentTabIndex])

        isVisible = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        isVisible = false
    }
    
    // MARK: - SwipeMenuViewDataSource implementation
    
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return viewControllers.count
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return titles[index]
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let viewController = viewControllers[index]
        viewController.didMove(toParent: self)
        return viewController
    }
    
    // MARK: - SwipeMenuViewDelegate implementation
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        FirbaseAnalytics.trackScreen(name: titles[toIndex])
        AmplitudeAnalytics.logEvent(toIndex == 1 ? .theWorld : .yourPeople, group: .viewSpots)
    }
    
    // MARK: - Private methods
    
    private func setupChildControllers() {
        playListViewController.isTheWorldView = true
        playListViewController.disablePullToRefresh()
        viewControllers = [spotsViewController, playListViewController]
        viewControllers.forEach{ addChild($0) }
    }
    
    private func setupSwipe() {
        var options = SwipeMenuViewOptions()
        options.tabView.style = .segmented
        options.tabView.additionView.backgroundColor = .white
        options.tabView.backgroundColor = ColorName.navigationBarTint.color
        options.tabView.itemView.selectedTextColor = .white
        options.tabView.itemView.font = UIFont.appLight
        options.contentScrollView.isScrollEnabled = false
        swipeMenuView.reloadData(options: options)
    }
    
    private func checkIsNewUser() {
        currentTabIndex = UserDefaults.bool(key: UserDefaultsKey.showWorldTab.rawValue) ? 1 : 0
        UserDefaults.save(value: false, forKey: UserDefaultsKey.showWorldTab.rawValue)
        swipeMenuView.jump(to: currentTabIndex, animated: false)
    }
    
}
