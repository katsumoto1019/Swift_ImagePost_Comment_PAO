//
//  LaunchScreenViewController.swift
//  Pao
//
//  Created by MACBOOK PRO on 31/10/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit

class LogoAnimViewController: UIViewController {
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoImageView.layer.minificationFilter = .trilinear
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func animate(delay: TimeInterval = 0.0, callback: @escaping () -> Void) {
        
        UIView.animate(withDuration: 0.2,
                       delay: delay,
                       options: [.curveEaseIn],
                       animations: {
                        self.logoImageView.transform = CGAffineTransform(scaleX: 0.83, y: 0.83)
        }) { (status) in
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: [.curveEaseIn],
                           animations: {
                            self.logoImageView.center = CGPoint(x: self.logoImageView.center.x, y:self.logoImageView.center.y)
                            self.logoImageView.transform = CGAffineTransform(scaleX: 12.0, y: 12.0)
            }, completion: { (status) in
                self.logoImageView.isHidden = true
                callback()
            })
        }
    }
}
