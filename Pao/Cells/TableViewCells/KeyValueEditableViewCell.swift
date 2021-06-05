//
//  KeyValueEditableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/21/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class KeyValueEditableViewCell: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueTextField: UITextField!
    
    private var valueChanged: ((_ value: String?) -> Void)?
    private var changedValue = false;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(key: String, value: String?, keyboardType: UIKeyboardType, valueChanged: @escaping (_ value: String?) -> Void) {
        keyLabel.text = key;
        valueTextField.text = value;
        valueTextField.keyboardType = keyboardType;
        
        self.valueChanged = valueChanged;
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        if (!changedValue) {
            changedValue = true;
//            FirbaseAnalytics.trackEvent(category: .uiAction, action: .buttonPress, label: EventLabel(rawValue: keyLabel.text!)!);
        }
        
        valueChanged?(valueTextField.text);
    }
}
