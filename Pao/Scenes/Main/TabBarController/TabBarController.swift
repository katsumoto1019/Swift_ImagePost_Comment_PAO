//
//  TabBarController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/6/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos
import Kingfisher
import Instructions
import RocketData
import Payload

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: - ViewControllers
    
    lazy var coachMarksController = CoachMarksController()
    lazy var spotsViewController = SpotsViewController()
    private lazy var playListViewController = PlayListTableViewController()
    lazy var notificationsViewController: UIViewController = NotificationsViewController()
    
    // MARK: - Dependencies
    
    private lazy var dataProvider = DataProvider<NetworkStatus>()
    
    // MARK: - Internal properties
    var showingYourLocation = false
    var IsDummyDisplay = false // If true, it means it is the dummyView which is shown from NetworkViewController
    lazy var postButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    var selectedTabIndex: Int?
    
    var notificationCollection = PayloadCollection<PushNotification<String>>()
    
    // MARK: - Private properties
    
    private lazy var taskGroup = DispatchGroup()
	private var currentController: UIViewController? {
		guard
			let selectedIndex = selectedTabIndex,
			let viewControllers = viewControllers,
			viewControllers.count > selectedIndex,
			let navController = viewControllers[selectedIndex] as? UINavigationController
		else { return nil }

		return navController.visibleViewController
	}

    private var paoAlert: UploadNotificationAlertController!
    
    var task: URLSessionTask?
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var uploadingSpotIds = [String]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        // Initialize location service to update current location, if is enabled.
        _ = LocationService.shared
            
        spotsViewController.isFeed = true
        spotsViewController.addPaoLogoAndSearchButton = true
        spotsViewController.comesFrom = .yourPeopleFeed
        _ = spotsViewController.view
        
        playListViewController.isTheWorldView = true
        playListViewController.disablePullToRefresh()
        playListViewController.loadIfIsUpdateNeeeded()
        
        if UserDefaults.bool(key: UserDefaultsKey.hasLocationNotifications.rawValue) {
            showingYourLocation = true
            notificationsViewController = NotificationSwipeMenuViewController()
        } else if DataContext.cache.user?.hasLocationNotifications ?? false {
            showingYourLocation = true
            UserDefaults.save(value: true, forKey: UserDefaultsKey.hasLocationNotifications.rawValue)
            notificationsViewController = NotificationSwipeMenuViewController()
        }
        
        // Do any additional setup after loading the view.
        viewControllers = [
            UINavigationController(rootViewController: spotsViewController),
            UINavigationController(rootViewController: playListViewController),
            UINavigationController(rootViewController: UIViewController()),
            UINavigationController(rootViewController: notificationsViewController),
            UINavigationController(rootViewController: ProfileViewController.init(user: DataContext.cache.user))
        ]
        
        let image = Asset.Assets.TabBar.userTabBar.image
        
        tabBar.items?[0].image = Asset.Assets.TabBar.homeTabBar.image
        tabBar.items?[1].image = Asset.Assets.TabBar.discoverTabIcon.image
        tabBar.items?[2].image = nil
        tabBar.items?[3].image = Asset.Assets.TabBar.notificationTabBar.image
        tabBar.items?[4].image = image
        
        setProfileImage(image: image)
        
        checkIsNewUser()
        
        setUserImage()
        
        applyStyle()
        addPostButton()
        //setupTutorials()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileImage(notification:)), name: .profileImageUpdate, object:  nil)
        NotificationCenter.default.addObserver(self, selector: #selector(newNotificationsAvailable(notification:_:isLocationNotification:)), name: .newNotifications, object: nil)
        
        dataProvider.delegate = self
        dataProvider.fetchDataFromCache(withCacheKey: NetworkStatus.modelIdentifier(withId: NetworkStatus.uniqueId)) { (networkStatus, error) in
            self.networkStatusChanged(networkStatus: networkStatus)
        }
        
        getPayloadsForNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bfprint("-= SOS =- TabBarController.viewWillAppear")
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        bfprint("-= SOS =- TabBarController.viewDidAppear")
        super.viewDidAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        if let page = appDelegate.openSearchPageWithTab {
            appDelegate.openSearchPageWithTab = nil
            openSearchPageWith(tabName: page)
        }
        if appDelegate.openImageSelection {
            appDelegate.openImageSelection = false
            openImageSelection()
        }
        if appDelegate.openDiscoverPage {
            appDelegate.openDiscoverPage = false
            selectedIndex = 1
            selectedTabIndex = 1
        }
        if let spotId = appDelegate.openSpotWithId {
            appDelegate.openSpotWithId = nil
            if let navigationController = self.selectedViewController as? UINavigationController {
                let manualviewController = ManualSpotsViewController(spotId: spotId)
                navigationController.pushViewController(manualviewController, animated: true)
            }
        }
        
        //        Commented out for this release.
        //        if UserDefaults.bool(key: UserDefaultsKey.shouldShowPermission.rawValue) == false {
        //            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        //
        //            let paoAlert = UserPermissionsAlertViewController()
        //            paoAlert.addButton(title: "Ok") {
        //                var user = DataContext.cache.user
        //                user?.permission = paoAlert.permissions
        //                self.postUser(user: user!)
        //                UserDefaults.save(value: true, forKey: UserDefaultsKey.shouldShowPermission.rawValue)
        //
        /// If being sued as dummyView after app launch, don't show the tutorials.
        if view.isUserInteractionEnabled {
            //checkNewFeaturePlayList()
            startTutorials()
        }
        //            }
        //            paoAlert.show(parent: (appDelegate.window?.rootViewController!)!)
        //        }
        
        if let notification = appDelegate.notificationOption as? [String: AnyObject],
           let _ = notification["type"] as? String {
            appDelegate.handleTapped(userInfo: notification)
            selectedTabIndex = 3
            appDelegate.notificationOption = nil
        }
    }
    
    // MARK: - Internal methods
    
    private func checkIsNewUser() {
        self.selectedIndex = UserDefaults.bool(key: UserDefaultsKey.showWorldTab.rawValue) ? 1 : 0
        self.selectedTabIndex = self.selectedIndex
        UserDefaults.save(value: false, forKey: UserDefaultsKey.showWorldTab.rawValue)
    }
    
    func openSearchPageWith(tabName: String) {
        //AmplitudeAnalytics.logEvent(.searchIcon, group: .search)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.searchViewController.hidesBottomBarWhenPushed = true
        appDelegate.searchViewController.firstLoad = true
        //appDelegate.searchViewController.animationIdentifier = searchMotionIdentifier
        appDelegate.searchViewController.tabIndex = tabName == "spots" ? 2 : tabName == "people" ? 1 : 0
        let navigationController = UINavigationController(rootViewController: appDelegate.searchViewController)
        //navigationController.isMotionEnabled = true
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    func openImageSelection() {
        guard PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized else {
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.denied {
                let message = L10n.TabBarController.MessagePrompt.message
                self.showMessagePrompt(message: message, customized: true)
                AmplitudeAnalytics.logEvent(.accessDeniedToPhoto, group: .uploadEvents, properties: ["error": message])
                return
            }
            
            PHPhotoLibrary.requestAuthorization { (phAuthorizationStatus) in
                if phAuthorizationStatus == PHAuthorizationStatus.authorized {
                    self.openImageSelection()
                }
            }
            return
        }
        
        DispatchQueue.main.async {
            FirbaseAnalytics.logEvent(.tapUpload)
            AmplitudeAnalytics.logEvent(.uploadTab, group: .upload)
            
            let viewController = NewSpotImageSelectionViewController()
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @objc
    func newNotificationsAvailable(notification: NSNotification?, _ avoidRefresh: Bool = false, isLocationNotification: Bool = false) {
        let tabBarItem = tabBar.items?[3]
        tabBarItem?.badgeColor = .clear
        tabBarItem?.badgeValue = "●"
        tabBarItem?.setBadgeTextAttributes([.foregroundColor: ColorName.accent.color], for: .normal)
        var isLocationNotification = isLocationNotification
        if let locationFlag = notification?.userInfo?["isLocationNotification"] as? Bool {
            isLocationNotification = locationFlag
        }
        if isLocationNotification {
            (notificationsViewController as? NotificationSwipeMenuViewController)?.showDotOnYourLocationTab()
        } else if showingYourLocation {
            (notificationsViewController as? NotificationSwipeMenuViewController)?.showDotOnYourPeopleTab()
        }
        print("*** avoidRefresh: \(avoidRefresh ? "yes" : "no")")
        if !avoidRefresh {
            if isLocationNotification && showingYourLocation {
                NotificationsViewController.isUpdateNeededForLocationNotifications = true
            } else {
                NotificationsViewController.isUpdateNeededForPeopleNotifications = true
            }
            if UIApplication.shared.applicationState == .active {
                // foreground only
                if !showingYourLocation {
                    let notificationVC = (notificationsViewController as? NotificationsViewController)
                    notificationVC?.passedCollection.removeAll()
                    notificationVC?.refresh()
                } else {
                    if isLocationNotification {
                        let notificationVC = (notificationsViewController as? NotificationSwipeMenuViewController)?.yourLocationViewController.yourLocationSpotTableViewController
                        notificationVC?.passedCollection.removeAll()
                        notificationVC?.refresh()
                    } else {
                        let notificationVC = (notificationsViewController as? NotificationSwipeMenuViewController)?.notificationsViewController
                        notificationVC?.passedCollection.removeAll()
                        notificationVC?.refresh()
                    }
                }
            }
        }
    }
    
    func showLocationTabControllers() {
        if showingYourLocation {
            // Only assign collection
            (notificationsViewController as? NotificationSwipeMenuViewController)?.notificationCollection = notificationCollection.filter { $0.type != .location }
            (notificationsViewController as? NotificationSwipeMenuViewController)?.locationCollection = notificationCollection.filter { $0.type == .location }
        } else {
            // Replace with location tab controller
            if var vcArray = self.viewControllers {
                notificationsViewController = NotificationSwipeMenuViewController()
                (notificationsViewController as? NotificationSwipeMenuViewController)?.notificationCollection = notificationCollection.filter { $0.type != .location }
                (notificationsViewController as? NotificationSwipeMenuViewController)?.locationCollection = notificationCollection.filter { $0.type == .location }
                notificationsViewController.tabBarItem = self.tabBar.items?[3]
                vcArray[3] = UINavigationController(rootViewController: notificationsViewController)
                self.viewControllers = vcArray
            }
            showingYourLocation = true
            UserDefaults.save(value: true, forKey: UserDefaultsKey.hasLocationNotifications.rawValue)
        }
    }
    func showFeed() {
        let indexPath = IndexPath(row: 0, section: 0)
        tabBarController?.selectedIndex = 0
        spotsViewController.navigationController?.popToRootViewController(animated: false)
        if spotsViewController.activeViewController != nil {
            spotsViewController.activeViewController.scrollTo(indexPath: indexPath, animated: false)
        }
    }

    func showNewFeatureAlertIfNeeded() {
        let noNeedShow = UserDefaults.bool(key: UserDefaultsKey.sharabilityFeatureAlreadyPresented.rawValue) ||
            UserDefaults.bool(key: UserDefaultsKey.isNewUser.rawValue)
        if noNeedShow { return }
        
        let alert = NewFeatureAlertViewController(title: L10n.TabBarController.NewFeatureAlert.title, subTitle: L10n.TabBarController.NewFeatureAlert.subTitle)
        alert.addButton(title: L10n.TabBarController.NewFeatureAlert.buttonTitle, onClick: {
            alert.close()
            self.selectedTabIndex = 0
            self.selectedIndex = 0
        })
        alert.show(parent: self)
    }
    
    func showWelcomeMessage() {
        let alert = ForceUpdateAlertController.init(title: L10n.TabBarController.WelcomeAlert.title, subTitle: L10n.TabBarController.WelcomeAlert.subTitle)
        alert.addButton(title: L10n.Common.letsDoIt, onClick: { alert.dismiss() })
        alert.show(parent: self)
    }
    
    // MARK: - Private methods
    
    private func postUser(user: User) {
        taskGroup.enter()
        App.transporter.post(user, returnType: User.self) { (result) in
            self.taskGroup.leave()
        }
    }
    
    private func applyStyle() {
        tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        tabBar.layer.shadowRadius = 7
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOpacity = 0.4
        
        tabBar.items?.forEach({$0.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)})
    }
    
    private func addPostButton() {
        postButton.backgroundColor = ColorName.backgroundHighlight.color
        postButton.layer.cornerRadius = 4
        
        let image = Asset.Assets.Icons.plus.image        
        postButton.setImage(image, for: UIControl.State())
        postButton.setImage(image.image(withAlpha: 0.6), for: .disabled)
        postButton.clipsToBounds = true
        
        postButton.addTarget(self, action: #selector(post), for: .touchUpInside)
        
        tabBar.addSubview(postButton)
        
        postButton.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = postButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor)
        // This hides bottom round corners
        //        let verticalConstraint = postButton.bottomAnchor.constraint(equalTo: self.tabBar.bottomAnchor, constant: 2)
        let verticalConstraint = postButton.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -4)
        let widthConstraint = postButton.widthAnchor.constraint(equalToConstant: 57 + 4)
        // We add extra height to 50 to compensate for bottom anchor from above
        let heightConstraint = postButton.heightAnchor.constraint(equalToConstant: 49 + 5)
        
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }
    
    @objc
    func post(_ sender: UIButton) {
        if sender == postButton,
            !postButton.isEnabled {
            return
        }
        openImageSelection()
    }
    
    private func setUserImage() {
        guard let profileImageUrl = DataContext.cache.user?.profileImage?.url else {
            return
        }
        
        KingfisherManager.shared.retrieveImage(with: profileImageUrl, options: nil, progressBlock: nil, downloadTaskUpdated: nil) { (result) in
            if let image = try? result.get().image {
                let scale = UIScreen.main.scale
                let fit = CGSize(width: 30 * scale, height: 30 * scale)
                if let cgImage = image.kf.image(withRoundRadius: 15 * scale, fit: fit).cgImage {
                    let image = UIImage(cgImage: cgImage, scale: scale, orientation: .up).withRenderingMode(.alwaysOriginal)
                    self.setProfileImage(image: image)
                }
            }
        }
    }
    
    @objc
    private func updateProfileImage(notification: Notification) {
        if let image = notification.object as? UIImage {
            let scale = UIScreen.main.scale
            if let cgImage = image.kf.image(withRoundRadius: 15 * scale, fit: CGSize(width: 30 * scale, height: 30 * scale)).cgImage {
                let image = UIImage(cgImage: cgImage, scale: scale, orientation: .up).withRenderingMode(.alwaysOriginal)
                self.setProfileImage(image: image)
            }
        }
    }
    
    private func setProfileImage(image: UIImage) {
        let tabBarItem = tabBar.items?.last
        tabBarItem?.image = image.image(withAlpha: 0.5)!.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        tabBarItem?.selectedImage = image.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
    }
    
    // deprecated - should update or remove on next update
    private func checkNewFeaturePlayList() {
        guard
            !UserDefaults.bool(key: UserDefaultsKey.isNewUser.rawValue),
            !UserDefaults.bool(key: UserDefaultsKey.isShowPlaylistFeature.rawValue),
        UserDefaults.bool(key: UserDefaultsKey.doneTutorialForTabs.rawValue)
            else { return }
        UserDefaults.save(value: true, forKey: UserDefaultsKey.isShowPlaylistFeature.rawValue)
        
        let popUpViewController = PlayListPopUpViewController(nibName: "PlayListPopUpViewController", bundle: nil)
        addChild(popUpViewController)
        popUpViewController.view.frame = view.frame
        view.addSubview(popUpViewController.view)
        popUpViewController.didMove(toParent: self)
        popUpViewController.checkItOutButtonDidPressed = { [weak self] in
            guard let self = self else { return }
            self.tabBarController?.selectedIndex = 1
        }
    }
    
    func getPayloadsForNotification() {
        bfprint("-= SOS =- getPayloadsForNotification")
        
        let params = NotificationParams(skip: notificationCollection.count, take: notificationCollection.bufferSize, type: .all)
        let url = App.transporter.getUrl([String].self, for: NotificationsViewController.self, httpMethod: .get, queryParams: params)
        APIManager.callAPIForWebServiceOperation(model: PushNotification<String>(), urlPath: url, methodType: "GET") { (apiStatus, _: PushNotification<String>?, responseObject, statusCode) in
            if(apiStatus){
                do {
                    let array = responseObject as? NSArray ?? []
                    let notificationArray = array.map({ (dictionary) -> PushNotification<String> in
                        let dic = dictionary as? NSDictionary ?? [:]
                        let notification = PushNotification<String>()
                        notification.id = dic["id"] as? String
                        notification.type = PushNotificationType(rawValue: dic["type"] as? Int ?? 0)
                        notification.timestamp = Date.init(timeIntervalSince1970: TimeInterval((dic["timestamp"] as? Int ?? 0)/1000))
                        let payloadData =  try? JSONSerialization.data(withJSONObject: dic["payload"] as Any, options: JSONSerialization.WritingOptions.sortedKeys)
                        notification.payload =  String(data: payloadData ?? Data(), encoding: String.Encoding.utf8)
                        return notification
                    })
                    self.notificationCollection.append(contentsOf: notificationArray)
                    let locationNotifications = self.notificationCollection.filter { $0.type == .location }
                    if locationNotifications.count > 0 {
                        self.showLocationTabControllers()
                    } else {
                        (self.notificationsViewController as? NotificationsViewController)?.passedCollection = self.notificationCollection.filter { $0.type != .location }
                    }
                    let firstLocationElement = locationNotifications.first
                    if firstLocationElement?.timestamp?.timeIntervalSince1970 ?? 0 > UserDefaults.standard.double(forKey: UserDefaultsKey.lastLocationNotificationDate.rawValue) {
                        self.newNotificationsAvailable(notification: nil, true, isLocationNotification: true)
                    }
                    let peopleNotifications = self.notificationCollection.filter { $0.type != .location }
                    let firstPeopleElement = peopleNotifications.first
                    if firstPeopleElement?.timestamp?.timeIntervalSince1970 ?? 0 > UserDefaults.standard.double(forKey: UserDefaultsKey.lastPeopleNotificationDate.rawValue) {
                        self.newNotificationsAvailable(notification: nil, true)
                    }
                }catch{
                    return
                }
            }
        }
    }
    
}

