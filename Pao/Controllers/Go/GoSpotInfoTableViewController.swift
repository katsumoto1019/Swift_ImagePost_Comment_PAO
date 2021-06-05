//
//  GoSpotInfoTableTableViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 03/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class GoSpotInfoTableViewController: StyledTableViewController {
    
    private var spot: Spot!
    private var placeDetails: PlaceDetailsResult?
    
    init(style: UITableView.Style, spot: Spot) {
        super.init(style: style)
        
        self.spot = spot;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView();
        getPlaceInfo();
        getPlaceDescription();
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none;
        tableView.register(GoAboutTableViewCell.self);
        tableView.register(GoFactsTableViewCell.self);
        tableView.register(GoContactTableViewCell.self);
    }
    
    private func getPlaceInfo() {
        guard let placeId = spot.location?.googlePlaceId else { return; }
        let placeDetails: [PlaceDetail] = [.openingHours,
                                           .formattedPhoneNumber,
                                           .formattedAddress,
                                           .website,
                                           .businessStatus];
        
        APIContext.shared.getPlaceDetails(placeDetails,
                                          placeId: placeId,
                                          inLanguage: .english) { (data, urlResponse, error) in
            guard let details = try? data?.convert(PlaceDetailsResponse.self).result else { return; }
            self.placeDetails = details
            self.tableView.reloadData();
        }
    }
    
    private func getPlaceDescription() {
        guard let name = spot.location?.name, spot.location?.about == nil else {return}
        APIContext.shared.placeDescription(searchTerm: name) { (responseData, response, error) in
            if let kgResult = try? responseData?.convert(KGResult.self) {
                self.spot.location?.about = kgResult.itemListElement?[safe: 0]?.result?.detailedDescription?.articleBody;
                self.tableView.reloadData();
            }
        }
    }
}

// MARK: - Table view data source
extension GoSpotInfoTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        var section = 1;
//        section += spot.location?.about != nil ? 1 : 0;
        section += placeDetails != nil ? 1: 0;
        return section;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = GoContactTableViewCell.reuseIdentifier;
        switch indexPath.section {
        case 0:
            //identifier = spot.location?.about != nil ? GoAboutTableViewCell.reuseIdentifier : placeDetails != nil ? GoFactsTableViewCell.reuseIdentifier : identifier;
            identifier = placeDetails != nil ? GoFactsTableViewCell.reuseIdentifier : identifier;
            break;
        case 1:
            //identifier =  (spot.location?.about != nil && placeDetails != nil) ? GoFactsTableViewCell.reuseIdentifier : identifier;
            break;
        default:
            identifier = GoContactTableViewCell.reuseIdentifier;
            break;
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! GoBaseTableViewCell
        cell.set(spot: spot, placeDetails: placeDetails);
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 20));
        headerView.tintColor = ColorName.background.color
        headerView.textColor = ColorName.accent.color
        headerView.font =  UIFont.appNormal.withSize(UIFont.sizes.small);
        
        headerView.text = titleForHeader(inSection: section);
        headerView.text?.capitalizeFirstLetter();
        return headerView;
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section > 0 && section >= (numberOfSections(in: tableView) - 1){
            return 0;
        }
         return section == 0 ? 30 : 20;
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1;
    }
    
    func titleForHeader(inSection section: Int)-> String?{
        switch section {
        case 0:
            //return spot.location?.about != nil ? "About" : placeDetails != nil ? "Facts" : nil;
            return  placeDetails != nil ? L10n.GoSpotInfoTableViewController.facts : nil;
        case 1:
            //return (spot.location?.about != nil && placeDetails != nil) ? "Facts" : nil;
            return nil;
        default:
            return nil;
        }
    }
}

extension GoSpotInfoTableViewController: PullUpPresentationControllerDelegate {
    
    var canDismiss: Bool {
        return tableView.contentOffset.y <= 0
    }
}
