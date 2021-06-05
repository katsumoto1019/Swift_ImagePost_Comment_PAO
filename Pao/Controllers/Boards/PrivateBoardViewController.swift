//
//  EmptyBoardViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 01/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class PrivateBoardViewController: BaseViewController {
    
    private let nvActivityIndicator = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type: .circleStrokeSpin, color:ColorName.textGray.color, padding: 8);
    private var messageLabel = UILabel(frame: CGRect(x: 0, y: 20, width: 280, height: 100));

    var message: String?
    
    init(message: String?) {
        super.init(nibName: nil, bundle: nil);
        
        self.message = message;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
    
        view.addSubview(messageLabel);
        view.addSubview(nvActivityIndicator);
        
        if self.message == nil {
            nvActivityIndicator.startAnimating();
        }
        messageLabel.text = message;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        let center = CGPoint.init(x: view.bounds.midX, y: view.bounds.midY);
        messageLabel.center = center;
        nvActivityIndicator.center = center;
    }
    
    override func applyStyle() {
        super.applyStyle();
        
        view.backgroundColor = ColorName.background.color
        
        messageLabel.font = UIFont.app.withSize(UIFont.sizes.normal);
        messageLabel.textColor = UIColor.lightGray;
        messageLabel.textAlignment = .center;
        messageLabel.numberOfLines = 0;
    }
}