extension TabBarController {
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.lastIndex(of: item) else { return }
        
        FirbaseAnalytics.logEvent(screenAction(index).rawValue)
        AmplitudeAnalytics.logEvent(tabbarEvent(index), group: tabbarEventGroup(index))
        
        guard index == 0, selectedTabIndex == 0 else {
			if
				index == selectedTabIndex,
				let currentController = currentController as? ScrollableProtocol {
				currentController.scrollToTop()
			}
            selectedTabIndex = index
            return
        }
        spotsViewController.spotCollectionViewController.refresh()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if selectedTabIndex == 2 {
            post(postButton)
            return false
        }

        return true
    }
    
    // MARK: - Private methods
    
    private func screenAction(_ index: Int) -> EventAction {
        return [EventAction.tapYourPeople, .tapDiscover, .tapUpload, .tapNotifications, .tapMyProfile][index]
    }
    
    private func tabbarEvent(_ index: Int) -> EventName {
        return [EventName.yourPeople, .discover, .uploadTab, .notifications, .myProfile][index]
    }
    
    private func tabbarEventGroup(_ index: Int) -> EventGroup {
        return [EventGroup.viewSpots, .viewSpots, .upload, .notifications, .myProfile][index]
    }
}


extension TabBarController: DataProviderDelegate {
    func dataProviderHasUpdatedData<T>(_ dataProvider: DataProvider<T>, context: Any?) where T: SimpleModel {
        networkStatusChanged(networkStatus: self.dataProvider.data)
    }
    
