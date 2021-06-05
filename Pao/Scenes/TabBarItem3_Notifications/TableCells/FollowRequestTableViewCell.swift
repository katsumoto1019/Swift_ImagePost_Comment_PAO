//
//  FollowRequestTableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 18/12/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class FollowRequestTableViewCell: UITableViewCell, Consignee {
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak internal var rejectButton: UIButton!
    @IBOutlet weak var subTitleLabel: UILabel!
    
    weak var delegate: UIViewController?
    private var notification: PushNotification<SpotNotification>? = nil
    private var indexPath:IndexPath = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //actionButton.layer.borderColor = ColorName.textWhite.color.cgColor
        //actionButton.layer.borderWidth = 0.5
        
        //rejectButton.layer.borderColor = UIColor.red.cgColor as! CGColor
        //rejectButton.layer.borderWidth = 0.5
        //rejectButton.setTitleColor(UIColor.red, for: .normal)
        
        profileImageView.isUserInteractionEnabled = false
        let profileTapGestureRecongizer = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        contentView.addGestureRecognizer(profileTapGestureRecongizer)
        
        applyStyles()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(_ notification: PushNotification<SpotNotification>) {
        self.notification = notification
        
        if let profileImageURL = notification.payload?.user?.profileImage?.url {
            profileImageView.kf.setImage(with: profileImageURL)
        } else {
            profileImageView.image = Asset.Assets.Icons.user.image
        }
        
        let formattedString = NSMutableAttributedString()
        formattedString.bold(notification.payload?.user?.name ?? "").normal(L10n.FollowRequestTableViewCell.string)
        titleLabel.attributedText = formattedString
        subTitleLabel.text = notification.timestamp?.timeElapsedString(suffix: "", isShort: true)
    }
    
    func setIndexPath(indexPath: IndexPath)
    {
        self.indexPath = indexPath
    }
    
    @IBAction func action(_ sender: Any) {
        let followRequest = FollowRequest()
        followRequest.notificationId = self.notification?.id
        followRequest.otherUserId = self.notification?.payload?.user?.id
        
        App.transporter.post(followRequest, to: FollowAction.accept) { (success) in
            if success == true {
                NotificationCenter.followRequest(indexPath: self.indexPath)
            } else {
            }
        }
    }
    
    @IBAction func rejectRequest(_ sender: Any) {
        let followRequest = FollowRequest()
        followRequest.notificationId = self.notification?.id
        followRequest.otherUserId = self.notification?.payload?.user?.id
        
        App.transporter.post(followRequest, to: FollowAction.reject) { (success) in
            if success == true {
                NotificationCenter.followRequest(indexPath: self.indexPath)
            } else {
                
            }
        }
    }
    
    @objc func showProfile() {
        if let user = notification?.payload?.user {
            FirbaseAnalytics.logEvent(.clickProfileIcon)
            if let navController = delegate?.navigationController {
                navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
                let viewController = UserProfileViewController(user: User(user: user))
                viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
                navController.pushViewController(viewController, animated: true)
            }
        }
    }
    
    func applyStyles() {
        
        subTitleLabel.set(fontSize: UIFont.sizes.verySmall)
    }
}

