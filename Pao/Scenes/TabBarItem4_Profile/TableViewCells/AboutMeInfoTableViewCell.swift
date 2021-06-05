//
//  AboutMeInfoTableViewCell.swift
//  Pao
//
//  Created by Exelia Technologies on 05/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class AboutMeInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var topKeyLabel: UILabel!
    @IBOutlet weak var topValueTextField: UITextField!
    @IBOutlet weak var middleKeyLabel: UILabel!
    @IBOutlet weak var middleValueTextField: UITextField!
    @IBOutlet weak var bottomKeyLabel: UILabel!
    @IBOutlet weak var bottomValueTextField: UITextField!
    
    private var topValueChanged: ((String?) -> Void)?;
    private var middleValueChanged: ((String?) -> Void)?;
    private var bottomValueChanged: ((String?) -> Void)?;

    override func awakeFromNib() {
        super.awakeFromNib()
        
        topValueTextField.delegate = self;
        middleValueTextField.delegate = self;
        
        topValueTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        middleValueTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        bottomValueTextField.isUserInteractionEnabled = false;
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.05);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        // REF: https://medium.com/@andersongusmao/left-and-right-margins-on-uitableviewcell-595f0ba5f5e6
        contentView.frame.inset(by: UIEdgeInsets(top: 0, left: contentView.layoutMargins.left, bottom: 0, right: contentView.layoutMargins.right));
    }
    
    func set(topKey: String, topValue: String?, topValuePlaceholder: NSAttributedString?, topKeyboardType: UIKeyboardType, topValueChanged: @escaping (String?) -> Void,
             middleKey: String, middleValue: String?, middleValuePlaceholder: NSAttributedString?, middleKeyboardType: UIKeyboardType, middleValueChanged: @escaping (String?) -> Void,
             bottomKey: String, bottomValue: String?, bottomValuePlaceholder: NSAttributedString?, bottomKeyboardType: UIKeyboardType, bottomValueChanged: @escaping (String?) -> Void) {
        self.topValueChanged = topValueChanged;
        self.middleValueChanged = middleValueChanged;
        self.bottomValueChanged = bottomValueChanged;
        
        style(topKeyboardType: topKeyboardType, middleKeyboardType: middleKeyboardType, bottomKeyboardType: bottomKeyboardType);
        
        topKeyLabel.text = topKey;
        middleKeyLabel.text = middleKey;
        bottomKeyLabel.text = bottomKey;
        
        setValue(textField: topValueTextField, value: topValue, valuePlaceholder: topValuePlaceholder);
        setValue(textField: middleValueTextField, value: middleValue, valuePlaceholder: middleValuePlaceholder);
        setValue(textField: bottomValueTextField, value: bottomValue, valuePlaceholder: bottomValuePlaceholder);
    }
    
    private func setValue(textField: UITextField, value: String?, valuePlaceholder: NSAttributedString?) {
        if let value = value {
            textField.text = value;
        } else {
            textField.attributedPlaceholder = valuePlaceholder;
        }
    }
    
    private func style(topKeyboardType: UIKeyboardType, middleKeyboardType: UIKeyboardType, bottomKeyboardType: UIKeyboardType) {
        topValueTextField.keyboardType = topKeyboardType;
        middleValueTextField.keyboardType = middleKeyboardType;
        bottomValueTextField.keyboardType = bottomKeyboardType;
        
        let keyTextColor = UIColor.lightGray;
        topKeyLabel.textColor = keyTextColor;
        middleKeyLabel.textColor = keyTextColor;
        bottomKeyLabel.textColor = keyTextColor;
        
        let valueFont = UIFont.boldSystemFont(ofSize: 13.0);
        topValueTextField.font = valueFont;
        middleValueTextField.font = valueFont;
        bottomValueTextField.font = valueFont;
        
        let valueReturnKeyType = UIReturnKeyType.done;
        topValueTextField.returnKeyType = valueReturnKeyType;
        middleValueTextField.returnKeyType = valueReturnKeyType;
        bottomValueTextField.returnKeyType = valueReturnKeyType;
    }
    
    private func valueChanged(_ valueTextField: UITextField, keyLabel: UILabel, valueChanged: ((String?) -> Void)?) {
        valueChanged?(valueTextField.text);
    }
}

extension AboutMeInfoTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        
        return true;
    }
    
   @objc func textFieldDidChange(_ textField: UITextField) {
        switch (textField) {
        case topValueTextField: valueChanged(textField, keyLabel: topKeyLabel, valueChanged: topValueChanged); break;
        case middleValueTextField: valueChanged(textField, keyLabel: middleKeyLabel, valueChanged: middleValueChanged); break;
        case bottomValueTextField: valueChanged(textField, keyLabel: bottomKeyLabel, valueChanged: bottomValueChanged); break;
        default: break;
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
//        FirbaseAnalytics.trackEvent(category: .uiAction, action: .enterText, label: textField == topValueTextField ? .name : textField == middleValueTextField ? .username : .email);
    }
}
