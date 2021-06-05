//
//  RefreshControl.swift
//  Pao
//
//  Created by Parveen Khatkar on 17/10/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RefreshControl: UIRefreshControl {

    private let refreshIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .circleStrokeSpin, color: ColorName.textGray.color, padding: 8)
    
    override init() {
        super.init();
        
        initialize();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        initialize();
    }
    
    private func initialize() {
        refreshIndicator.startAnimating();
        addSubview(refreshIndicator);
        refreshIndicator.translatesAutoresizingMaskIntoConstraints = false;
        refreshIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true;
        refreshIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true;
        refreshIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true;
        refreshIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true;
        
        tintColor = .clear;
    }
}
