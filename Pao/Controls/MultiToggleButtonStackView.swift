//
//  MultiToggleButtonStackView.swift
//  Pao
//
//  Created by Waseem Ahmed on 21/10/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit

class MultiToggleButtonStackView: ToggleButtonStackView {
    
//   override var buttons = [MultiToggleButton]();
    
   override var selectedOption: String? {
            get {
                return (subviews as! [UIButton]).first(where: {$0.isSelected})?.currentTitle;
            }
            set {
                (subviews as! [UIButton]).forEach({$0.isSelected = $0.currentTitle == newValue });
            }
        }
    
     var secondarySelectedOptions: [String]? {
             get {
                return (subviews as! [CircularToggleButton]).filter({$0.secondarySelected}).compactMap({ ($0.currentTitle) });
             }
             set {
                (subviews as! [CircularToggleButton]).forEach({$0.secondarySelected = newValue?.contains($0.currentTitle ?? "N/A") ?? false })
             }
         }
    
//  override var options: [String]? {
//        didSet {
//            arrangedSubviews.forEach({removeArrangedSubview($0)});
//            options?.forEach({ (option) in
//                let button = MultiToggleButton(type: .custom);
//                button.delegate = self;
//                button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true;
//                button.setTitle(option, for: UIControl.State.normal);
//                buttons.append(button);
//                self.addArrangedSubview(button);
//            })
//        }
//    }
    
    override func toggled(_ sender: UIButton) {
        (subviews as! [UIButton]).forEach { (button) in
            if button != sender {
                button.isSelected = false;
            }
        }
        delegate?.selectionChanged(title: sender.titleLabel?.text, isSelected: sender.isSelected);
    }
}
