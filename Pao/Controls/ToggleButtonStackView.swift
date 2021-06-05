//
//  ToggleButtonStackView.swift
//  Pao
//
//  Created by Parveen Khatkar on 5/7/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class ToggleButtonStackView: UIStackView {
    
    weak var delegate: ToggleButtonStackViewDelegate?
    var buttons = [UIButton]();
    
    var selectedOption: String? {
          get {
              return (subviews as! [UIButton]).first(where: {$0.isSelected})?.currentTitle;
          }
          set {
              (subviews as! [UIButton]).forEach({$0.isSelected = $0.currentTitle == newValue });
          }
      }
    
    var options: [String]? {
        didSet {
            arrangedSubviews.forEach({
                removeArrangedSubview($0)
                $0.removeFromSuperview()
            });
            options?.forEach({ (option) in
                let button = CircularToggleButton(type: .custom);
                button.delegate = self;
                button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true;
                button.setTitle(option, for: UIControl.State.normal);
                buttons.append(button);
                self.addArrangedSubview(button);
            })
        }
    }
}

extension ToggleButtonStackView: ToggleButtonDelegate {
    @objc func toggled(_ sender: UIButton) {
        (subviews as! [UIButton]).forEach { (button) in
            if button != sender {
                button.isSelected = false;
            }
        }
        delegate?.selectionChanged(title: sender.titleLabel?.text, isSelected: sender.isSelected);
    }
}

protocol ToggleButtonStackViewDelegate: class {
    func selectionChanged(title: String?, isSelected: Bool);
}
