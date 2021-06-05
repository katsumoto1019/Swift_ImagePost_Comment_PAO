//
//  GoTableViewCell.swift
//  Pao
//
//  Created by Waseem Ahmed on 03/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class GoBaseTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        applyStyle();
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func applyStyle() {
        addSideBar();
        addSideBar(isRight: true);
        backgroundColor = UIColor.white.withAlphaComponent(0.05);
    }
    
    /// To be overriden by chid classes
    ///
    /// - Parameters:
    ///   - spot: Spot object
    ///   - placeDetails: PlaceDetailsResult object
    func set(spot: Spot, placeDetails: PlaceDetailsResult?) {
        
    }
    
    /// Add sidebar for the cell
    ///
    /// - Parameter isRight: indicates to add the bar on ride side.
    private func addSideBar(isRight: Bool = false) {
    
        //width of side bar
        let width = 3;
        
        let leftBar = UIView.init();
        leftBar.backgroundColor = ColorName.accent.color
        leftBar.translatesAutoresizingMaskIntoConstraints = false;
        addSubview(leftBar);
        
        let viewlabel = isRight ? "rightBar" : "leftBar";
        let horizontalFormateStr = isRight ? "H:[\(viewlabel)(\(width))]-0-|" : "H:|-0-[\(viewlabel)(\(width))]";
        let verticalFormateStr = "V:|-0-[\(viewlabel)]-0-|";
        
        let views:[String:UIView] = ["\(viewlabel)":leftBar];
        var allConstraints: [NSLayoutConstraint] = [];
        
        let barHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: horizontalFormateStr,
            metrics: nil,
            views: views);
        allConstraints += barHorizontalConstraints;
        
        let barVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: verticalFormateStr,
            metrics: nil,
            views: views);
        allConstraints += barVerticalConstraints;
        
        NSLayoutConstraint.activate(allConstraints);
    }
}
