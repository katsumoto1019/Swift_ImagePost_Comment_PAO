//
//  ConnectivityHelper.swift
//  Pao DEV
//
//  Created by Waseem Ahmed on 04/06/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Foundation
import Reachability
import RocketData

class ReachabilityService {
    
    private var reachability:Reachability?
    private var messageView: UIView?
    
    init() {
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        stopNotifier()
    }
    
    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
    }
    
    func isOnline() -> Bool {
        return reachability == nil ? true : (reachability!.connection != .unavailable)
    }
    
    private func setup() {
        let size = UIApplication.shared.statusBarFrame.size;
        let labelHeight:CGFloat = 20
        let messagelabel = UILabel(frame: CGRect.init(x: 0, y: 0, width: size.width, height: labelHeight))
        messagelabel.backgroundColor = .clear
        messagelabel.textAlignment = .center
        messagelabel.textColor = .white
        messagelabel.font = UIFont.app
        messagelabel.text = L10n.ReachabilityService.youAreOffline
        
        messageView = UIView(frame: CGRect.init(origin: CGPoint.zero, size: messagelabel.bounds.size))
        messageView?.backgroundColor = ColorName.reachabilityMessageView.color
        messageView?.addSubview(messagelabel)
        
        self.reachability = try! Reachability()
        
        reachability?.whenReachable = { reachability in
            self.networkStatusChanged(reachability: reachability)
        }
        reachability?.whenUnreachable = { reachability in
            self.networkStatusChanged(reachability: reachability)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarFrameDidChangeCallback(notification:)), name:  UIApplication.didChangeStatusBarFrameNotification, object: nil)
    }
    
    @objc func statusBarFrameDidChangeCallback(notification: Notification) {
        if messageView != nil, messageView!.superview != nil, messageView!.frame.origin.y != 0,
         let mainView = UIApplication.shared.keyWindow?.subviews.first {
            messageView?.frame.origin.y = UIApplication.shared.statusBarFrame.size.height;
            mainView.frame = UIApplication.shared.keyWindow!.bounds.inset(by: UIEdgeInsets.init(top: messageView!.frame.maxY, left: 0, bottom: 0, right: 0));
            UIApplication.shared.keyWindow?.layoutIfNeeded()
        }
    }
    
    private func networkStatusChanged(reachability: Reachability) {
        switch reachability.connection {
        case .cellular, .wifi:
            print("Network Availability : TRUE")
            noConnectivityMessage(show: false)
            NotificationCenter.default.post(name: .networkStuatusChanged, object: true)
            break;
        case .none, .unavailable:
            print("Network Availability : FALSE")
            noConnectivityMessage(show: true)
            NotificationCenter.default.post(name: .networkStuatusChanged, object: false)
            break;
        }
        
        let dataProvider = DataProvider<NetworkStatus>();
        dataProvider.setData(NetworkStatus.init(status: reachability.connection != .unavailable));
    }
    
    func noConnectivityMessage(show: Bool) {
        DispatchQueue.main.async {
            self.messageView?.layer.removeAllAnimations()
            
            //Remove view with animation
            guard show else {
                if let mainView = UIApplication.shared.keyWindow?.subviews.first, self.messageView?.superview != nil {
                    mainView.frame = UIApplication.shared.keyWindow!.bounds.inset(by: UIEdgeInsets.init(top:UIApplication.shared.statusBarFrame.size.height, left: 0, bottom: 0, right: 0));
                    UIApplication.shared.keyWindow?.layoutSubviews()
                    UIApplication.shared.keyWindow?.layoutIfNeeded()
                }
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.messageView?.frame.origin.y = -self.messageView!.frame.maxY;
                    
                }) { (status) in
                    self.messageView?.removeFromSuperview()
                    self.messageView?.frame.origin.y = 0;
                    
                    if #available(iOS 13.0, *) {}
                    else {
                        UIApplication.shared.statusBarView?.backgroundColor = ColorName.navigationBarTint.color
                    }
                    
                    UIApplication.shared.keyWindow?.layoutIfNeeded()
                }
                return;
            }
            
            let size = UIApplication.shared.statusBarFrame.size
            if size.height > 24 {
                self.messageUnderStatusBar()
            } else {
                let paoAlert = PaoAlertController(title: L10n.ReachabilityService.PaoAlert.title, subTitle: L10n.ReachabilityService.PaoAlert.subTitle);
                paoAlert.addButton(title: L10n.Common.gotIt) {
                    self.messageUnderStatusBar();
                }
                if let rootViewVC = UIApplication.shared.keyWindow?.rootViewController{
                    paoAlert.show(parent: rootViewVC);
                }
            }
        }
    }

    private func messageUnderStatusBar() {
        messageView?.frame.origin.y = UIApplication.shared.statusBarFrame.size.height;
        
        if #available(iOS 13.0, *) {}
        else {
            UIApplication.shared.statusBarView?.backgroundColor = .red
        }
        
        if let mainView = UIApplication.shared.keyWindow?.subviews.first {
            messageView?.frame.origin.y = UIApplication.shared.statusBarFrame.size.height;
             mainView.frame = UIApplication.shared.keyWindow!.bounds.inset(by: UIEdgeInsets.init(top:  messageView!.frame.maxY, left: 0, bottom: 0, right: 0));
        }
        
        UIApplication.shared.keyWindow?.addSubview(messageView!)
        messageView?.layer.zPosition = 1
        UIApplication.shared.keyWindow?.bringSubviewToFront(messageView!)
    }
    
    private func messageOverStatusBar() {
        
          if #available(iOS 13.0, *) {}
          else {
            let statusBar = UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow
        
            messageView?.frame.origin.y = 0;
            statusBar?.addSubview(messageView!)
            statusBar?.bringSubviewToFront(messageView!)
        }
    }
}
