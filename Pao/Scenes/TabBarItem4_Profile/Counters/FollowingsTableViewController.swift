//
//  YourPeopleTableViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 13/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class FollowingsTableViewController: TableViewController<PeopleSearchTableViewCell> {
    var userId:String?
    var userObj:User?
    var showProfile: ((User) -> Void)?
    
    init(userId: String, userObject : User) {
        super.init();
        self.userId = userId;
        self.userObj = userObject;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userInList = collection[indexPath.row];
        
        dismiss(animated: true);
        showProfile?(userInList);
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65;
    }
    
   override func getPayloads(completionHandler: @escaping ([PeopleSearchTableViewCell.PayloadType]?) -> Void) -> PayloadTask? {
        let params = UserParams(skip: collection.count, take: collection.bufferSize, userId: userId!);
        return App.transporter.get([PeopleSearchTableViewCell.PayloadType].self, for:type(of: self), queryParams: params, completionHandler: { (result) in
            if self.userId == DataContext.cache.user.id {
                result?.forEach({
                    $0.isFollowedByViewer = true
                    //TODO: - Might be not needed
                    if let user0Id = $0.id {
                        DataContext.cache.addToMyPeople(userObj: $0);
                        NotificationCenter.followingPeople();
                    }
                });
            }
            completionHandler(result);
        })
    }
}
