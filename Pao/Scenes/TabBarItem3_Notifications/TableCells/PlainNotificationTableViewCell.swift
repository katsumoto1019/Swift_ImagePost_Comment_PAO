//
//  PlainNotificationTableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 18/12/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class PlainNotificationTableViewCell: UITableViewCell, Consignee {

    @IBOutlet weak var titleLabel: UILabel!
    
    private var notification: PushNotification<PlainNotification>? = nil;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(_ notification: PushNotification<PlainNotification>) {
        self.notification = notification;
        
        titleLabel.text = notification.payload?.title;
    }
}
