//
//  BaseViewController.swift
//  Pao
//
//  Created by Developer on 3/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    // MARK: - Internal properties
    
    static var activeViewControllerType: UIViewController.Type?
    var screenName = String.empty
    
    // MARK: - Private properties
    
    private var activityIndicator: UIActivityIndicatorView?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(notification:)),
            name: .networkStuatusChanged,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        FirbaseAnalytics.trackScreen(name: screenName)
        
        applyStyle()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        BaseViewController.activeViewControllerType = type(of: self)
        
        //FirbaseAnalytics.trackScreen(name: screenName, screenClass: classForCoder.description())
    }
    
    // MARK: - Internal methods
    
    func applyStyle() {
        view.backgroundColor = ColorName.background.color
    }
    
    func startActivityIndicator() {
        let screenSize: CGRect = UIScreen.main.bounds
        
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        activityIndicator?.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        activityIndicator?.center = view.center
        activityIndicator?.hidesWhenStopped = true
        activityIndicator?.style = UIActivityIndicatorView.Style.white
        
        // Change background color and alpha channel here
        activityIndicator?.backgroundColor = UIColor.black
        activityIndicator?.clipsToBounds = true
        activityIndicator?.alpha = 0.5
        
        view.addSubview(self.activityIndicator!)
        activityIndicator?.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopActivityIndicator() {
        activityIndicator?.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    func networkChanged(online: Bool) {}
    
    // MARK: - Actions
    
    @IBAction private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Private methods
    
    private func closeLastNViewControllers(n: Int) {
        
        guard let navigationController = navigationController else { return }
        
        var controllers = navigationController.viewControllers
        controllers.removeLast(n)
        navigationController.setViewControllers(controllers, animated: true)
    }
    
    @objc
    private func networkStatusChanged(notification: Notification) {
        guard let status = notification.object as? Bool else { return }
        networkChanged(online: status)
    }
}
