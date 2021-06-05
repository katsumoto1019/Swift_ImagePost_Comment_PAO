//
//  ProfileViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/20/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Instructions
import Kingfisher

import RocketData
import NVActivityIndicatorView

class ProfileViewController: BaseViewController, UISearchBarDelegate, UITextViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet private var coverImageView: UIImageView!
    @IBOutlet private var profileImageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var usernameLabel: UILabel!
    @IBOutlet private var containerView: UIView!
    @IBOutlet var profileActionButton: UIButton!
    
    @IBOutlet weak var loaderBackgroundView: UIView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    // MARK: - Dependencies
    
    lazy var dataProvider = DataProvider<User>()
    lazy var profileSubViewController = ProfileSubViewController()
    
    // MARK: - Internal properties
    
    var userId: String!
    var userName: String!
    var isNavigationBarHiddenOnParent = false
    
    // MARK: - Private properties
    
    private var subLoaded = false
    var user: User?
    private var lastNavigationController: UINavigationController?
    // MARK: - Lifecycle
    
    init(user: User) {
        super.init(nibName: String(describing: ProfileViewController.self), bundle: nil)
        
        self.user = user
        self.userName = user.username ?? ""
        self.userId = user.id ?? ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenName = "My Profile"
        
        dataProvider.delegate = self
        
        nameLabel.alpha = 0
        usernameLabel.alpha = 0
        
        setupNavigationBar()
        setupChildControllers()
        
        activityIndicatorView.type = .circleStrokeSpin
        activityIndicatorView.color = .white
        activityIndicatorView.startAnimating()
        
        // from init, previous controller sends a partial user object
        self.set(profile: nil)

        loadUserData()
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(enlargeProfileImage)))
        profileImageView.isUserInteractionEnabled = true
        
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
        lastNavigationController = navigationController
        profileSubViewController.screenPrefix = screenName
        profileSubViewController.delegate = self
        if #available(iOS 13.0, *) {}
        else {
            UIApplication.shared.statusBarView?.backgroundColor = .clear
        }
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.setNavigationBarX(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isNavigationBarHiddenOnParent {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if #available(iOS 13.0, *) {}
        else {
            UIApplication.shared.statusBarView?.backgroundColor = ColorName.navigationBarTint.color
        }
        if !isNavigationBarHiddenOnParent {
            lastNavigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func applyStyle() {
        super.applyStyle()
        
        nameLabel.set(fontSize: UIFont.sizes.normal)
        usernameLabel.set(fontSize: UIFont.sizes.small)
        profileActionButton.titleLabel?.set(fontSize: UIFont.sizes.verySmall)
        profileActionButton.backgroundColor = UIColor.clear
        profileActionButton.layer.borderWidth = 1
        profileActionButton.layer.borderColor = UIColor.white.cgColor
        profileActionButton.layer.cornerRadius = 5
    }
    
    // MARK: - Actions
    
    @IBAction func profileAction(_ sender: UIButton) {
        FirbaseAnalytics.logEvent(.editProfile)
        AmplitudeAnalytics.logEvent(.clickEditProfile, group: .myProfile)
        
        navigationItem.backBarButtonItem = UIBarButtonItem()
        navigationItem.backBarButtonItem?.title = L10n.Common.cancel
        let viewController = ProfileEditViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Internal methods
    
    func loadUserData() {
        dataProvider.fetchDataFromCache(withCacheKey: User.modelIdentifier(withId: DataContext.cache.user.id!)) { (user, error) in
            self.set(profile: user)
        }
        
        if userId == DataContext.userUID || userName == DataContext.cache.user.username {
            DataContext.cache.loadUser()
            NotificationCenter.default.addObserver(self, selector: #selector(updateProfileImage(notification:)), name: .profileImageUpdate, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateCoverImage(notification:)), name: .coverImageUpdate, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateUploadBoard(notification:)), name: .newSpotUploaded, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(updateSavedBoard(notification:)), name: .saveBoardUpdate, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(followingUpdated(notification:)), name: .followingPeopleUpdate , object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(profileDataUpdated(notification:)), name: .initialDataLoaded , object: nil)
        }
    }
    
    // TODO: Refactor to either Profile or to User
    func set(profile: User?) {
        
        if let profile = profile {
            self.user = profile
            if !subLoaded {
                profileSubViewController.set(user: profile)
                subLoaded = true
            } else {
                profileSubViewController.refreshData(userUpdated: profile)
            }
        }
        
        guard let user = self.user else { return }
        
        if let placeholderColor = user.coverImage?.placeholderColor {
            coverImageView.backgroundColor = UIColor(hex: placeholderColor)
        }
        
        if let placeholderColor = user.profileImage?.placeholderColor {
            profileImageView.backgroundColor = UIColor(hex: placeholderColor)
        }
        
        let factor = UIScreen.main.scale
        let coverImageSize = CGSize(width: coverImageView.frame.width * factor, height: coverImageView.frame.height * factor)
        
        
        if let coverImageUrl = user.coverImage?.url?.imageServingUrl(cropSize: coverImageSize, quality: 70) {
            KingfisherManager.shared.retrieveImage(with: coverImageUrl, options: nil, progressBlock: nil, downloadTaskUpdated: nil) { (result) in
                let image = try? result.get().image
                if let image = image {
                    self.coverImageView.image = image
                }
            }
        } else {
            coverImageView.image = Asset.Assets.Backgrounds.defaultCoverPhoto.image
        }
        
        let profileImageSize = Int(profileImageView.frame.width * factor)
        
        if let profileImageUrl = user.profileImage?.url?.imageServingUrl(cropSize: profileImageSize, quality: 70) {
            KingfisherManager.shared.retrieveImage(with: profileImageUrl, options: nil, progressBlock: nil, downloadTaskUpdated: nil) { (result) in
                if let image = try? result.get().image {
                    self.profileImageView.image = image
                }
            }
        } else {
            profileImageView.image = Asset.Assets.Icons.user.image
        }
        
        nameLabel.text = user.name ?? ""
        
        if let username = user.username {
            usernameLabel.text = "@" + username
        }
        
        let fadeSpeed: Double = 0.2
        UIView.animate(withDuration: fadeSpeed, animations: {
            self.nameLabel.alpha = 1
            self.usernameLabel.alpha = 1
        })
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.settings.image,
            style: .plain,
            target: self,
            action: #selector(showSettingsController)
        )
    }
    
    private func setupChildControllers() {
        containerView.backgroundColor = UIColor.clear
        
        addChild(profileSubViewController)
        containerView.addSubview(profileSubViewController.view)
        profileSubViewController.view.constraintToFit(inContainerView: containerView)
        profileSubViewController.didMove(toParent: self)
    }
    
    @objc
    private func enlargeProfileImage() {
        if userId == DataContext.userUID || userId == DataContext.cache.user.id || userName == DataContext.cache.user.username {
            AmplitudeAnalytics.logEvent(.enlargeOthersProfilePicture, group: .myProfile)
        } else {
            AmplitudeAnalytics.logEvent(.enlargeOthersProfilePicture, group: .otherProfile)
        }
        
        guard let user = self.user else { return }
        
        let viewController = ProfileImagePopupViewController(imageUrl: user.profileImage?.url)
        viewController.modalTransitionStyle = .crossDissolve
        viewController.modalPresentationStyle = .overCurrentContext
        
        if type(of: self) is UserProfileViewController.Type {
            present(viewController, animated: true, completion: nil)
        } else if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(viewController, animated: true, completion: nil)
        }
    }
    
    @objc
    private func showSettingsController() {
        FirbaseAnalytics.logEvent(.clickSettings)
        AmplitudeAnalytics.logEvent(.clickSettings, group: .settings)
        
        let viewController = SettingsTableViewController()
        navigationItem.backBarButtonItem = UIBarButtonItem()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    //MARK: - Image update
    
    @objc
    private func updateProfileImage(notification: Notification) {
        guard let image = notification.object as? UIImage else { return }
        profileImageView.image = image
    }
    
    @objc
    private func updateCoverImage(notification: Notification) {
        guard let image = notification.object as? UIImage else { return }
        coverImageView.image = image
    }
    
    @objc
    private func updateUploadBoard(notification: Notification) {
        profileSubViewController.uploadBoardUpdated = true
        profileSubViewController.refreshData()
    }
    
    @objc
    private func updateSavedBoard(notification: Notification) {
        profileSubViewController.saveBoardUpdated = true
    }
    
    @objc
    private func followingUpdated(notification: Notification) {
        profileSubViewController.followingUpdated = true
    }
    
    @objc
    private func profileDataUpdated(notification: Notification) {
        nameLabel.text = DataContext.cache.user.name
    }
}

extension ProfileViewController: DataProviderDelegate {
    func dataProviderHasUpdatedData<T>(_ dataProvider: DataProvider<T>, context: Any?) where T : SimpleModel {
        set(profile: self.dataProvider.data)
    }
}

extension ProfileViewController: ProfileSubViewDelegate {
    func subViewLoadingDone(_ viewController: ProfileSubViewController) {
        loaderBackgroundView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
}
