//
//  LocationInteractionViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 08/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class LocationInteractionViewController: SwipeMenuViewController {
    
    var viewControllers = [TopSpotsViewController]()
    var selectedFilters = [String]()
    var selectedFiltersKeys:String?
    
    var filtersCountLabel = UILabel()
    
    let titles = [
        L10n.LocationInteractionViewController.titleTop,
        L10n.LocationInteractionViewController.titleRecent
    ]
    
    var observation: NSKeyValueObservation?
    
    var location: Location?
    var comesFrom: ComesFrom?
    
    init(location: Location?) {
        super.init(nibName: nil, bundle: nil)
        
        self.location = location
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let font = UIFont.app.withSize(UIFont.sizes.small)
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: ColorName.navigationBarText.color,
            NSAttributedString.Key.font: font
        ]
        
        loadLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FirbaseAnalytics.trackScreen(name: "\(titles[swipeMenuView.currentIndex]) (Locations)")
        
        setupNavigationBar()
        toggleFilterState()
    }
    
    private func addRightBarCounter() {
        filtersCountLabel.frame = CGRect(x: self.view.frame.width - 35,y: 25 ,width: 20,height: 20)
        filtersCountLabel.font = UIFont.appMedium.withSize(UIFont.sizes.verySmall)
        filtersCountLabel.textAlignment = .center
        filtersCountLabel.textColor = .white
        filtersCountLabel.backgroundColor = ColorName.gradientTop.color
        filtersCountLabel.layer.opacity = 0.95
        filtersCountLabel.layer.cornerRadius = 10
        filtersCountLabel.layer.masksToBounds = true
        filtersCountLabel.clipsToBounds = true
        
        filtersCountLabel.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(showFilters)))
        filtersCountLabel.isUserInteractionEnabled = true
        
        navigationController?.view.addSubview(filtersCountLabel)
        navigationController?.view.bringSubviewToFront(filtersCountLabel)
    }
    
    func toggleFilterState() {
        if (selectedFilters.count > 0) {
            filtersCountLabel.text = String(selectedFilters.count)
            filtersCountLabel.isHidden = false
        }
        else{
            filtersCountLabel.text = ""
            filtersCountLabel.isHidden = true
        }
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.shadowImage = UIColor.gray.withAlphaComponent(0.5).as1ptImage()
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.leftArrowNav.image,
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.filter.image,
            style: .plain,
            target: self,
            action: #selector(showFilters)
        )
        
        addRightBarCounter()
    }
    
    func loadLocation() {
        if let location  = location {
            title = location.name
            setupChildControllers()
            setupSwipe()
            getLocationViewport()
        } else {
            title = L10n.LocationInteractionViewController.labelLocating
            LocationService.shared.updateCurrentPlace { [self] (location) in
                guard self.location == nil else {return}
                
                self.location = location
                self.location?.name = self.location?.cityFormatted
                self.location?.isCurrentLocation = true
                self.loadLocation()
            }
        }
    }
    
    private func setupSwipe() {
        var options = SwipeMenuViewOptions()
        options.tabView.style = .segmented
        options.tabView.additionView.backgroundColor = UIColor.white
        options.tabView.backgroundColor = ColorName.navigationBarTint.color
        options.tabView.itemView.selectedTextColor = .white
        
        options.contentScrollView.isScrollEnabled = false
        
        swipeMenuView.reloadData(options: options)
    }
    
    private func setupChildControllers() {
        viewControllers = [ TopSpotsViewController(location: location!), YourPeopleSpotsViewController(location: location!)]
        
        viewControllers.forEach({
            $0.comesFrom = comesFrom
            addChild($0)
            $0.didMove(toParent: self)
        })
    }
    
    @IBAction func goBack(_ sender: Any) {
        if viewControllers.count > swipeMenuView.currentIndex, viewControllers[swipeMenuView.currentIndex].backPressed() {
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func showFilters() {
        FirbaseAnalytics.logEvent(.filter)
        AmplitudeAnalytics.logEvent(.filter, group: .search, properties: ["filter type" : ["eat", "play", "stay"]])
        
        let viewController = FilterViewController()
        let navigationController = UINavigationController(rootViewController:  viewController)
        viewController.delegate = self
        viewController.selectedFilters = self.selectedFilters
        viewController.selectedFiltersKeys = self.selectedFiltersKeys
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: false, completion: nil)
    }
    
    // MARK - SwipeMenuViewDataSource
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        return viewControllers.count
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        return titles[index]
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        return viewControllers[index]
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, didChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        FirbaseAnalytics.trackScreen(name: "\(titles[toIndex]) (Locations)")
        AmplitudeAnalytics.logEvent(toIndex == 1 ? .searchLocRecentTab : .searchLocTopSpotTab, group: .search)
    }
}

extension LocationInteractionViewController: FilterDelegate {
    
    func filterBy(categories: String?, selectedFilters: [String]) {
        viewControllers.forEach{ $0.categories = categories }
        
        self.selectedFilters = selectedFilters
        selectedFiltersKeys = categories
        
        toggleFilterState()
    }
}



///Get ViewPort for the given location
extension LocationInteractionViewController {
    private func getLocationViewport() {
        guard let location = location, let coordinate = location.coordinate else { return }
        
        let locationType = location.type?.lowercased() ?? ""
        
        if locationType == "continent" || locationType == "country", let name = location.name {
            APIContext.shared.adressDetails(name: name, inLanguage: .english) { (data, urlRresponse, error) in
                guard
                    let geocode = try? data?.convert(RevesrseGeocode.self).results.last,
                    let viewport = geocode.geometry?.viewport else { return }
                self.viewControllers.forEach({
                    $0.locationViewport = viewport
                    $0.spotMapViewController.locationViewport = viewport
                })
            }
            
            return
        }
        
        APIContext.shared.reverseGeocode(coordinate: coordinate, inLanguage: .english) { (data, urlResponse, error) in
            
            guard let results = try? data?.convert(RevesrseGeocode.self).results else { return }
            
            var geocode:GeocodeLocation?
            if locationType == "state" {
                geocode = results.last(where: { ($0.types?.contains("administrative_area_level_1") ?? false) }) ??
                    (results.count > 1 ? results[results.count - 2] : nil)
            } else if locationType == "country" || locationType == "continent" {
                geocode = results.last(where: { ($0.types?.contains("country") ?? false) }) ??
                    results.last
            } else {
                geocode = results.last(where: { ($0.types?.contains("locality") ?? false) }) ??
                    results.last(where: { ($0.types?.contains("postal_town") ?? false) }) ??
                    results.last(where: { ($0.types?.contains("administrative_area_level_3") ?? false) }) ??
                    results.last(where: { ($0.types?.contains("administrative_area_level_2") ?? false) })
            }
            
            if let viewport = geocode?.geometry?.viewport {
                self.viewControllers.forEach({
                    $0.locationViewport = viewport
                    $0.spotMapViewController.locationViewport = viewport
                })
            }
        }
    }
}
