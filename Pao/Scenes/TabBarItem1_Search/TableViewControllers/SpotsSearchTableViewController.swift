//
//  SpotsSearchTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 28/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class SpotsSearchTableViewController: TableViewController<SpotSearchTableViewCell>, UIViewControllerTransitioningDelegate {
    
    //var headerStackView = UIStackView();
    var noResultText = NSMutableAttributedString(string: L10n.SpotsSearchTableViewController.noResultText);
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
    
    
    override func viewDidLoad() {
        screenName = "spot_search";
        tableView.backgroundView = emptyView;
        tableView.keyboardDismissMode = .onDrag;
        tableView.separatorStyle = .none
        
        super.viewDidLoad();
        self.tableView.refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let spot = collection[indexPath.row];
        FirbaseAnalytics.logEvent( .searchTopSpot)
        AmplitudeAnalytics.logEvent(((self.searchString?.isEmpty ?? true) ? .searchSpotSelectTopSpot : .searchSpotSlectSpecific), group: .search)

        showGo(spot: spot);
    }
    
    private func showGo(spot: Spot) {        
        let viewController = ManualSpotsViewController.init(spots: [spot])
        viewController.title = spot.location?.name
        viewController.comesFrom = .topPaoSpots
        viewController.dataDidUpdate = { (updatedSpot: Spot) in
            DispatchQueue.main.async {
                // update data in collection
                if let index = self.collection.firstIndex(of: updatedSpot) {
                    self.collection[index] = updatedSpot
                }
                self.tableView.reloadData()
            }
        }
        navigationController?.pushViewController(viewController, animated: false)
        
        //Amplitude swipe event
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            viewController.spotCollectionViewController.amplitudeEventSwipe =  .swipeTopSpotsFeed
            viewController.spotCollectionViewController.amplitudeEventGroup =  .search
        }
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = PullUpPresentationController(presentedViewController: presented, presenting: presenting);
        
        return controller;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return collection[indexPath.row].location?.typeFormatted != nil ? 85 : 70;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if collection.count <= 0  {
            return 0
        }
                
        return  30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String?
        title = L10n.SpotsSearchTableViewController.title
        
        guard title != nil, collection.count > 0 else { return nil }
                
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        let headerViewLabel = UILabel.init(frame: CGRect.init(x: 16, y: 10, width: tableView.bounds.width, height: 16))
        headerViewLabel.tintColor = ColorName.background.color
        headerViewLabel.textColor = ColorName.textWhite.color
        headerViewLabel.font =  UIFont.appNormal.withSize(UIFont.sizes.small)
        headerViewLabel.text = title
        
        headerView.backgroundColor = tableView.backgroundColor
        headerView.addSubview(headerViewLabel)
        return headerView;
    }
}
