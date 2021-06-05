//
//  AppDelegate.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/6/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

@_exported import BugfenderSDK

import UIKit
import Firebase
import UserNotifications
import IQKeyboardManagerSwift
import GooglePlaces
import Payload

import FBSDKCoreKit
import Amplitude_iOS
import FirebaseCrashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Dependencies
    
    var reachabilityService: ReachabilityService?
    
    // MARK: - Internal properties
    
    var window: UIWindow?
    var notificationOption: Any?
    var openSpotWithId: String?
    var openSearchPageWithTab: String?
    var openImageSelection = false
    var openDiscoverPage = false
    var showPeopleNotification = false
    var showLocationNotification = false
    
    // MARK: - Private properties
    
    private var subscriptionRetries = 0
    private var subscriptionTopicRetries = 0
    private var completedAppLaunch = false
    private let gcmMessageIDKey = "gcm.message_id"
    private lazy var paoAlert = PushNotificationAlertController(text: "") {
        willSet {
            paoAlert.view.removeFromSuperview()
        }
    }
    lazy var searchViewController = SearchViewController()
    let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Lifecycle
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if let bugfenderKey = Bundle.main.bugfenderKey, bugfenderKey.isNotEmpty {
            Bugfender.activateLogger(bugfenderKey)
            Bugfender.enableCrashReporting()
            Bugfender.enableUIEventLogging()  // optional, log user interactions automatically
        }
        
        bfprint("-= BF =- App did Finish Launching With Options")
        bfprint(launchOptions ?? "no launchOptions")
        
        setupNotification(with: launchOptions)
        setupFirebase()
        
        // if launching app for a silent push in background, skip startup
        if let options = launchOptions,
           let remoteNotif = options[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any],
           let aps = remoteNotif["aps"] as? [String: Any],
           let contentAvailable = aps["content-available"] as? String,
           contentAvailable == "1",
           UIApplication.shared.applicationState != .active {
            
            bfprint("-= BF =- Skipped app launch")
            completedAppLaunch = false
            return false
        }
        
        return completeAppLaunch()
    }
    
    private func completeAppLaunch() -> Bool {
        bfprint("-= BF =- completeAppLaunch")
        bfprint("-= BF =- completed App Launch = \(completedAppLaunch)")
        if (!completedAppLaunch) {
            bfprint("-= BF =- now performing startup")
            completedAppLaunch = true
            
            setupLanguage()
            resetSubscriptionRetries()
            setupWindow()
            setupTheme()
            setupKeyboardManager()
            setupAmplitude()
            setupGoogleMap()
            
            checkFirstRun()
            setupAuthStateListener()
            setupReachabilityService()
            setupNetworkTransporter()
            setupRootViewController()
            
            // performing task each session
            // in case user settings have changed
            UIApplication.shared.registerForRemoteNotifications()
            
            bfprint("-= BF =- startup completed")
            return true
        }
        
        return false
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        bfprint("-= BF =- applicationWillResignActive")
        bfprint("-= BF =- completed App Launch = \(completedAppLaunch)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        bfprint("-= BF =- applicationDidEnterBackground")
        bfprint("-= BF =- completed App Launch = \(completedAppLaunch)")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state here you can undo many of the changes made on entering the background.
        bfprint("-= BF =- applicationWillEnterForeground")
        bfprint("-= BF =- completed App Launch = \(completedAppLaunch)")
        if !completeAppLaunch() {
            refreshToken()
            refreshNotifications()
            reachabilityService?.stopNotifier()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        bfprint("-= BF =- applicationDidBecomeActive")
        bfprint("-= BF =- completed App Launch = \(completedAppLaunch)")
        reachabilityService?.startNotifier()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        bfprint("-= BF =- applicationWillTerminate")
        bfprint("-= BF =- completed App Launch = \(completedAppLaunch)")
    }
    
    func application(_ application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        NotificationCenter.default.post(name: .statusBarFrameUpdate, object: newStatusBarFrame)
    }
    
    // MARK: - Private methods
    
    private func setupLanguage() {
        UserDefaults.standard.set(["en_US"], forKey: "AppleLanguages")
    }
    
    private func resetSubscriptionRetries() {
        subscriptionRetries = 0
    }
    
    private func setupWindow() {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.tintColor = .white
        window?.backgroundColor = ColorName.navigationBarTint.color
    }
    
    private func setupTheme() {
        Theme().apply()
    }
    
    private func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    private func setupAmplitude() {
        Amplitude.instance()?.initializeApiKey(Bundle.main.amplitudeApiKey)
        Amplitude.instance()?.trackingSessionEvents = true
    }
    
    private func setupGoogleMap() {
        let hasProvided = GMSPlacesClient.provideAPIKey(Bundle.main.googleMapsAPIKey)
        
        #if DEBUG
        print("Google Places SDK has provided: \(hasProvided)")
        #endif
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
        
        // Remote config
        let remoteConfig = RemoteConfig.remoteConfig()
        remoteConfig.configSettings = RemoteConfigSettings()
        remoteConfig.fetch { (status, error) in
            if status == .success {
                remoteConfig.activate(completion: nil)
            }
        }
        
        // FCM
        //Messaging.messaging().shouldEstablishDirectChannel = true // now deprecated
        Messaging.messaging().delegate = self
        
        UNUserNotificationCenter.current().delegate = self
        bfprint("-= PN =- 1")
    }
    
    private func checkFirstRun() {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            var specificVersionSessions = UserDefaults.integer(key: "v\(appVersion)")
            specificVersionSessions += 1
            UserDefaults.save(value: specificVersionSessions, forKey: "v\(appVersion)")
            print("Session \(specificVersionSessions) for version \(appVersion)")
            
            // fail-safe, register for push every start other than the first
            if (specificVersionSessions > 1) {
                // FCM
                if #available(iOS 10.0, *) {
                    // For iOS 10 display notification (sent via APNS)
                    UNUserNotificationCenter.current().delegate = self
                    
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: { status, error in
                            AmplitudeAnalytics.setUserProperty(property: .notificationStatus, value: NSNumber(value: status))
                        })
                } else {
                    let settings: UIUserNotificationSettings =
                        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    UIApplication.shared.registerUserNotificationSettings(settings)
                }
                
                UIApplication.shared.registerForRemoteNotifications()
            }
            else {
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    AmplitudeAnalytics.setUserProperty(property: .notificationStatus, value: NSNumber(value: settings.authorizationStatus == .authorized))
                }
            }
        }
        let isFirstRun = UserDefaults.bool(key: UserDefaultsKey.isFirstRun.rawValue)
        if !isFirstRun {
            // this is the first run ever
            UserDefaults.save(value: true, forKey: UserDefaultsKey.isFirstRun.rawValue)
            setupAmplitudeAppInstallDate()
        }
    }
    
    // Swizzling disabled: mapping your APNs token and registration token [EG]
    // https://firebase.google.com/docs/cloud-messaging/ios/client#token-swizzle-disabled
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        bfprint("-= PN =- Successfully registered for notifications!")
        bfprint("-= PN =- 2")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        bfprint("-= PN =- Failed to register for notifications: \(error.localizedDescription)")
    }
    
    private func setupAmplitudeAppInstallDate() {
        if let dataInstalled = Date().formateToISO8601String() {
            AmplitudeAnalytics.setUserProperty(
                property: .appInstallDate,
                value: dataInstalled as NSObject
            )
        }
        
        do {
            try Auth.auth().signOut()
            AmplitudeAnalytics.logOut()
        } catch {
            print("⛔️ Amplitude error: \(error)")
        }
    }
    
    private func setupReachabilityService() {
        reachabilityService = ReachabilityService()
    }
    
    private func setupNetworkTransporter() {
        App.transporter.set(endpoint: Endpoint())
        App.transporter.jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
    }
    
    private func setupNotification(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        notificationOption = options?[.remoteNotification]
    }

    private func setupRootViewController(splashAnim: Bool = true) {
        bfprint("-= SOS =- setupRootViewController")
        
        let viewController = NetworkViewController(splashAnim: splashAnim)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }
    
    private func dismissPlaylistIfPresented(tabBarController: TabBarController) {
        if let firstNavigation = tabBarController.viewControllers?.first as? UINavigationController,
           let discoverViewController = firstNavigation.viewControllers.first as? DiscoverViewController
           {
            discoverViewController.presentedViewController?.dismiss(animated: false, completion: nil)
        }
    }
}

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print(userInfo)
        bfprint("-= PN =- 3")
        
        
        bfprint("-= PN =- 4")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            bfprint("-= PN =- Message ID: \(messageID)")
        }
        // Print full message.
        bfprint(userInfo)
        bfprint("-= PN =- 5")
        
        guard let info = userInfo as? [String: AnyObject] else { return }
        
        handleTapped(userInfo: info)
        
        completionHandler()
        bfprint("-= PN =- 6")
    }
    
    @objc
    private func notificationTapped(_ sender: CustomTapGesture) {
        paoAlert.dismiss()
        guard let info = sender.userInfo else { return }
        handleTapped(userInfo: info)
        bfprint("-= PN =- 7")
    }
    
    func handleTapped(userInfo: [String: AnyObject]) {
        bfprint("-= PN =- handleTapped")
        let spotId = userInfo["spotId"]
        
        guard
            let tabBarController = window?.rootViewController as? TabBarController,
            let stringPNType = userInfo["type"] as? String,
            let pnType = PushNotificationCustomType(rawValue: stringPNType) else { return }
                
        if !tabBarController.isViewLoaded && notificationOption != nil {
            // in the scenario that app launched with options
            // this method will be called after loading sequence is completed
            bfprint("-= SOS =- handleTapped skipped")
            return
        }
        bfprint("-= SOS =- handleTapped resumed")
        
        var pushNotificationType: PushNotificationType?
        if let intType = Int(stringPNType) {
            pushNotificationType = PushNotificationType(rawValue: intType)
        }
        var eventName: EventName
        switch pushNotificationType {
        case .plain:
            eventName = .plain
        case .save:
            eventName = .saved
        case .checkList:
            eventName = .checklist
        case .comment:
            eventName = .comment
        case .follow:
            eventName = .follow
        case .followRequest:
            eventName = .followRequest
        case .verify:
            eventName = .verify
        case .spotcomment:
            eventName = .spotComment
        case .followRequestAccepted:
            eventName = .acceptRequest
        case .reactHeartEyes:
            eventName = .reactHeartEyes
        case .reactGem:
            eventName = .reactGem
        case .reactDroolingFace:
            eventName = .reactDroolingFace
        case .reactClap:
            eventName = .reactClap
        case .reactRoundPushpin:
            eventName = .reactRoundPushpin
        case .location:
            eventName = .location
        default:
            eventName = .custom
        }
        AmplitudeAnalytics.logEvent(eventName, group: .externalNotification)
    
        switch pnType {
        case .follow, .followrequest:
            //Do nothing
            tabBarController.selectedIndex = 3
        //Fix: Why is there a comment and spotcomment
        case .save, .comment, .verify, .spotcomment, .reactHeartEyes, .reactGem, .reactDroolingFace, .reactClap, .reactRoundPushpin:
            tabBarController.selectedIndex = 3
            self.dismissPlaylistIfPresented(tabBarController: tabBarController)
            self.searchViewController.goBack()
            if
                let id = spotId as? String,
                let navigationController = tabBarController.selectedViewController as? UINavigationController {
                let manualviewController = ManualSpotsViewController(spotId: id)
                manualviewController.showCommentsOnLoad = pnType == .comment || pnType == .spotcomment
                navigationController.pushViewController(manualviewController, animated: true)
            }
        case .location:
            DispatchQueue.main.async { [self] in
                self.dismissPlaylistIfPresented(tabBarController: tabBarController)
                self.searchViewController.goBack()
                (tabBarController.notificationsViewController as? NotificationSwipeMenuViewController)?.moveToLocationTab = true
                tabBarController.selectedIndex = 3
                if !tabBarController.showingYourLocation {
                    tabBarController.showLocationTabControllers()
                    _ = (tabBarController.notificationsViewController as? NotificationSwipeMenuViewController)?.view
                    (tabBarController.notificationsViewController as? NotificationSwipeMenuViewController)?.moveToLocationTab = true
                }
                if
                    let id = spotId as? String,
                    let navigationController = tabBarController.selectedViewController as? UINavigationController {
                    let manualviewController = ManualSpotsViewController(spotId: id)
                    navigationController.pushViewController(manualviewController, animated: true)
                }
            }
        case .custom:
            guard let pageId = userInfo["page"] as? String, !(pageId.isEmpty) else { return }
            
            if let pnPageType = PushPageType(rawValue: pageId) {
                switch pnPageType {
                case .search_people, .search_locations, .search_spots:
                    
                    tabBarController.dismiss(animated: false, completion: nil)
                    tabBarController.selectedIndex = 1
                    
                    if
                        let navigationController = tabBarController.selectedViewController as? UINavigationController,
                        let searchViewController = navigationController.viewControllers[0] as? SearchViewController {
                        searchViewController.tabIndex = pnPageType == .search_people ? 0 : pnPageType == .search_locations ? 1 : 2
                    }
                }
            }
        default:
            break
        }
        bfprint("-= PN =- 8")
    }
    
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        let handled = ApplicationDelegate.shared.application(
            application, open: url,
            options: options
        )
        
        // Add any custom logic here.
        bfprint("-= PN =- 9")
        return handled
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        bfprint("-= PN =- 16")
        
        // Get URL components from the incoming user activity.
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
            let incomingURL = userActivity.webpageURL else {
            return false
        }
        
        bfprint("-= PN =- Incoming user activity URL: \(incomingURL)")

        let pathComponents = incomingURL.pathComponents
        if let path = pathComponents[safe: 1] {
            let tabBarController = self.window?.rootViewController as? TabBarController
            switch path {
            case "search":
                if let page = pathComponents.last {
                    if tabBarController == nil {
                        self.openSearchPageWithTab = page
                    }
                    tabBarController?.openSearchPageWith(tabName: page)
                    return true
                }
            case "upload":
                if tabBarController == nil {
                    self.openImageSelection = true
                }
                tabBarController?.openImageSelection()
                return true
            case "discover":
                if tabBarController == nil {
                    self.openDiscoverPage = true
                }
                tabBarController?.selectedIndex = 1
                tabBarController?.selectedTabIndex = 1
                return true
            case "spot":
                if let spotId = pathComponents.last {
                    if tabBarController == nil {
                        self.openSpotWithId = spotId
                    }
                    if let navigationController = tabBarController?.selectedViewController as? UINavigationController {
                        let manualviewController = ManualSpotsViewController(spotId: spotId)
                        navigationController.pushViewController(manualviewController, animated: true)
                        return true
                    }
                }
            default:
                break
            }
        }
        
        bfprint("-= PN =- 17")
        return false
    }
}
// [END ios_10_message_handling]

