//
//  NotificationViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/27/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class NotificationViewCell: UserViewCell, Consignee {
    @IBOutlet weak var thumbnailImageView: UIImageView!
  
    weak var delegate: UIViewController?
    private var notification: PushNotification<SpotNotification>? = nil
    @IBOutlet weak var thumbnailImageHeightConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImageView.isUserInteractionEnabled = false
        let profileTapGestureRecongizer = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        contentView.addGestureRecognizer(profileTapGestureRecongizer)
        
        profileImageView.isUserInteractionEnabled = false
        
        let thumbnailTapGestureRecongizer = UITapGestureRecognizer(target: self, action: #selector(showSpot))
        thumbnailImageView.addGestureRecognizer(thumbnailTapGestureRecongizer)
        thumbnailImageView.isUserInteractionEnabled = true
        
        // override UIAppearance so it doesn't reset text style.
        titleLabel.font = nil
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
        
        if let thumbnailUrl = notification.payload?.spot?.media?.url {
            thumbnailImageView.kf.setImage(with: thumbnailUrl)
            thumbnailImageView.isHidden = false
            thumbnailImageHeightConstraint.constant = 65
        } else {
            thumbnailImageView.isHidden = true
            thumbnailImageHeightConstraint.constant = 0
        }
        
        var titleString = ""
        switch notification.type! {
        case .save:
            titleString = L10n.NotificationViewCell.labelSavedYourGem
            break
        case .comment:
            titleString = L10n.NotificationViewCell.labelMentionedYouInComment
            break
        case .follow:
            titleString = L10n.NotificationViewCell.labelAddedYouToTheirPeople
            break
        case .spotcomment:
            titleString = L10n.NotificationViewCell.labelCommentedOnYourGem
            break
        case .verify:
            titleString = L10n.NotificationViewCell.labelVerifiedYourGem
            break
        case .followRequestAccepted:
            titleString = L10n.NotificationViewCell.labelAcceptedYourRequest
            break
        default:    
            break
        }
        
        let formattedString = NSMutableAttributedString()
        formattedString.bold(notification.payload?.user?.name ?? "").normal(" " + titleString)
        titleLabel.attributedText = formattedString
        
        subTitleLabel.text = notification.timestamp?.timeElapsedString(suffix: "", isShort: true)
    }
    
    @objc func showProfile() {
        FirbaseAnalytics.logEvent(.notifyToProfile)
        AmplitudeAnalytics.logEvent(.notifyToProfile, group: .notifications)
        
        if let user = notification?.payload?.user {
            if let navController = delegate?.navigationController {
                navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
                let viewController = UserProfileViewController(user: User(user: user))
                viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
                navController.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @objc func showSpot() {
        if let spotId = notification?.payload?.spot?.id {
            FirbaseAnalytics.logEvent(.notifyToSpot)
            AmplitudeAnalytics.logEvent(.notifyToSpot, group: .notifications)

            let manualSpotsViewController = ManualSpotsViewController.init(spotId: spotId)
            manualSpotsViewController.title = notification?.payload?.spot?.location?.name
            manualSpotsViewController.showCommentsOnLoad = notification!.type! == .comment || notification!.type! == .spotcomment
            delegate?.navigationController?.pushViewController(manualSpotsViewController, animated: true)
        }
    }
}

protocol NotificationViewCellDelegate: class {
    func showSpot(spotRef: SpotRef)
    func showProfile(userId: String)
}

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Avenir-Medium", size: 14)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Avenir", size: 14)!]
        let normal = NSAttributedString(string: text, attributes: attrs)
        append(normal)
        
        return self
    }
}
