//
//  ChecklistItemTableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 17/12/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class ChecklistItemTableViewCell: UITableViewCell, Consignee {

    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var todoLabel: UILabel!
    @IBOutlet weak var todoView: UIView!
    @IBOutlet weak var todoViewHeightConstraint: NSLayoutConstraint!
    
    private var notification: PushNotification<ChecklistNotification>? = nil;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.textColor = ColorName.textWhite.color
        titleLabel.font = UIFont.appNormal.withSize(UIFont.sizes.medium)
        checkboxButton.isUserInteractionEnabled = false
        showTodo(show: false)
        todoLabel.text = L10n.ChecklistItemTableViewCell.todoLabel
        todoLabel.font = UIFont.appMedium.withSize(UIFont.sizes.large)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func showTodo(show: Bool) {
        todoViewHeightConstraint.constant = show ? 60 : 0
        todoView.isHidden = !show
    }
    
    func set(_ notification: PushNotification<ChecklistNotification>) {
        self.notification = notification;
        guard let mainString: String = notification.payload?.title else { return }
        //titleLabel.text = notification.payload?.title;
        let aryWords: [String] = mainString.components(separatedBy: " ")
        var word: String? = aryWords.first
        if mainString.lowercased() == "scroll through 5 hidden gems" {
            word = "\(aryWords[0]) \(aryWords[1])"
            showTodo(show: true)
        } else {
            showTodo(show: false)
        }
        let range: NSRange = (mainString as NSString).range(of: word!)
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string:mainString)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: ColorName.accent.color, range: range)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.appMedium.withSize(UIFont.sizes.medium), range: range)
        titleLabel.attributedText = attributedString

        checkboxButton.isSelected = notification.payload?.isDone == true
    }
}