    func networkStatusChanged(networkStatus: NetworkStatus?) {
        guard
            let networkStatus = networkStatus,
            let available = networkStatus.available else { return }
        postButton.isEnabled = available
    }
}

//MARK: - Upload Spot Methods

extension TabBarController {
    
    func upload(spot: Spot, phAssetsDictionary: [String: PHAsset], uploadImagesDictionary: [String: UIImage]) {
        let boundary = UUID().uuidString
        createMultipartBody(formJson: String(bytes: try! spot.toData(), encoding: String.Encoding.utf8)!, phAssetsDictionary: phAssetsDictionary, uploadImagesDictionary:uploadImagesDictionary, boundary: boundary) { data in

            guard let data = data else {
                let message = L10n.TabBarController.UploadError.checkInternetConnectioin
                self.showMessagePrompt(message: message, handler: { (alertAction) in
                })
                AmplitudeAnalytics.logEvent(.checkInternetConnection, group: .uploadEvents, properties: ["error": message])
                return
            }
            
            let uploadSizeLimit = 60 * 1024 * 1024
            guard data.count <= uploadSizeLimit else {
                let message = L10n.TabBarController.UploadError.postIsTooLarge
                self.showMessagePrompt(message: message, customized: true)
                AmplitudeAnalytics.logEvent(.postIsTooLarge, group: .uploadEvents, properties:["error": message])
                return
            }
            self.uploadingSpotIds.append(spot.id!)
            self.spotsViewController.addUploadingSpot(spot: spot)
            // Start upload in background
            self.uploadImageInBackground(data: data, boundary: boundary, spotId: spot.id!)
        }
    }
    
