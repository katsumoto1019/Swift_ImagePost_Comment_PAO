//
//  LocationsSearchTableViewController+Extension.swift
//  Pao
//
//  Created by Waseem Ahmed on 10/10/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit

//TableView delegate & datasource
extension LocationsSearchTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if showCurrentLocation, indexPath.section == 0, indexPath.item == 0 {
            if !LocationService.shared.isEnabled() {
                askLocationPermission()
            } else  {
                showLocation(for: nil)
            }
            return
        }
        
        let data = dataAt(indexPath: indexPath)
        showLocation(for: data)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (showCurrentLocation && indexPath.section == 1) || !showCurrentLocation && indexPath.section == 0 {
            if (indexPath.row + collection.bufferDelta >= collection.count) {
                loadData()
            }
        }
        
        let locationSearchTableViewCell = cell as? LocationSearchTableViewCell
        
        if showCurrentLocation, indexPath.section == 0, indexPath.item == 0 {
            locationSearchTableViewCell?.titleLabel.textColor = ColorName.accent.color
        } else {
            locationSearchTableViewCell?.titleLabel.textColor = ColorName.textWhite.color
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard collection.count > 0 else { return 0 }
        
        if showCurrentLocation {
            return section == 0 ? (collection.count > 0 ? 1 : 0) : collection.count
        } else {
            return section == 0 ? collection.count : relatedLocations.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationSearchTableViewCell.reuseIdentifier, for: indexPath) as! LocationSearchTableViewCell
        
        willSet(cell: cell)
        cell.set(dataAt(indexPath: indexPath), isPinIcon: !(showCurrentLocation && indexPath.section > 0))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String?
        
        if showCurrentLocation {
            title = section == 0 ? nil : L10n.LocationsSearchTableViewController.Section.titleTopPaoCities
        } else {
            title = section == 0 ? L10n.LocationsSearchTableViewController.Section.titleResults : L10n.LocationsSearchTableViewController.Section.titleRelated
        }
        
        guard title != nil, collection.count > 0 else { return nil }
                
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 30))
        let headerViewLabel = UILabel.init(frame: CGRect.init(x: 16, y: 10, width: tableView.bounds.width, height: 16))
        headerViewLabel.tintColor = ColorName.background.color
        headerViewLabel.textColor = ColorName.textWhite.color
        headerViewLabel.font =  UIFont.appNormal.withSize(UIFont.sizes.small)
        headerViewLabel.text = title
        
        headerView.backgroundColor = tableView.backgroundColor
        headerView.addSubview(headerViewLabel)
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if collection.count <= 0 ||
            (showCurrentLocation && section == 0) ||
            (!showCurrentLocation && section == 1 && self.relatedLocations.count <= 0) {
            return 0
        }
                
        return  30
    }
    
    private func dataAt(indexPath: IndexPath) -> Location {
        if showCurrentLocation {
            return indexPath.section == 0 ? self.currentLocation : self.collection[indexPath.row]
        } else {
            return indexPath.section == 0 ? self.collection[indexPath.row] : self.relatedLocations[indexPath.row]
        }
    }
}

extension LocationsSearchTableViewController {
    func askLocationPermission() {
        guard var parentVC = self.parent else { return }
        if let presentedViewController = self.presentedViewController {
            parentVC = presentedViewController
        }
        if LocationService.shared.isDenied() {
            LocationService.shared.openSettings(parent: parentVC)
            return
        }
        
        let alert = PermissionAlertController(title: L10n.LocationsSearchTableViewController.PermissionAlert.title, subTitle: L10n.LocationsSearchTableViewController.PermissionAlert.subTitle)
        alert.addButton(title: L10n.Common.yes, style: .normal) {
            LocationService.shared.enableService({ [unowned self](granted) in
                if granted {
                    self.showLocation(for: nil)
                }
            })
        }
        alert.addButton(title: L10n.Common.notNow, style: .additional) {
        }
        alert.show(parent: parentVC)
    }
}