extension AppDelegate: MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        bfprint("-= PN =- Firebase registration token: \(fcmToken)")
        self.subscribeTopicAndDeviceToken(userId: nil, fcmToken: fcmToken)
        bfprint("-= PN =- 10")
    }
    // [END refresh_token]
    
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        bfprint("-= PN =- Received data message: \(remoteMessage.appData)")
        
        if
            let stringPNType = remoteMessage.appData["type"] as? String,
            let pnType = PNTypes(rawValue: stringPNType) {
            switch pnType {
            case .profileUpdate:
                DataContext.cache.loadUser()
            case .spotUpload:
                if UploadBoardCollectionViewController.uploadInProgress {
                    UploadBoardCollectionViewController.uploadInProgress = false
                    NotificationCenter.default.post(name: .newSpotUploaded, object: nil)
                    DataContext.cache.loadUser()
                }
            case .playlistUpdate:
                PlayListCollectionViewController.isUpdateNeededForPlaylist = true
                PlayListTableViewController.isUpdateNeededForPlaylist = true
                NotificationCenter.default.post(name: .playlistUpdateNotification, object: nil)
            case .peopleNotificationUpdate:
                NotificationCenter.default.post(name: .newNotifications, object: nil)
            case .locationNotificationUpdate:
                NotificationCenter.default.post(name: .newNotifications, object: nil, userInfo: ["isLocationNotification":true])
            case .forceUpdate:
                self.setupRootViewController(splashAnim: false)
            }
        } else {
            NotificationCenter.default.post(name: .newNotifications, object: nil)
        }
        bfprint("-= PN =- 11")
    }
    // [END ios_10_data_message]
}

