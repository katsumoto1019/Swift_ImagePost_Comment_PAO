//
//  AccountViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/6/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class AccountViewController: BaseViewController {
    
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var joinNowButton: RoundCornerButton!
    @IBOutlet weak var logInButton: RoundCornerButton!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        screenName = "Home";
        
        // Do any additional setup after loading the view.
        initialSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        navigationController?.isNavigationBarHidden = true;
        if let mosaicController = self.navigationController?.parent as? MosaicCollectionViewController {
            mosaicController.shouldAutoScroll = true;
            mosaicController.collectionView.alpha = 0.3;
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        navigationController?.isNavigationBarHidden = false;
        if let mosaicController = self.navigationController?.parent as? MosaicCollectionViewController {
            mosaicController.shouldAutoScroll = false;
             mosaicController.collectionView.alpha = 0.1;
        }
    }
    
     func initialSetup() {
        gradientView.gradientColors = [UIColor.black.withAlphaComponent(0.0),UIColor.black.withAlphaComponent(0.9),UIColor.black, UIColor.black];
        joinNowButton.setTitle(L10n.AccountViewController.joinNowButton, for: .normal)
        logInButton.setTitle(L10n.AccountViewController.logInButton, for: .normal)
        descriptionLabel.text = L10n.AccountViewController.descriptionLabel
        subTitleLabel.text = L10n.AccountViewController.subTitleLabel
    }
    
    override func applyStyle() {
        super.applyStyle();
        
        self.subTitleLabel.set(fontSize: UIFont.sizes.large);
        self.descriptionLabel.set(fontSize: UIFont.sizes.normal - 1);
    }
    
    
    @IBAction func register(_ sender: Any) {
        AmplitudeAnalytics.logEvent(.chooseRegister, group: .onBoarding)
        
       let viewController = RegisterViewController();
       navigationController?.pushViewController(viewController, animated: true);
        // let viewController = OnboardingPageViewController();
        // viewController.modalTransitionStyle = .flipHorizontal;
        // present(viewController, animated: true, completion: nil);
    }
    
    @IBAction func login(_ sender: Any) {
        let viewController = LoginViewController();
        navigationController?.pushViewController(viewController, animated: true);
    }
    
}
