//
//  KeySwitchTableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 10/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class KeySwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueSwitch: UISwitch!
    
    private var valueChanged: ((_ value: Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        keyLabel.set(fontSize: UIFont.sizes.normal);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func set(key: String, value: Bool, valueChanged: @escaping (_ value: Bool) -> Void) {
        keyLabel.text = key;
        valueSwitch.isOn = value;
        self.valueChanged = valueChanged;
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        valueChanged?(valueSwitch.isOn);
    }
}
