//
//  LocationNotificationCell.swift
//  Pao
//
//  Created by OmShanti on 01/12/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit
import RocketData
import Payload

class LocationNotificationCell: UITableViewCell, Consignee {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var GoButton: GradientButton!
    
    private var spot: Spot!
    private var notification: PushNotification<LocationNotification>!
    weak var delegate: YourLocationSpotTableViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.font = UIFont.appBold.withSize(UIFont.sizes.small)
        descriptionLabel.textColor = ColorName.accent.color
        timeLabel.font = UIFont.appNormal.withSize(UIFont.sizes.verySmall)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonGo_Tapped(_ sender: Any) {
        FirbaseAnalytics.logEvent(.bizNotifyGo)
        let notificationId = notification.id ?? ""
        let bizUsername = spot.user?.username ?? ""
        let spotLocationName = spot.location?.name ?? ""
        let postId = spot.id ?? ""
        let properties = ["notification ID":notificationId, "biz username":bizUsername, "spot location name":spotLocationName, "post id": postId]
        AmplitudeAnalytics.logEvent(.go, group: .notifications, properties: properties)
        
        delegate?.showGo(spot: spot)
    }
    
    func set(_ notification: PushNotification<LocationNotification>) {
        self.notification = notification
        if let spot = notification.payload?.spot {
            self.spot = spot
            GoButton.isHidden = spot.location == nil
            if let media = spot.media?.values.sorted(by: {$0.index ?? 0 < $1.index ?? 0}).first,
               let url = media.type == 0 ? media.url : media.thumbnailUrl {
                postImage.kf.setImage(with: url)
            }
        }
        if let title = notification.payload?.title {
            titleLabel.text = title
        }
        if let description = notification.payload?.description {
            descriptionLabel.text = description
        }
        timeLabel.text = notification.timestamp?.timeElapsedString(suffix: "", isShort: true)
    }
}
