//
//  NotificationSwipeMenuViewController.swift
//  Pao
//
//  Created by OmShanti on 26/11/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit
import Payload

class NotificationSwipeMenuViewController: SwipeMenuViewController {

    lazy var notificationsViewController = NotificationsViewController()
    lazy var yourLocationViewController = YourLocationViewController()
    lazy var viewControllers: [UIViewController] = []
    
    private let searchMotionIdentifier = "search_icon_search_bar"
    private let titles = [
        L10n.Common.titleYourPeople,
        L10n.Common.titleYourLocations
    ]
    private var aryShowDot = [false, false]
    
    var notificationCollection = PayloadCollection<PushNotification<String>>()
    var locationCollection = PayloadCollection<PushNotification<String>>()
    var moveToLocationTab = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationsViewController.passedCollection.append(contentsOf: notificationCollection)
        yourLocationViewController.collection.append(contentsOf: locationCollection)
        setupChildControllers()
        setupSwipe()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigaionBar()
        removeDotFromTab(currentTab: swipeMenuView.currentIndex)
        
        if moveToLocationTab {
            if swipeMenuView != nil {
                swipeMenuView.jump(to: 1, animated: false)
                swipeMenuView.currentIndex = 1
                moveToLocationTab = false
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if swipeMenuView != nil {
            removeDotFromTab(currentTab: swipeMenuView.currentIndex)
        }
    }
    
    func showDotOnYourPeopleTab() {
        aryShowDot[0] = true
        if swipeMenuView != nil {
            swipeMenuView.updateDotOnTabView()
        }
    }
    
    func showDotOnYourLocationTab() {
        aryShowDot[1] = true
        if swipeMenuView != nil {
            swipeMenuView.updateDotOnTabView()
        }
    }
    
    private func removeDotFromTab(currentTab: Int) {
        aryShowDot[currentTab] = false
        swipeMenuView.updateDotOnTabView()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        if currentTab == 0 { // Your People Page
            if !aryShowDot[1] {
                if tabBarController?.tabBar.items?[3].badgeValue != nil {
                    tabBarController?.tabBar.items?[3].badgeValue = nil
                }
            }
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: UserDefaultsKey.lastPeopleNotificationDate.rawValue)
        } else if currentTab == 1 { // Your Location Page
            if !aryShowDot[0] {
                if tabBarController?.tabBar.items?[3].badgeValue != nil {
                    tabBarController?.tabBar.items?[3].badgeValue = nil
                }
            }
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: UserDefaultsKey.lastLocationNotificationDate.rawValue)
            }
    }
    
    // MARK: - SwipeMenuViewDataSource implementation
    
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return viewControllers.count
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return titles[index]
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, showDotForTabAt index: Int) -> Bool? {
        return aryShowDot[index]
    }
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        let viewController = viewControllers[index]
        viewController.didMove(toParent: self)
        return viewController
    }
    
    // MARK: - SwipeMenuViewDelegate implementation
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        aryShowDot[0] = false
        aryShowDot[1] = false
        swipeMenuView.updateDotOnTabView()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        if tabBarController?.tabBar.items?[3].badgeValue != nil {
            tabBarController?.tabBar.items?[3].badgeValue = nil
        }
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: UserDefaultsKey.lastPeopleNotificationDate.rawValue)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: UserDefaultsKey.lastLocationNotificationDate.rawValue)
        
        FirbaseAnalytics.trackScreen(name: titles[toIndex])
        AmplitudeAnalytics.logEvent(toIndex == 1 ? .yourLocations : .notifications, group: .notifications)
    }
    
    // MARK: - Private methods
    
    private func setupChildControllers() {
        viewControllers = [notificationsViewController, yourLocationViewController]
        viewControllers.forEach{ addChild($0) }
    }
    
    private func setupSwipe() {
        let tabInternalMargin: CGFloat = 12
        var leadingMargin: CGFloat = 16
        if let margin = self.navigationController?.systemMinimumLayoutMargins.leading {
            leadingMargin = margin
        }
        var options = SwipeMenuViewOptions()
        options.tabView.height = 32
        options.tabView.margin = (leadingMargin - tabInternalMargin) + 1.3
        options.tabView.style = .flexible
        options.tabView.additionView.backgroundColor = ColorName.accent.color
        options.tabView.additionView.padding = UIEdgeInsets(horizontal: 16, vertical: 0)
        options.tabView.itemView.selectedTextColor = .white
        options.tabView.itemView.font = UIFont.appLight.withSize(UIFont.sizes.small)
        options.tabView.itemView.margin = tabInternalMargin
        options.contentScrollView.isScrollEnabled = false
        swipeMenuView.reloadData(options: options)
    }
    
    private func setupNavigaionBar() {
        navigationController?.navigationBar.isHidden = false
        // Removes navigation bar bottom shadow line
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        addTitle()
        addSearchButton()
    }
    
    private func addTitle() {
        let label = UILabel()
        label.text = L10n.Common.titleNotifications
        label.font = UIFont.appBold.withSize(UIFont.sizes.large)
        label.textColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
    func addSearchButton() {
        let searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        searchButton.setImage(UIImage(named: "search-teal"), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchButton.motionIdentifier = searchMotionIdentifier
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
    }
    
    @objc func searchButtonTapped() {
        AmplitudeAnalytics.logEvent(.searchIcon, group: .search)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.searchViewController.hidesBottomBarWhenPushed = true
        appDelegate.searchViewController.firstLoad = true
        appDelegate.searchViewController.animationIdentifier = searchMotionIdentifier
        let navigationController = UINavigationController(rootViewController: appDelegate.searchViewController)
        navigationController.isMotionEnabled = true
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
}
