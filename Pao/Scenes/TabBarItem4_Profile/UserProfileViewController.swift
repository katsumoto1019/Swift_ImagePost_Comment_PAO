//
//  UserProfileViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 5/9/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import Payload


class UserProfileViewController: ProfileViewController {
    
    // MARK: - Private properties
    
    private lazy var gradient = CAGradientLayer()
    
    // MARK: - Lifecycle

    override init(user: User) {
        super.init(user: user)
        hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Other's Profile"
        
        setupButtons()
        profileSubViewController.isUserProfile = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func loadUserData() {
        dataProvider.fetchDataFromCache(withCacheKey: User.modelIdentifier(withId: userId)) { (data, error) in
            if let user = data, error == nil {
                self.set(profile: user)
            }
            
            self.reloadUserData()
        }
    }
    
    override func set(profile: User?) {
        super.set(profile: profile)
        
        if let profile = profile {
            profileActionButton.isSelected = DataContext.cache.isSelectedInMyPeople(userId: profile.id)
        }
        profileActionButton.isHidden = userName.isEmpty ? (userId == DataContext.cache.user.id) : (userName == DataContext.cache.user.username)

        if profileActionButton.isSelected {
            gradient.removeFromSuperlayer()
            profileActionButton.layer.borderWidth = 1
        } else {
            gradient.frame =  CGRect(origin: .zero, size: profileActionButton.frame.size)
            gradient.colors = [ColorName.gradientTop.color.cgColor, ColorName.gradientBottom.color.cgColor]
            gradient.cornerRadius = 5
            profileActionButton.layer.borderWidth = 0
            profileActionButton.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    override func applyStyle() {
        super.applyStyle()
        
        if profileActionButton.isSelected {
            gradient.removeFromSuperlayer()
            profileActionButton.layer.borderWidth = 1
        } else {
            gradient.frame =  CGRect(origin: .zero, size: profileActionButton.frame.size)
            gradient.colors = [ColorName.gradientTop.color.cgColor, ColorName.gradientBottom.color.cgColor]
            gradient.cornerRadius = 5
            profileActionButton.layer.borderWidth = 0
            profileActionButton.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    func reloadUserData() {
        let vars = UserVars(userId: self.userName.isEmpty ? self.userId : self.userName)
        App.transporter.get(User.self, for: type(of: self), pathVars: vars) { (user) in
            //TODO: Handle The cases for error
            guard let user = user else {
                self.set(profile: nil)
                return
            }
            // Check id of user object and if found null redirect to previous screen
            // This will prevent crash on Profile screen
            guard user.id != nil else {
                self.set(profile: nil)
                let alert = PaoAlertController(title: "Error", subTitle: "Profile not found!")
                alert.addButton(title: "Ok") {
                    self.navigationController?.popViewController(animated: false)
                }
                alert.show(parent: self)
                return
            }
            self.dataProvider.setData(user)
            self.set(profile: user)
        }
    }
    
    // MARK: - Actions
    
    @IBAction override func profileAction(_ sender: UIButton) {
        let action: FollowAction = sender.isSelected ? .unfollow : .follow
        sender.isSelected = !sender.isSelected;
        
        if let userId = self.user?.id
        {
            App.transporter.post(User(id: userId), to: action) { (success) in
                if success == true {
                    FirbaseAnalytics.logEvent(.addUser, parameters: ["value": action == .follow ? 1 : 0])
                    AmplitudeAnalytics.logEvent(
                        .friendFromProfile,
                        group: .addPeople,
                        properties: ["action" : action == .follow ? "follow" : "unfollow"])
                    AmplitudeAnalytics.addUserValue(property: .followings, value: action == .unfollow ? -1 : 1)
                    
                    if let data = self.dataProvider.data {
                        data.isFollowedByViewer = sender.isSelected
                        if sender.isSelected {
                            DataContext.cache.addToMyPeople(userObj: data)
                        } else {
                            DataContext.cache.removeFromMyPeople(userObj: data)
                        }
                        self.dataProvider.setData(data)
                        NotificationCenter.followingPeople()
                    }
                } else {
                    sender.isSelected = !sender.isSelected;
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func setupButtons() {
        profileActionButton.setTitle(L10n.UserProfileViewController.ProfileAction.add, for: UIControl.State.normal)
        profileActionButton.setTitle(L10n.UserProfileViewController.ProfileAction.added, for: UIControl.State.selected)
        profileActionButton.isHidden = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem()
    }
}
