//
//  MultiSelectButtonStackView.swift
//  Pao
//
//  Created by MACBOOK PRO on 22/08/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit

class MultiSelectButtonStackView: ToggleButtonStackView {

    weak var multiSelectDelegate: MultiSelectStackViewDelegate?
    var filters = [String]();
    
    override func toggled(_ sender: UIButton) {
       
        if (sender.isSelected)
        {
            filters.append(sender.titleLabel!.text!);
        }
        else
        {
            filters.remove(at: filters.firstIndex(of: sender.titleLabel!.text!)!);
        }
        multiSelectDelegate?.addFilters(selectedFilters: filters);
        multiSelectDelegate?.selectionChanged(title: sender.currentTitle, isSelected: sender.isSelected)
    }
    
    public func selectCategories(categories: [String])
    {
        filters.removeAll();
        buttons.forEach {
            if (categories.contains($0.titleLabel!.text!))
            {
                $0.isSelected = true;
                filters = categories;
            }
        };
    }
}

protocol MultiSelectStackViewDelegate: class {
    func addFilters(selectedFilters: [String]);
     func selectionChanged(title: String?, isSelected: Bool);

}

extension MultiSelectStackViewDelegate {
    func selectionChanged(title: String?, isSelected: Bool) {
        //this is a empty implementation to allow this method to be optional
    }
}
