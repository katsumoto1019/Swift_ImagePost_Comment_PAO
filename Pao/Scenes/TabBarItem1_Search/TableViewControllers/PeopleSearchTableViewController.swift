//
//  PeopleSearchTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 28/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class PeopleSearchTableViewController: RocketTableViewController<PeopleSearchTableViewCell> {
    
    var noResultText = NSMutableAttributedString(string: L10n.PeopleSearchTableViewController.noResultText);
    lazy var emptyView: UIView = {
        noResultText.addAttribute(NSAttributedString.Key.font, value: UIFont.appNormal.withSize(18), range: NSRange(location: 0, length: 5))
        
        let label = UILabel()
        label.font = UIFont.app.withSize(UIFont.sizes.small)
        label.attributedText = noResultText
        label.numberOfLines = 0;
        label.textAlignment = .center
        label.textColor = ColorName.textWhite.color
        
        let view = UIView()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constraintToFit(inContainerView: view)
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        screenName = "people_search"
        rocketCollection.cacheKey = "peopleSearch"
        tableView.backgroundView = emptyView
        tableView.keyboardDismissMode = .onDrag
        
        super.viewDidLoad()
        self.tableView.separatorColor = .clear
        self.tableView.refreshControl?.endRefreshing()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PeopleSearchTableViewCell.reuseIdentifier, for: indexPath) as! PeopleSearchTableViewCell;
        
        cell.isPeopleSearch = true;
        cell.set(collection[indexPath.row])
        cell.followCallback = {[weak self] action in
            AmplitudeAnalytics.logEvent(((self?.searchString?.isEmpty ?? true) ? .friendTopUser : .friendSearchText), group: .addPeople, properties: ["action" :  action == .follow ? "follow" : "unfollow"])
            if (self?.searchString?.isEmpty ?? true) {
                AmplitudeAnalytics.logEvent(.viewOtherFromTopUsers, group: .otherProfile)
            } else {
                AmplitudeAnalytics.logEvent(.viewOtherFromSearch, group: .otherProfile, properties: ["search method" : "text search"])
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = collection[indexPath.row]
        
        FirbaseAnalytics.logEvent(.searchTopUser)
        AmplitudeAnalytics.logEvent(((self.searchString?.isEmpty ?? true) ? .searchPeopleSelectTopUser : .searchPeopleSelectSpecific), group: .search)
        if let navController = navigationController {
            navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
            let viewController = UserProfileViewController(user: user)
            viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
            navController.pushViewController(viewController, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func getPayloads(completionHandler: @escaping ([User]?) -> Void) -> PayloadTask? {
        return super.getPayloads { (users) in
            
            //If result contains current user, then data of curent user should be repalced with the full profileData object.
            if var users = users, let currentUser = DataContext.cache.user, let index = users.firstIndex(where: {currentUser.id == $0.id }) {
                users[index] = currentUser.duplicate() ?? currentUser
                completionHandler(users)
                return
            }
            
            completionHandler(users)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if collection.count <= 0  {
            return 0
        }
                
        return  30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var title: String?
        title = L10n.PeopleSearchTableViewController.Header.title
        
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
