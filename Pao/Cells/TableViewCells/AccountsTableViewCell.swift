//
//  AccountsTableViewCell.swift
//  Pao
//
//  Created by MACBOOK PRO on 17/05/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit

class AccountsTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var headLabel: UILabel!
    @IBOutlet private var actionLabel: UILabel!
    
    // MARK: - Private properties
    
    private var dateString: String {
        guard let createdOn = DataContext.cache.user.createdOn else { return "nil" }
        return String(createdOn.prefix(16).suffix(11))
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.textColor = .darkGray
        headLabel.textColor = .lightGray
        headLabel.font = UIFont.appMedium.withSize(UIFont.sizes.large)
        titleLabel.set(fontSize: UIFont.sizes.small)
    }
    
    // MARK: - Internal methods
    
    func set(type: String?) {
        switch type {
        case "subscription":
            setLabels(title: L10n.AccountsTableViewCell.labelSubscription, head: L10n.AccountsTableViewCell.labelPremium, action: L10n.AccountsTableViewCell.actionViewSubscriptionOptions)
        case "profile":
            setLabels(title: L10n.AccountsTableViewCell.labelProfileType, head: L10n.AccountsTableViewCell.labelPersonal, action: L10n.AccountsTableViewCell.actionSwitchToBusinessProfile)
        case "account":
            setLabels(title: L10n.AccountsTableViewCell.labelAccountInfo, head: "\(L10n.AccountsTableViewCell.labelCreatedOn) " + dateString, action: L10n.AccountsTableViewCell.actionDeleteAccount)
        default:
            break
        }
    }
    
    // MARK: - Private methods
    
    private func setLabels(title: String?, head: String,action: String) {
        titleLabel.text = title
        headLabel.text = head
        actionLabel.text = action
        underline()
    }
    
    private func underline() {
        guard let text = actionLabel.text else { return }
        actionLabel.attributedText = NSAttributedString(
            string: text,
            attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
}