extension AppDelegate {
    
    func showPopupNotification(message: String, userInfo: [String: AnyObject]) {
        if message == "" { return }
        if let stringPNType = userInfo["type"] as? String, let pnType = PushNotificationCustomType(rawValue: stringPNType), pnType == .location || pnType == .custom {
            paoAlert = PushNotificationAlertController(text: message)
        } else {
            paoAlert = PushNotificationAlertController(text: "@" + message)
        }
        paoAlert.show(parent: UIApplication.shared.keyWindow!)
        
        let notificationGestureRecognizer = CustomTapGesture(target: self, action: #selector(notificationTapped(_:)))
        notificationGestureRecognizer.userInfo = userInfo
        
        notificationGestureRecognizer.numberOfTapsRequired = 1
        notificationGestureRecognizer.numberOfTouchesRequired = 1
        paoAlert.containerView.addGestureRecognizer(notificationGestureRecognizer)
        paoAlert.containerView.isUserInteractionEnabled = true
        
        paoAlert.dismiss(afterDelay: 5)
        
        bfprint("-= PN =- 12")
    }
    
    private func setupAuthStateListener() {
        Auth.auth().addIDTokenDidChangeListener { (auth, user) in
            user?.getIDToken(completion: { (token, error) in
                
                if error == nil, let token = token {
                    App.transporter.headers["Authorization"] = "Bearer \(token)"
                    NotificationCenter.default.post(name: .tokenLoaded, object: nil)
                    self.subscribeTopicAndDeviceToken(userId: user?.uid, fcmToken: nil)
                }
            })
        }
        
        // TODO: Test it out.
        Auth.auth().addStateDidChangeListener { (auth, user) in
            #if DEBUG
            print(user ?? "Logout detected")
            #endif
            let isLoggedIn = user != nil
            if let uid = user?.uid {
                FirbaseAnalytics.setUserId(userId: uid)
                AmplitudeAnalytics.setUserId(userId: uid)
                Crashlytics.crashlytics().setUserID(uid)
            }
            
            
            if !isLoggedIn {
                //                InstanceID.instanceID().deleteID { (error) in
                //                    if let error = error {
                //                        print(error)
                //                    }
                //                }
                
                // FIXME: Make sure no memory leak is happening with this, everywhere.
                //                self.window?.rootViewController = AccountViewController()
            } else {
                self.subscribeTopicAndDeviceToken(userId: user?.uid, fcmToken: nil)
                
                // HACK: This updates endpoints to have fid
                App.transporter.set(endpoint: Endpoint())
            }
        }
    }
    
    func refreshToken(completion: ((Bool) -> Void)? = nil) {
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (token, error) in
            if error == nil, let token = token {
                App.transporter.headers["Authorization"] = "Bearer \(token)"
                NotificationCenter.default.post(name: .tokenLoaded, object: nil)
                completion?(true)
            } else if let error = error {
                self.window?.rootViewController?.showMessagePrompt(
                    message: error.localizedDescription,
                    customized: true)
                completion?(false)
            }
        })
    }
    
    private func refreshNotifications() {
        guard
            let tabBarController = window?.rootViewController as? TabBarController,
            let notificationsViewController = tabBarController.viewControllers?[3] as? NotificationsViewController else { return }
        notificationsViewController.refresh()
    }
    
    private func subscribeTopicAndDeviceToken(userId: String?, fcmToken: String?) {
        bfprint("-= PN =- subscribeTopicAndDeviceToken user: \(userId ?? ""), token: \(fcmToken ?? "")")
        if let userId = userId ?? Auth.auth().currentUser?.uid {
            // re-register the topic, to be safe (Google says the best time to do this is didReceiveRegistrationToken) [EG]
            self.subscribeSilentPNs(userId: userId)
            
            // also, send to the server the device token, if its different than the locally known one [EG]
            if let fcmToken = fcmToken {
                self.registerDeviceTokenIfChanged(userId: userId, fcmToken: fcmToken)
            } else {
                Messaging.messaging().token { token, error in
                    if let error = error {
                        bfprint("-= PN =- Error fetching FCM registration token: \(error)")
                    } else if let token = token {
                        bfprint("-= PN =- FCM registration token: \(token)")
                        self.registerDeviceTokenIfChanged(userId: userId, fcmToken: token)
                    }
                }
            }
        }
        
        // playlist topic for silent updates
        self.subscribeSilentPNs(topic: PNTopics.playlistUpdate.rawValue)
        
        // force update for auto refresh
        self.subscribeSilentPNs(topic: PNTopics.forceUpdate.rawValue)
        self.subscribeSilentPNs(topic: "\(PNTopics.forceUpdate.rawValue)\(Bundle.main.apiVersionCode)")
        
        // remove any older force updates (only going back to version 18)
        if Bundle.main.apiVersionCode > 18 {
            for apiVersionCode in 18...Bundle.main.apiVersionCode {
                Messaging.messaging().unsubscribe(fromTopic: "\(PNTopics.forceUpdate.rawValue)\(apiVersionCode - 1)")
            }
        }
    }
    
    private func registerDeviceTokenIfChanged(userId: String, fcmToken: String) {
        if UserDefaults.standard.string(forKey: UserDefaultsKey.deviceToken.rawValue) != fcmToken {
            bfprint("-= PN =- deviceToken registration (token change)")
            registerDeviceToken(userId: userId, fcmToken: fcmToken)
        } else {
            if UserDefaults.standard.string(forKey: UserDefaultsKey.deviceTokenUser.rawValue) != userId {
                bfprint("-= PN =- deviceToken registration (user change)")
                registerDeviceToken(userId: userId, fcmToken: fcmToken)
            }
        }
    }
    
    private func registerDeviceToken(userId: String, fcmToken: String) {
        bfprint("-= SOS =- registerDeviceToken")
        
        UserDefaults.save(value: fcmToken, forKey: UserDefaultsKey.deviceToken.rawValue)
        UserDefaults.save(value: userId, forKey: UserDefaultsKey.deviceTokenUser.rawValue)
        
        let deviceToken = DeviceToken()
        deviceToken.token = fcmToken
        let url = App.transporter.getUrl(DeviceToken.self, httpMethod: .post)
        APIManager.callAPIForWebServiceOperation(model: deviceToken, urlPath: url, methodType: "POST") { (apiStatus, result: DeviceToken?, responseObject, statusCode) in
            if(apiStatus){
                print("-= PN =- deviceToken registration succeed")
            }else{
                UserDefaults.save(value: "", forKey: UserDefaultsKey.deviceToken.rawValue)
                UserDefaults.save(value: "", forKey: UserDefaultsKey.deviceTokenUser.rawValue)
                bfprint("-= PN =- deviceToken registration failed")
            }
        }
    }
    
    private func subscribeSilentPNs(userId: String) {
        bfprint("-= PN =- Attempting try \(self.subscriptionRetries) for subscribeSilentPNs for userId: \(userId)")
        Messaging.messaging().subscribe(toTopic: userId, completion: { [weak self] (error) in
            guard let self = self else { return }
            if error != nil, self.subscriptionRetries < 3, !userId.isEmpty {
                self.subscriptionRetries = self.subscriptionRetries + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    self.subscribeSilentPNs(userId: userId)
                })
            } else {
                self.subscriptionRetries = 0
            }
        })
    }
    
    func subscribeSilentPNs(topic: String) {
        bfprint("-= PN =- Attempting try \(self.subscriptionTopicRetries) for subscribeSilentPNs for topic: \(topic)")
        Messaging.messaging().subscribe(toTopic: topic, completion: { [weak self] (error) in
            guard let self = self else { return }
            if error != nil, self.subscriptionTopicRetries < 3, !topic.isEmpty {
                self.subscriptionTopicRetries = self.subscriptionTopicRetries + 1
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    self.subscribeSilentPNs(topic: topic)
                })
            } else {
                self.subscriptionTopicRetries = 0
            }
        })
    }
}

