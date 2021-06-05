//
//  LocationsSearchTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 28/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class LocationsSearchTableViewController: TableViewController<LocationSearchTableViewCell> {
    
    private let currentLocationName = L10n.LocationsSearchTableViewController.currentLocation
    var noResultText = NSMutableAttributedString(string: L10n.LocationsSearchTableViewController.noResultText);
    lazy var emptyView: UIView = {
        noResultText.addAttribute(NSAttributedString.Key.font, value: UIFont.appNormal.withSize(18), range: NSRange(location: 0, length: 8))
        
        let label = UILabel();
        label.font = UIFont.app.withSize(UIFont.sizes.small);
        label.attributedText = noResultText;
        label.numberOfLines = 0;
        label.textAlignment = .center;
        label.textColor = ColorName.textWhite.color
        
        let view = UIView();
        view.addSubview(label);
        label.translatesAutoresizingMaskIntoConstraints = false;
        label.constraintToFit(inContainerView: view);
        view.isHidden = true;
        return view;
    }()
    
    var showCurrentLocation: Bool {
        return self.searchString?.isEmpty ?? true
    }
    
    var relatedLocations = [Location]()
    lazy var currentLocation: Location = {
        let location = Location()
        location.name = self.currentLocationName
        return location
    }()
    
    override func viewDidLoad() {
        screenName = "locationSearch";
        collection.bufferSize = 30;
        tableView.backgroundView = emptyView;
        tableView.keyboardDismissMode = .onDrag;
        tableView.separatorStyle = .none
        
        super.viewDidLoad();
        
        _ = collection.elementsChanged.removeLast();
        
        collection.elementsChanged.append { (changes) in
            if changes != nil {
                self.tableView.reloadData()
            } else {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                self.activityIndicatorView?.stopAnimating()
            }
        }
        
        collection.loaded.append { (status) in
            self.activityIndicatorView?.stopAnimating()
        }
        
        self.tableView.refreshControl?.endRefreshing()
    }
    
    
    /// Show spots for specific location
    ///
    /// - Parameter location: Location to be displayed. If sent nil, then it will get current location
    func showLocation(for location: Location?) {
        if location == nil {
            AmplitudeAnalytics.logEvent(.searchLocationSelectCurrent, group: .search)
        } else {
            AmplitudeAnalytics.logEvent(((self.searchString?.isEmpty ?? true) ? .searchLocationSelectTopCity : .searchLocationSelectSpecific), group: .search)
        }
        
        FirbaseAnalytics.logEvent( location == nil ? .searchCurrentLocation : .searchTopCity)
        
        let viewController = LocationInteractionViewController(location: location);
        viewController.comesFrom = .locationSearch
        let navigationController = UINavigationController(rootViewController:  viewController);
        navigationController.modalPresentationStyle = .fullScreen;
        present(navigationController, animated: true);
    }
    
    override func getPayloads(completionHandler: @escaping ([LocationSearchTableViewCell.PayloadType]?) -> Void) -> PayloadTask? {
        
        if collection.count > 0, let screenName = screenName, !screenName.isEmpty {
            //            FirbaseAnalytics.trackEvent(category: .uiAction, action: .scrollMore, label: screenName);
        }
        
        let params = CollectionParams(skip: collection.count, take: collection.bufferSize, keyword: searchString);
        return App.transporter.get(LocationSearch.self, queryParams: params) { (result) in
            
            self.relatedLocations = result?.related ?? [Location]()
            completionHandler(result?.locations)
        }
    }
}
