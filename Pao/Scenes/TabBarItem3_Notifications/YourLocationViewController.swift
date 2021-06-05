//
//  YourLocationViewController.swift
//  Pao
//
//  Created by OmShanti on 30/11/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit
import Payload

class YourLocationViewController: BaseViewController {
    
    var headerView: LocationHeaderView!
    var headerViewHeightConstraint: NSLayoutConstraint!
    var maxHeight: CGFloat = 0.0
    var minHeight: CGFloat = 0.0
    var previousScrollingOffsetValue: CGFloat = 0.0
    var tableContainerView: UIView!
    var yourLocationSpotTableViewController = YourLocationSpotTableViewController()
    var isCollapsed = false
    var collection = PayloadCollection<PushNotification<String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        yourLocationSpotTableViewController.passedCollection.append(contentsOf: collection)
        yourLocationSpotTableViewController.scrollViewDidScrollCallback = scrollViewDidScroll(_:)
        yourLocationSpotTableViewController.scrollViewDidEndDeceleratingCallback = scrollViewDidEndDecelerating(_:)
        
        headerView = LocationHeaderView.loadFromNibNamed(nibNamed: "LocationHeaderView") as? LocationHeaderView
        view.addSubview(headerView)
        
        tableContainerView = UIView()
        view.addSubview(tableContainerView)
        
        setupConstraints()
        setupChildControllers()
        
        maxHeight = headerViewHeightConstraint.constant
        minHeight = 40.0
    }
    
    func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerViewHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: 200)
        headerViewHeightConstraint.isActive = true
        
        tableContainerView.translatesAutoresizingMaskIntoConstraints = false
        tableContainerView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    private func setupChildControllers() {
        addChild(yourLocationSpotTableViewController)
        yourLocationSpotTableViewController.view.frame = tableContainerView.bounds
        tableContainerView.addSubview(yourLocationSpotTableViewController.view)
        yourLocationSpotTableViewController.didMove(toParent: self)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollViewScrolled(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewScrolled(scrollView)
    }
    
    func scrollViewScrolled(_ scrollView: UIScrollView) {
        if scrollView.contentSize.height > scrollView.frame.height + headerViewHeightConstraint.constant && scrollView.contentOffset.y > 30 {
            if !isCollapsed {
                collapseHeader()
            }
        } else {
            if isCollapsed {
                expandHeader()
            }
        }
    }
    
    func collapseHeader() {
        isCollapsed = true
        UIView.animate(withDuration: 0.2) {
            self.headerViewHeightConstraint.constant = self.minHeight
            self.headerView.transparentView.alpha = 0
            self.headerView.backgroundImage.alpha = 0
            self.headerView.gradientView.alpha = 0
            self.headerView.blackView.alpha = 0
            self.headerView.lblWhatsHappening.alpha = 0
            self.headerView.lblWhatsHappening.text = ""
            self.headerView.lblCity.textAlignment = .left
            self.headerView.leftAlignConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    func expandHeader() {
        isCollapsed = false
        UIView.animate(withDuration: 0.2) {
            self.headerViewHeightConstraint.constant = self.maxHeight
            self.headerView.transparentView.alpha = 0.5
            self.headerView.backgroundImage.alpha = 1
            self.headerView.gradientView.alpha = 1
            self.headerView.blackView.alpha = 1
            self.headerView.lblWhatsHappening.text = L10n.YourLocationViewController.labelWahtsHappening
            self.headerView.lblWhatsHappening.alpha = 1
            self.headerView.lblCity.textAlignment = .center
            self.headerView.leftAlignConstraint.isActive = false
            self.view.layoutIfNeeded()
        }
    }
}