extension AppDelegate {
    static func startAccountFlow() {
        let viewController = AccountViewController()
        viewController.view.backgroundColor = .clear
        
        let navigationController = OnboardingNavigationController(rootViewController: viewController)
        navigationController.view.backgroundColor = .clear
        
        let rootViewController = MosaicCollectionViewController(collectionViewLayout: UICollectionViewLayout())
        rootViewController.addChild(navigationController)
        rootViewController.view.addSubview(navigationController.view)
        navigationController.view.constraintToFit(inContainerView: rootViewController.view)
        navigationController.didMove(toParent: rootViewController)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        appDelegate.window?.rootViewController = rootViewController
        
        let options: UIView.AnimationOptions = .transitionCrossDissolve
        let duration: TimeInterval = 0.2
        
        UIView.transition(with: (appDelegate.window)!, duration: duration, options: options, animations: {}, completion:
                            { completed in
                            })
    }
}

extension AppDelegate {
    @available(iOS 9, *)
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // Let FCM know about the message for analytics etc.
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // handle your message
        bfprint("-= PN =- 13")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        bfprint("-= PN =- didReceiveRemoteNotification 1")
        
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        if let stringPNType = userInfo["type"] as? String, let pnType = PNTypes(rawValue: stringPNType) {
            bfprint("-= PN =- type \(pnType)")
            switch pnType {
            case .profileUpdate:
                DataContext.cache.loadUser()
            case .spotUpload:
                if UploadBoardCollectionViewController.uploadInProgress {
                    UploadBoardCollectionViewController.uploadInProgress = false
                    NotificationCenter.default.post(name: .newSpotUploaded, object: nil)
                    DataContext.cache.loadUser()
                }
            case .playlistUpdate:
                PlayListCollectionViewController.isUpdateNeededForPlaylist = true
                PlayListTableViewController.isUpdateNeededForPlaylist = true
                NotificationCenter.default.post(name: .playlistUpdateNotification, object: nil)
            case .peopleNotificationUpdate:
                NotificationCenter.default.post(name: .newNotifications, object: nil)
            case .locationNotificationUpdate:
                NotificationCenter.default.post(name: .newNotifications, object: nil, userInfo: ["isLocationNotification":true])
            case .forceUpdate:
                self.setupRootViewController(splashAnim: false)
            }
        } else {
            NotificationCenter.default.post(name: .newNotifications, object: nil)
        }
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            bfprint("-= PN =- Message ID: \(messageID)")
        }
        
        // Print full message.
        bfprint("-= PN =- Received data message: \(userInfo)")
        bfprint("-= PN =- 14")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        bfprint("-= PN =- didReceiveRemoteNotification 2")
        
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        if let stringPNType = userInfo["type"] as? String, let pnType = PNTypes(rawValue: stringPNType) {
            bfprint("-= PN =- type \(pnType)")
            switch pnType {
            case .profileUpdate:
                DataContext.cache.loadUser()
            case .spotUpload:
                if UploadBoardCollectionViewController.uploadInProgress {
                    UploadBoardCollectionViewController.uploadInProgress = false
                    NotificationCenter.default.post(name: .newSpotUploaded, object: nil)
                    DataContext.cache.loadUser()
                }
            case .playlistUpdate:
                PlayListCollectionViewController.isUpdateNeededForPlaylist = true
                PlayListTableViewController.isUpdateNeededForPlaylist = true
                NotificationCenter.default.post(name: .playlistUpdateNotification, object: nil)
            case .peopleNotificationUpdate:
                showPeopleNotification = true
                NotificationCenter.default.post(name: .newNotifications, object: nil)
            case .locationNotificationUpdate:
                showLocationNotification = true
                NotificationCenter.default.post(name: .newNotifications, object: nil, userInfo: ["isLocationNotification":true])
            case .forceUpdate:
                self.setupRootViewController(splashAnim: false)
            }
        } else {
            NotificationCenter.default.post(name: .newNotifications, object: nil)
        }
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            bfprint("-= PN =- Message ID: \(messageID)")
        }
        
        // Print full message.
        bfprint("-= PN =- Received data message: \(userInfo)")
        
        completionHandler(UIBackgroundFetchResult.newData)
        bfprint("-= PN =- 15")
    }
}
