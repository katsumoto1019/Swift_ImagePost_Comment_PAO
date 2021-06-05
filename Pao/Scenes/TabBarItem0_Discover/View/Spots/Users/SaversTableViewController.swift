//
//  SaversTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 10/10/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class SaversTableViewController: TableViewController<PeopleSearchTableViewCell> {
    private var users: [User]!
    
    init(users: [User]!) {
        super.init()
        
        self.users = users
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func getPayloads(completionHandler: @escaping ([PeopleSearchTableViewCell.PayloadType]?) -> Void) -> PayloadTask? {
        completionHandler(users)
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = collection[indexPath.row];
        navigationController?.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
        let viewController = UserProfileViewController(user: user);
   
        // HACK
        dismiss(animated: true);
        if let navigationController = presentingViewController as? UINavigationController {
            viewController.isNavigationBarHiddenOnParent = navigationController.navigationBar.isHidden
            navigationController.pushViewController(viewController, animated: true);
        } else if let tabBarController = presentingViewController as? TabBarController {
            if let navController = tabBarController.children[tabBarController.selectedIndex] as? UINavigationController {
                viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
                navController.pushViewController(viewController, animated: true)
            }
        }
    }
}
