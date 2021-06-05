//
//  OnboardingNavigationController.swift
//  Pao
//
//  Created by Parveen Khatkar on 14/11/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class OnboardingNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self;
        
        if #available(iOS 13.0, *) {}
        else {
            UIApplication.shared.statusBarView?.backgroundColor = .clear;
        }
        
        navigationBar.isTranslucent = true;
        navigationBar.setBackgroundImage(UIImage(), for: .default);
        navigationBar.shadowImage = UIColor.gray.withAlphaComponent(0.5).as1ptImage();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        if viewControllers.count > 0 {
            viewControllers[viewControllers.count - 1].view.backgroundColor = UIColor.clear;
        }
    }
    
    @objc func pop() {
        view.endEditing(true)
        popViewController(animated: true);
    }
    
    @discardableResult
    override func popViewController(animated: Bool) -> UIViewController? {
        if viewControllers.count > 1 {
            let lastViewController = viewControllers[viewControllers.count - 2];
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                lastViewController.view.alpha = 1;
            })
        }
        return super.popViewController(animated: animated);
    }
}

extension OnboardingNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.leftArrowNav.image,
            style: .plain,
            target: self,
            action: #selector(pop)
        )
        viewController.view.backgroundColor = .clear;
        
        if viewControllers.count <= 1 {return}
        let lastViewController = viewControllers[viewControllers.count - 2];
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            lastViewController.view.alpha = 0;
        })
    }
}
