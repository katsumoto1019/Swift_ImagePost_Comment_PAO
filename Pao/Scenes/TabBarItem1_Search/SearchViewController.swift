//
//  SearchViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 28/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload
import Motion

class SearchViewController: SwipeMenuViewController {
    var animationIdentifier: String?
    
    // SwipeMenuViewController is really bad so its best to track (again) which tab is current [EG]
    var currentTabIndex: Int = 0
    
    var searchViewControllers: [UIViewController & Searchable] = [
        LocationsSearchTableViewController(),
        PeopleSearchTableViewController(),
        SpotsSearchTableViewController()
    ]
    
    var viewControllers: [UIViewController & Searchable] = []
    
    let titles = [
        L10n.Common.titleLocations,
        L10n.Common.titlePeople,
        L10n.Common.titleGems
    ]
    
    let searchController = UISearchController(searchResultsController: nil)
    
    private var searchEvent = true //used to fire amplitude search event for only first search, to avoid multiple search events for each letter change
    public var isOpenedByEmail = false
    public var firstLoad = true
    public var tabIndex: Int? {
        didSet {
            if let forceTabIndex = tabIndex, let _ = swipeMenuView {
                cancelSearch(searchController.searchBar, defaultIndex: forceTabIndex)
                searchController.isActive = false
                tabIndex = nil
            }
        }
    }
    
    var options = SwipeMenuViewOptions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchViewControllers.forEach({addChild($0)})
        
        viewControllers = searchViewControllers
        
        setupSwipe()
        setupSearch()
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.leftArrowNav.image,
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        self.navigationController?.navigationBar.isTranslucent = false
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.searchController.dismiss(animated: false, completion: nil)
        self.searchController.searchBar.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (viewControllers.first as? PeopleSearchCollectionViewController) == nil {
            FirbaseAnalytics.trackScreen(name: "\(titles[swipeMenuView.currentIndex]) Search Bar")
        } else {
            FirbaseAnalytics.trackScreen(name: "\(titles[swipeMenuView.currentIndex]) Search")
        }
        
        let event: EventAction = swipeMenuView.currentIndex == 0 ? .tabSearchLocations : swipeMenuView.currentIndex == 1 ? .tabSearchPeople : .tabSearchSpots
        FirbaseAnalytics.logEvent(event)
        
        DispatchQueue.main.async {
            if self.firstLoad {
                self.firstLoad = false
                self.searchController.searchBar.becomeFirstResponder()
            } else {
                self.searchController.searchBar.resignFirstResponder()
            }
        }
    }
    
    @objc func goBack() {
        searchController.searchBar.text = ""
        if self.presentedViewController != nil {
            self.dismiss(animated: true, completion: nil)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    private func setupSwipe() {
        
        options.tabView.style = .segmented
        options.tabView.additionView.backgroundColor = ColorName.accent.color
        options.tabView.backgroundColor = ColorName.navigationBarTint.color
        options.tabView.itemView.selectedTextColor = .white
        swipeMenuView.reloadData(options: options)
        
        if (isOpenedByEmail) {
            swipeMenuView.jump(to: 2, animated: false)
        } else if let forceTab = self.tabIndex {
            //HACK: jump to index 1 before jumping to required index, fixes an issue.
            swipeMenuView.jump(to: 1, animated: false) // [EG] not sure if this is needed since recent fixes
            swipeMenuView.jump(to: forceTab, animated: false)
            self.tabIndex = nil
        }
    }
    
    private func setupSearch() {
        definesPresentationContext = true
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        let searchBar = searchController.searchBar
        searchBar.delegate = self
        searchBar.barStyle = .black
        searchBar.setTextFieldBorder()
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.leftView?.motionIdentifier = animationIdentifier
        } else {
            let subViews = searchBar.subviews.flatMap { $0.subviews }
            let textField = (subViews.filter { $0 is UITextField }).first as? UITextField
            textField?.leftView?.motionIdentifier = animationIdentifier
        }
        navigationItem.titleView = searchBar
    }
    
    // MARK - SwipeMenuViewDataSource
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
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        
        let event: EventAction = toIndex == 0 ? .tabSearchLocations : toIndex == 1 ? .tabSearchPeople : .tabSearchSpots
        FirbaseAnalytics.logEvent(event)
        
        AmplitudeAnalytics.logEvent(toIndex == 0 ? .searchLocationTab : toIndex == 1 ? .searchPeopleTab : .searchSpotTab , group: .search)
        searchEvent = true
        
        if (viewControllers.first as? PeopleSearchCollectionViewController) == nil {
            viewControllers[toIndex].searchString = searchController.searchBar.text
            
            FirbaseAnalytics.trackScreen(name: "\(titles[toIndex]) Search Bar")
        } else {
            FirbaseAnalytics.trackScreen(name: "\(titles[toIndex]) Search")
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateResults(_:)), object: searchController.searchBar)
        perform(#selector(updateResults(_:)), with: searchController.searchBar, afterDelay: 0.0)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelSearch(searchBar, defaultIndex: swipeMenuView.currentIndex)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        AmplitudeAnalytics.logEvent(.clickSearchBar, group: .search, properties: ["type" : swipeMenuView.currentIndex == 0 ? "locations" : swipeMenuView.currentIndex == 1 ? "people" : "spots"])
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isNotEmpty {
            searchController.searchBar.becomeFirstResponder()
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateResults(_:)), object: searchController.searchBar)
        perform(#selector(updateResults(_:)), with: searchController.searchBar, afterDelay: 0.2)
    }
    
    private func cancelSearch(_ searchBar: UISearchBar?, defaultIndex: Int) {
        searchBar?.text = nil
        viewControllers[swipeMenuView.currentIndex].searchString = nil
        if defaultIndex != swipeMenuView.currentIndex {
            swipeMenuView.jump(to: defaultIndex, animated: false)
        }
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    @objc func updateResults(_ searchBar: UISearchBar) {
        
        if searchEvent && !(searchBar.text?.isEmpty ?? true){
            let event: EventAction = swipeMenuView.currentIndex == 0 ? .searchBarLocation : swipeMenuView.currentIndex == 1 ? .searchBarPeople : .searchBarSpot
            FirbaseAnalytics.logEvent(event)
            
            let eventName: EventName = swipeMenuView.currentIndex == 0 ? .searchBarLocation : swipeMenuView.currentIndex == 1 ? .searchBarPeople : .searchBarSpots
            AmplitudeAnalytics.logEvent(eventName, group: .search)
            searchEvent = false
        }
        //This block is to resolve search Typo issue
        if let vc = viewControllers[swipeMenuView.currentIndex] as? PeopleSearchTableViewController {
            vc.collection.isLoading = false
        } else if let vc = viewControllers[swipeMenuView.currentIndex] as? LocationsSearchTableViewController {
            vc.collection.isLoading = false
        } else if let vc = viewControllers[swipeMenuView.currentIndex] as? SpotsSearchTableViewController {
            vc.collection.isLoading = false
        } else {
            return
        }
        
        viewControllers[swipeMenuView.currentIndex].searchString = searchBar.text
    }
}

extension SearchViewController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
        
        searchEvent = true
        
        let event: EventAction = swipeMenuView.currentIndex == 0 ? .searchBarLocation : swipeMenuView.currentIndex == 1 ? .searchBarPeople : .searchBarSpot
        FirbaseAnalytics.logEvent(event)
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(updateResults(_:)), object: searchController.searchBar)
        perform(#selector(updateResults(_:)), with: searchController.searchBar, afterDelay: 0.2)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        //navigationController?.popViewController(animated: true)
    }
}
