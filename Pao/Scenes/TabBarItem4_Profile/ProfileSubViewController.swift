//
//  ProfileSubViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 22/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit


class ProfileSubViewController: SwipeMenuViewController {
    
    lazy var viewControllers: [UIViewController] = [
        PrivateBoardViewController(message: nil),
        PrivateBoardViewController(message: nil),
        PrivateBoardViewController(message: nil)
    ]
    
    var user: User?
    private var titles = [L10n.Common.titleGems, L10n.SettingsTableViewController.optionAbout, L10n.Common.labelSaves];
    
    var screenPrefix = "Profile" {
        didSet {
            
        }
    }
    
    var uploadBoardUpdated = false;
    var saveBoardUpdated = false;
    var followingUpdated = false;
    public var isUserProfile = false;
    weak var delegate: ProfileSubViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear;
        
        setupSwipe();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
                
        refreshData();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        FirbaseAnalytics.trackScreen(name: "\(screenPrefix) \(titles[swipeMenuView.currentIndex])");
    }
    
    private func setupSwipe(){
        var options = SwipeMenuViewOptions();
        options.tabView.style = .segmented;
        options.tabView.additionView.backgroundColor = UIColor.white;
        options.tabView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6);
        options.tabView.itemView.selectedTextColor = ColorName.textWhite.color
        options.tabView.itemView.textColor = ColorName.textWhite.color
        options.tabView.itemView.font =  UIFont.app.withSize(UIFont.sizes.verySmall + 1);
        options.tabView.clipsToBounds = false;
        swipeMenuView.reloadData(options:options);
        
        viewControllers.forEach({
            addChild($0);
            $0.didMove(toParent: self);
        });
    }
    
    func set(user: User?) {
        
        if user != nil {self.user = user;}
        
        //remove already added views
        viewControllers.forEach({
            $0.removeFromParent();
            $0.view.removeFromSuperview();
        });
        
        //Following check is valid also for nil user.
        if self.user?.id != DataContext.cache.user.id && self.user?.settings?.isPublic == false && !DataContext.cache.isSelectedInMyPeople(userId: self.user?.id) {
            viewControllers = [
                PrivateBoardViewController(message: user != nil ? L10n.ProfileSubViewController.privateBoardMessage : ""),
                PrivateBoardViewController(message: user != nil ? L10n.ProfileSubViewController.privateBoardMessage : ""),
                PrivateBoardViewController(message: user != nil ? L10n.ProfileSubViewController.privateBoardMessage : "")
            ]
        }
        else {
            if (user == nil)
            {
                return;
            }
            viewControllers = [
                UINavigationController(rootViewController: UploadBoardCollectionViewController(userId: self.user!.id!, isUserProfile: self.isUserProfile)),
                AboutMeTableViewController(user: self.user!),
                UINavigationController(rootViewController: SaveBoardCollectionViewController(userId: self.user!.id!,isUserProfile: self.isUserProfile))
            ]
        }
        
        viewControllers.forEach({
            addChild($0);
            $0.didMove(toParent: self);
            (($0 as? UINavigationController)?.viewControllers[0] as? UploadBoardCollectionViewController)?.delegate = self;
        });
        
        swipeMenuView.reloadData();
    }
    
    func refreshData(userUpdated: User? = nil) {
        self.user = userUpdated != nil ? userUpdated : self.user;
        if userUpdated != nil {
            if let tabView = self.swipeMenuView.tabView {
                tabView.reloadData(options: self.swipeMenuView.options.tabView);
                //(self.viewControllers[1] as! AboutMeTableViewController).updateCounters(user: self.user!);
                self.swipeMenuView.jump(to: self.swipeMenuView.currentIndex, animated: false);
            }
        }
        
        if self.user != nil, self.user!.id == DataContext.cache.user.id {
            if (uploadBoardUpdated || UploadBoardCollectionViewController.uploadInProgress), let navigationController = viewControllers[0] as? UINavigationController, let boardViewController = navigationController.viewControllers.first as? UploadBoardCollectionViewController {
                boardViewController.refresh();
            }
            
            if saveBoardUpdated, let navigationController = viewControllers[2] as? UINavigationController, let boardViewController = navigationController.viewControllers.first as? SaveBoardCollectionViewController {
                boardViewController.refresh();
            }
            
            if followingUpdated || uploadBoardUpdated || saveBoardUpdated {
                App.transporter.get(User.self) { (user) in
                    guard let user = user else {
                        return;
                    }
                    if  let tabView = self.swipeMenuView.tabView {
                        AmplitudeAnalytics.setUserProperties(user: user)
                        self.user = user;
                        
                        tabView.reloadData(options: self.swipeMenuView.options.tabView);
                        (self.viewControllers[1] as! AboutMeTableViewController).updateCounters(user: user);
                        self.swipeMenuView.jump(to: self.swipeMenuView.currentIndex, animated: false);
                    }
                }
                saveBoardUpdated = false; uploadBoardUpdated = false; followingUpdated = false;
            }
        }
    }
    
    // MARK: - SwipeMenuViewDataSource
    
    override func numberOfPages(in swipeMenuView: SwipeMenuView) -> Int {
        select(tabAtIndex: swipeMenuView.currentIndex);
        return titles.count;
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, titleForPageAt index: Int) -> String {
        switch index {
        case 0: return String(format: "%d %@", user?.uploadedSpotsCount ?? 0, titles[index]);
        case 2: return String(format: "%d %@", user?.savedSpotsCount ?? 0, titles[index]);
        default: return titles[index];
        }
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, viewControllerForPageAt index: Int) -> UIViewController {
        return viewControllers[index];
    }
    
    override func swipeMenuView(_ swipeMenuView: SwipeMenuView, willChangeIndexFrom fromIndex: Int, to toIndex: Int) {
        FirbaseAnalytics.logEvent(toIndex == 2 ? .tapSavesBoardTab : toIndex == 1 ? .tapAboutTab : .tapUploadsBoardTab);
        FirbaseAnalytics.trackScreen(name: "\(screenPrefix) \(titles[toIndex])");
        if user?.id == DataContext.cache.user.id { AmplitudeAnalytics.logEvent(toIndex == 0 ? .profileUploadsTab : toIndex == 1 ? .profileAboutTab : .profileSavesTab, group: .myProfile)
        } else {
             AmplitudeAnalytics.logEvent(toIndex == 0 ? .othersUploadsTab : toIndex == 1 ? .othersAboutTab : .othersSavesTab, group: .otherProfile)
        }
        
        swipeMenuView.subviews.first?.subviews.first?.subviews[fromIndex].backgroundColor = .clear;
        select(tabAtIndex: toIndex);
    }
    
    private func select(tabAtIndex index: Int) {
        guard let stackView = swipeMenuView.tabView?.subviews.first else {return}
        guard stackView.subviews.count > viewControllers.count else {return}
        
        let selectedTabView = stackView.subviews[index];
        selectedTabView.backgroundColor = ColorName.navigationBarTint.color;
        selectedTabView.addShadow(offset: .zero, color: .black, radius: 3, opacity: 1);
        self.view.endEditing(true);
    }
}


extension ProfileSubViewController: BoardCollectionViewControllerDelegate {
    func gotFocus(_ viewContoller: UploadBoardCollectionViewController) {
        if user?.id == DataContext.cache.user.id {
            AmplitudeAnalytics.logEvent(type(of: viewContoller) == SaveBoardCollectionViewController.self ? .profileSearchSaves : .profileSearchUploads, group: .myProfile)
        } else {
        AmplitudeAnalytics.logEvent(type(of: viewContoller) == SaveBoardCollectionViewController.self ? .othersSearchSaves : .othersSearchUploads, group: .otherProfile)
        }
        swipeMenuView.contentScrollView?.isScrollEnabled = false;
    }
    
    func lostFocus(_ viewContoller: UploadBoardCollectionViewController) {
        swipeMenuView.contentScrollView?.isScrollEnabled = true;
    }
    func boardLoadingDone(_ viewController: UploadBoardCollectionViewController) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            self.delegate?.subViewLoadingDone(self)
        })
    }
}

protocol ProfileSubViewDelegate: class {
    func subViewLoadingDone(_ viewController: ProfileSubViewController)
}
