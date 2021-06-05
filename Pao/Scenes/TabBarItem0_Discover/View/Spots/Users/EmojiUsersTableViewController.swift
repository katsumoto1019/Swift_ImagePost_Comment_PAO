//
//  EmojiUsersTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 10/10/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class EmojiUsersTableViewController: TableViewController<PeopleSearchTableViewCell> {
    private var emojiItems: [User]!

    init(emojiItems: [User]!) {
        super.init()
        
        self.emojiItems = emojiItems
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func getPayloads(completionHandler: @escaping ([PeopleSearchTableViewCell.PayloadType]?) -> Void) -> PayloadTask? {
        completionHandler(emojiItems)
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = collection[indexPath.row]
        navigationController?.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
        let viewController = UserProfileViewController(user: user)
        
        FirbaseAnalytics.logEvent(.clickProfileIcon)

        // HACK
        dismiss(animated: true)
        if let navigationController = presentingViewController as? UINavigationController {
            viewController.isNavigationBarHiddenOnParent = navigationController.navigationBar.isHidden
            navigationController.pushViewController(viewController, animated: true)
        } else if let tabBarController = presentingViewController as? TabBarController {
            if let navController = tabBarController.children[tabBarController.selectedIndex] as? UINavigationController {
                viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
                navController.pushViewController(viewController, animated: true)
            }
        }
    }
    
}