    func retryUploadFor(spot: Spot) {
        let boundary = UUID().uuidString
        
        createMultipartBody(formJson: String(bytes: try! spot.toData(), encoding: String.Encoding.utf8)!, spot: spot, boundary: boundary) { data in

            guard let data = data else {
                let message = L10n.TabBarController.UploadError.checkInternetConnectioin
                self.showMessagePrompt(message: message, handler: { (alertAction) in
                })
                AmplitudeAnalytics.logEvent(.checkInternetConnection, group: .uploadEvents, properties:["error": message])
                return
            }
            self.uploadingSpotIds.append(spot.id!)
            self.spotsViewController.setUploadStatusFor(spotId: spot.id!, status: .uploading)
            // Start upload in background
            self.uploadImageInBackground(data: data, boundary: boundary, spotId: spot.id!)
        }
    }
    
    func createMultipartBody(formJson: String, phAssetsDictionary: [String : PHAsset], uploadImagesDictionary: [String : UIImage], boundary: String, completion: @escaping (Data?) -> Void)
    {
        var body = Data()
        
        //boundary
        body.append(String(format:"--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"spot\"\r\n".data(using: String.Encoding.utf8)!)
        body.append(String(format:"Content-Type: application/json\r\n\r\n").data(using: String.Encoding.utf8)!)
        body.append(formJson.data(using: String.Encoding.utf8)!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        for media in phAssetsDictionary
        {
            taskGroup.enter()
            media.value.toFormData { (data, mime) in
                if let data = data, let mime = mime {
                    body.append(String(format:"--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
                    body.append(String(format:"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", media.key, media.key).data(using: String.Encoding.utf8)!)
                    body.append(String(format:"Content-Type: %@\r\n\r\n", mime).data(using: String.Encoding.utf8)!)
                    
                    var imageData: Data
                    if let croppedImage = uploadImagesDictionary[media.key], let croppedImageData = croppedImage.jpegData(compressionQuality: 0.75) ?? croppedImage.pngData() {
                        imageData = croppedImageData
                    } else {
                        imageData = data
                    }
                    
                    body.append(imageData)
                    body.append("\r\n".data(using: String.Encoding.utf8)!)
                    
                    self.taskGroup.leave()
                } else {
                    completion(nil)
                }
            }
        }
        
        taskGroup.notify(queue: .main) {
            //end boundary
            body.append(String(format:"--%@--", boundary).data(using: String.Encoding.utf8)!)
            completion(body)
        }
    }
    
    func createMultipartBody(formJson: String, spot: Spot, boundary: String, completion: @escaping (Data?) -> Void) {
        var body = Data()
        
        //boundary
        body.append(String(format:"--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"spot\"\r\n".data(using: String.Encoding.utf8)!)
        body.append(String(format:"Content-Type: application/json\r\n\r\n").data(using: String.Encoding.utf8)!)
        body.append(formJson.data(using: String.Encoding.utf8)!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        for key in spot.media!.keys {
            taskGroup.enter()
            
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            if let url = URL(string: "\(path)/\(key)"), let mediaData = try? Data(contentsOf: url) {
                let mime = self.mimeType(for: mediaData)
                body.append(String(format:"--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
                body.append(String(format:"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", key, key).data(using: String.Encoding.utf8)!)
                body.append(String(format:"Content-Type: %@\r\n\r\n", mime).data(using: String.Encoding.utf8)!)
                
                body.append(mediaData)
                body.append("\r\n".data(using: String.Encoding.utf8)!)
                
                self.taskGroup.leave()
            } else {
                completion(nil)
            }
        }
        
        taskGroup.notify(queue: .main) {
            //end boundary
            body.append(String(format:"--%@--", boundary).data(using: String.Encoding.utf8)!)
            completion(body)
        }
    }
    
    func uploadImageInBackground(data: Data?, boundary: String, spotId: String) {
        AmplitudeAnalytics.logEvent(.completeUploadSpot, group: .upload)
        self.registerBackgroundTask()
        UserDefaults.save(value: true, forKey: UserDefaultsKey.isSpotUploading.rawValue)
        
        // Create URL Request
        let url = App.transporter.getUrl(Spot.self, httpMethod: .post)
        var request = URLRequest(url: url)
        request.timeoutInterval = 3000.0
        
        request.addValue(String(format: "multipart/form-data; boundary=%@", boundary), forHTTPHeaderField: "Content-Type")
        request.httpMethod = HttpMethod.post.rawValue
        request.httpBody = data
        
        var observation: NSKeyValueObservation?
        self.task = App.transporter.executeRequest(request) { (result: Spot?) in
            if let index = self.uploadingSpotIds.firstIndex(of: spotId) {
                self.uploadingSpotIds.remove(at: index)
            }
            if self.uploadingSpotIds.count == 0 {
                UserDefaults.save(value: false, forKey: UserDefaultsKey.isSpotUploading.rawValue)
            }
            self.spotUploaded(spot: result, tempSpotId: spotId)
            
            observation?.invalidate()
            self.endBackgroundTask()
        }
        
        observation = self.task?.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async {
                self.updateProgress(progress.fractionCompleted)
            }
        }
    }
    
    private func updateProgress(_ progress: Double) {
        switch UIApplication.shared.applicationState {
        case .active:
            NotificationCenter.default.post(name: .newSpotUplodingProgress, object: nil, userInfo: ["progress": progress])
          break
        case .background:
            #if DEBUG
              print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
            #endif
        case .inactive:
          break
        default:
            break
        }
    }
    
    private func spotUploaded(spot: Spot?, tempSpotId: String) {
        if spot == nil {
            let message = L10n.TabBarController.UploadError.checkInternetConnectioin
            #if DEBUG
                print(message)
            #endif
            AmplitudeAnalytics.logEvent(.checkInternetConnection, group: .uploadEvents, properties: ["error": message])
            UploadBoardCollectionViewController.uploadInProgress = false
            // Upload fail
            self.spotsViewController.setUploadStatusFor(spotId: tempSpotId, status: .failed)
            return
        }
        
        AmplitudeAnalytics.addUserValue(property: .uploads, value: 1)
        AmplitudeAnalytics.logEvent(.uploadSuccess, group: .uploadEvents)
        
        switch UIApplication.shared.applicationState {
        case .active:
            UploadBoardCollectionViewController.uploadInProgress = true
            self.spotsViewController.spotCollectionViewController.refresh()
            
            if selectedIndex == 0 {
                // User is on Feed page
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.spotsViewController.activeViewController.scrollTo(indexPath: indexPath, animated: false)
                }
                
            } else {
                showUploadNotification(message: L10n.TabBarController.UploadNotification.message)
            }
            break
            
        case .background:
            #if DEBUG
            print("Background time remaining = \(UIApplication.shared.backgroundTimeRemaining) seconds")
            #endif
            break
        case .inactive:
            break
        default:
            break
        }
        // Remove uploaded spot from cache
        self.spotsViewController.removeUploadedSpot(spotId: tempSpotId, reloadData: false)
    }
    
    func registerBackgroundTask() {
      backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
        self?.endBackgroundTask()
      }
      assert(backgroundTask != .invalid)
    }
    func endBackgroundTask() {
      UIApplication.shared.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
    
    func showUploadNotification(message: String) {
        paoAlert = UploadNotificationAlertController(text: message)
        paoAlert.show(parent: topMostController())
        
        let notificationGestureRecognizer = CustomTapGesture(target: self, action: #selector(notificationTapped(_:)))
        notificationGestureRecognizer.numberOfTapsRequired = 1
        notificationGestureRecognizer.numberOfTouchesRequired = 1
        paoAlert.containerView.addGestureRecognizer(notificationGestureRecognizer)
        paoAlert.containerView.isUserInteractionEnabled = true
        paoAlert.dismiss(afterDelay: 5)
    }
    
    @objc private func notificationTapped(_ sender: CustomTapGesture) {
        paoAlert.dismiss()
        self.presentedViewController?.dismiss(animated: false, completion: nil)
        let indexPath = IndexPath(row: 0, section: 0)
        selectedIndex = 0
        spotsViewController.navigationController?.popToRootViewController(animated: false)
        spotsViewController.activeViewController.scrollTo(indexPath: indexPath, animated: false)
    }
    
    func mimeType(for data: Data) -> String {
        var b: UInt8 = 0
        data.copyBytes(to: &b, count: 1)

        switch b {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x4D, 0x49:
            return "image/tiff"
        case 0x25:
            return "application/pdf"
        case 0xD0:
            return "application/vnd"
        case 0x46:
            return "text/plain"
        default:
            return "application/octet-stream"
        }
    }
}
