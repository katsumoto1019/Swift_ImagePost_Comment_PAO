//
//  LogoutTableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 07/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase;

class LogoutTableViewCell: UITableViewCell {
    @IBOutlet weak var logoutButton: GradientButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        logoutButton.setGradient(topGradientColor: ColorName.gradientTop.color, bottomGradientColor: ColorName.gradientBottom.color);
        logoutButton.layer.opacity = 0.82;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func logout(_ sender: Any) {
        signOut();
    }
    
    func signOut() {
        do {
            Messaging.messaging().unsubscribe(fromTopic: Auth.auth().currentUser?.uid ?? "")
            //Messaging.messaging().unsubscribe(fromTopic: PNTopics.playlistUpdate.rawValue) // no need to unsub (not user specific) [EG]
            //Messaging.messaging().unsubscribe(fromTopic: PNTopics.forceUpdate.rawValue) // no need to unsub (not user specific) [EG]
            try Auth.auth().signOut();
            AmplitudeAnalytics.logOut()
            AppDelegate.startAccountFlow()
        }
        catch {
            print("Error signing out");
        }
    }
}
