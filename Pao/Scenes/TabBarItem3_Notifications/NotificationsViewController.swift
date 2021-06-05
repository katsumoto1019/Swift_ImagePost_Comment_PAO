//
//  NotificationsViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/26/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import Payload


//TODO: This whole class should be refactored to handle notifcations better, with generic instead of manual switch case.
class NotificationsViewController: TableViewController<HackCell> {
    
    private var didCheckPermission = false
    var backgroundSessionCompletionHandler: (([HackCell.PayloadType]?) -> Void)? = nil
    var passedCollection = PayloadCollection<PushNotification<String>>()
    public static var isUpdateNeededForPeopleNotifications = false
    public static var isUpdateNeededForLocationNotifications = false
    
    private let searchMotionIdentifier = "search_icon_search_bar"
    let cellDictionary: [PushNotificationType: UITableViewCell.Type] = [
        PushNotificationType.plain: PlainNotificationTableViewCell.self,
        PushNotificationType.checkList: ChecklistItemTableViewCell.self,
        PushNotificationType.save: NotificationViewCell.self,
        PushNotificationType.comment: NotificationViewCell.self,
        PushNotificationType.follow: NotificationViewCell.self,
        PushNotificationType.followRequest: FollowRequestTableViewCell.self,
        PushNotificationType.verify: NotificationViewCell.self,
        PushNotificationType.spotcomment: NotificationViewCell.self,
        PushNotificationType.followRequestAccepted: NotificationViewCell.self,
        PushNotificationType.reactHeartEyes: EmojiNotificationViewCell.self,
        PushNotificationType.reactDroolingFace: EmojiNotificationViewCell.self,
        PushNotificationType.reactGem: EmojiNotificationViewCell.self,
        PushNotificationType.reactClap: EmojiNotificationViewCell.self,
        PushNotificationType.reactRoundPushpin: EmojiNotificationViewCell.self,
        PushNotificationType.location: NotificationViewCell.self
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cellDictionary.values.forEach({tableView.register($0)})
        
        NotificationCenter.default.addObserver(self, selector: #selector(followRequestUpdate(notification:)), name: .followRequestUpdate , object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func followRequestUpdate(notification: Notification) {
        guard let indexPath = notification.userInfo?["indexPath"] as? IndexPath else { return }
        _ = collection.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItems()
        self.navigationController?.navigationBar.isTranslucent = false // fix transparent issue
        self.view.layoutIfNeeded() // fix header layout issue
        
        loadIfIsUpdateNeeeded()
    }
    
    private func setupNavigationItems() {
        addTitle()
        addSearchButton()
    }
    
    func addTitle() {
        let label = UILabel()
        label.text = L10n.Common.titleNotifications
        label.font = UIFont.appBold.withSize(UIFont.sizes.large)
        //label.textColor = ColorName.accent.color
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
    func addSearchButton() {
        let searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        searchButton.setImage(UIImage(named: "search-teal"), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchButton.motionIdentifier = searchMotionIdentifier
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
    }
    
    @objc func searchButtonTapped() {
        AmplitudeAnalytics.logEvent(.searchIcon, group: .search)
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        appDelegate.searchViewController.hidesBottomBarWhenPushed = true
        appDelegate.searchViewController.firstLoad = true
        appDelegate.searchViewController.animationIdentifier = searchMotionIdentifier
        let navigationController = UINavigationController(rootViewController: appDelegate.searchViewController)
        navigationController.isMotionEnabled = true
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    @objc func willEnterForeground() {
        loadIfIsUpdateNeeeded()
    }

    func loadIfIsUpdateNeeeded() {
        if (NotificationsViewController.isUpdateNeededForPeopleNotifications || collection.count == 0) {
            passedCollection.removeAll()
            // seems like a refresh started but didn't complete
            self.refresh()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FirbaseAnalytics.trackScreen(name: .notifications)

        //TODO: It should be tabBarItem but it's null probably because of didMove?
        notificationsSeen()
        
        if !didCheckPermission {
            didCheckPermission = true
            checkPermissions()
            
            // performing task each time visitting screen per session
            // in case user settings have changed
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        navigationItem.title = ""
        FirbaseAnalytics.trackScreen(name: .notifications, screenClass: classForCoder.description())
        
        notificationsSeen()
    }
    
    private func notificationsSeen() {
        if let tabBarController = tabBarController as? TabBarController, !tabBarController.showingYourLocation {
            if tabBarController.tabBar.items?[3].badgeValue != nil {
                tabBarController.tabBar.items?[3].badgeValue = nil
            }
        }
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: UserDefaultsKey.lastPeopleNotificationDate.rawValue)
    }
    
    override func getPayloads(completionHandler: @escaping ([HackCell.PayloadType]?) -> Void) -> PayloadTask? {
        
        bfprint("-= SOS =- getPayloads notifs")
        
        if passedCollection.count > 0 {
            let array = passedCollection.map { (element) -> PushNotification<String> in
             return element
            }
            passedCollection.removeAll()
            completionHandler(array)
            didLoadNotifications()
            return nil
        } else {
            print("*** getPayloads start NotificationsViewController 1")
            let params = NotificationParams(skip: collection.count, take: collection.bufferSize, type: .notLocation)
            let url = App.transporter.getUrl([String].self, for: type(of: self), httpMethod: .get, queryParams: params)
            return APIManager.callAPIForWebServiceOperation(model: PushNotification<String>(), urlPath: url, methodType: "GET") { (apiStatus, _: PushNotification<String>?, responseObject, statusCode) in
                if(apiStatus){
                    do {
                        let array = responseObject as? NSArray ?? []
                        let notificationArray = try array.map({ (dictionary) -> PushNotification<String> in
                            let dic = dictionary as? NSDictionary ?? [:]
                            let notification = PushNotification<String>()
                            notification.id = dic["id"] as? String ?? "0"
                            notification.type = PushNotificationType(rawValue: dic["type"] as? Int ?? 0)
                            notification.timestamp = Date.init(timeIntervalSince1970: TimeInterval((dic["timestamp"] as? Int ?? 0)/1000))
                            let payloadData = try JSONSerialization.data(withJSONObject: dic["payload"] as Any, options: JSONSerialization.WritingOptions.sortedKeys)
                            notification.payload = String(data: payloadData, encoding: String.Encoding.utf8)
                            return notification
                        })
                        completionHandler(notificationArray)
                        self.didLoadNotifications()
                    }catch{
                        completionHandler(nil)
                        return
                    }
                }else{
                    completionHandler(nil)
                    return
                }
            } as? PayloadTask
        }
    }
    
    private func didLoadNotifications() {
        let locationNotifications = collection.filter { $0.type == .location }
        if locationNotifications.count > 0, let tabBarController = tabBarController as? TabBarController, !tabBarController.showingYourLocation {
            tabBarController.notificationCollection = collection
            tabBarController.showLocationTabControllers()
            tabBarController.newNotificationsAvailable(notification: nil, true, isLocationNotification: true)
            return
        }
        
        // Filtered location notification which comes as nil type
        let nilFiltered = collection.filter { $0.type != nil }
        collection.removeAll()
        collection.append(contentsOf: nilFiltered)
        
        var doneCount = 0
        let checkListNotifications = collection.filter { $0.type == .checkList }
        for notification in checkListNotifications {
            let notification: PushNotification<ChecklistNotification> = convert(notification)
            if notification.payload?.isDone ?? false {
                doneCount += 1
            }
        }
        if doneCount > 2 {
            let filtered = collection.filter { $0.type != .checkList && $0.type != .plain && $0.type != .location }
            if filtered.count > 0 {
                collection.removeAll()
                collection.append(contentsOf: filtered)
                tableView.reloadData()
            } else { // show plain message
                let plainMessage = collection.filter { $0.type == .plain && $0.type != .location }
                collection.removeAll()
                collection.append(contentsOf: plainMessage)
                tableView.reloadData()
            }
        } else {
            let filtered = collection.filter { $0.type != .location }
            collection.removeAll()
            collection.append(contentsOf: filtered)
            tableView.reloadData()
        }
        if let tabBarController = tabBarController as? TabBarController,
            collection.first?.timestamp?.timeIntervalSince1970 ?? 1 > lastPeopleNotificationDate() {
            tabBarController.newNotificationsAvailable(notification: nil, true)
             
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            if appDelegate.showPeopleNotification {
                appDelegate.showPeopleNotification = false
                let genericNotification = collection[0]
                var message = ""
                var spotId = ""
                switch genericNotification.type {
                case .save, .comment, .verify, .follow, .spotcomment, .followRequestAccepted:
                    let notification: PushNotification<SpotNotification> = convert(genericNotification)
                    spotId = notification.payload?.spot?.id ?? ""
                    var titleString = ""
                    switch notification.type! {
                    case .save:
                        titleString = L10n.NotificationViewCell.labelSavedYourGem
                        break
                    case .comment:
                        titleString = L10n.NotificationViewCell.labelMentionedYouInComment
                        break
                    case .follow:
                        titleString = L10n.NotificationViewCell.labelAddedYouToTheirPeople
                        break
                    case .spotcomment:
                        titleString = L10n.NotificationViewCell.labelCommentedOnYourGem
                        break
                    case .verify:
                        titleString = L10n.NotificationViewCell.labelVerifiedYourGem
                        break
                    case .followRequestAccepted:
                        titleString = L10n.NotificationViewCell.labelAcceptedYourRequest
                        break
                    default:
                        break
                    }
                    message = "\(notification.payload?.user?.name ?? "") \(titleString)"
                    break
                case .followRequest:
                    let notification: PushNotification<SpotNotification> = convert(genericNotification);
                    spotId = notification.payload?.spot?.id ?? ""
                    message = "\(notification.payload?.user?.name ?? "") \(L10n.FollowRequestTableViewCell.string)"
                    break;
                case .reactHeartEyes, .reactGem, .reactDroolingFace, .reactClap, .reactRoundPushpin:
                    let notification: PushNotification<SpotNotification> = convert(genericNotification);
                    spotId = notification.payload?.spot?.id ?? ""
                    var titleString = ""
                    switch notification.type! {
                    case .reactHeartEyes:
                        titleString = "\(L10n.EmojiNotificationViewCell.reacted): \(Emoji.heart_eyes.code)"
                        break
                    case .reactGem:
                        titleString = "\(L10n.EmojiNotificationViewCell.reacted): \(Emoji.gem.code)"
                        break
                    case .reactDroolingFace:
                        titleString = "\(L10n.EmojiNotificationViewCell.reacted): \(Emoji.drooling_face.code)"
                        break
                    case .reactClap:
                        titleString = "\(L10n.EmojiNotificationViewCell.reacted): \(Emoji.clap.code)"
                        break
                    case .reactRoundPushpin:
                        titleString = "\(L10n.EmojiNotificationViewCell.reacted): \(Emoji.round_pushpin.code)"
                        break
                    default:
                        break
                    }
                    message = "\(notification.payload?.user?.name ?? "") \(titleString)"
                    break
                default:
                    break
                }
                var userInfo = [String: AnyObject]()
                userInfo["spotId"] = spotId as NSString
                userInfo["type"] = "\(genericNotification.type.rawValue)" as NSString
                appDelegate.showPopupNotification(message: message, userInfo: userInfo)
            }
        }
        // this is the last step when completing the refresh, if it does not reach here [EG]
        NotificationsViewController.isUpdateNeededForPeopleNotifications = false
    }
    
    private func lastPeopleNotificationDate() -> Double {
        return UserDefaults.standard.double(forKey: UserDefaultsKey.lastPeopleNotificationDate.rawValue)
    }
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let genericNotification = collection[indexPath.row]
        guard let cellType = cellDictionary[genericNotification.type] else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath)
        
        switch genericNotification.type {
        case .plain:
            let notification: PushNotification<PlainNotification> = convert(genericNotification)
            (cell as? PlainNotificationTableViewCell)?.set(notification)
            break
        case .checkList:
            let notification: PushNotification<ChecklistNotification> = convert(genericNotification)
            (cell as? ChecklistItemTableViewCell)?.set(notification)
            break
        case .save, .comment, .verify, .follow, .spotcomment, .followRequestAccepted:
            let notification: PushNotification<SpotNotification> = convert(genericNotification)
            let notificationCell = cell as? NotificationViewCell
            notificationCell?.set(notification)
            notificationCell?.delegate = self
            break
        case .followRequest:
            let notification: PushNotification<SpotNotification> = convert(genericNotification);
            let followRequestCell = cell as? FollowRequestTableViewCell;
            followRequestCell?.set(notification);
            followRequestCell?.setIndexPath(indexPath: indexPath);
            followRequestCell?.delegate = self;
            break;
        case .reactHeartEyes, .reactGem, .reactDroolingFace, .reactClap, .reactRoundPushpin:
            let notification: PushNotification<SpotNotification> = convert(genericNotification);
            let notificationCell = cell as? EmojiNotificationViewCell
            notificationCell?.set(notification)
            notificationCell?.delegate = self
            break
        case .location:
            break
        case .none:
            break
        case .all:
            break
        case .notLocation:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let genericNotification = collection[indexPath.row]
        let notification: PushNotification<ChecklistNotification> = convert(genericNotification)
        let mainString: String = notification.payload?.title ?? ""
        if genericNotification.type == .checkList && mainString.lowercased() == "scroll through 5 hidden gems" {
            return UITableView.automaticDimension
        } else {
            return 75
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genericNotification = collection[indexPath.row]
        if genericNotification.type == .checkList {
            switch indexPath.row {
            case 0:
                // open "The World" playlist page
                guard
                    let tabbar = tabBarController,
                    tabbar.viewControllers!.count > 0,
                    let navigationVC: UINavigationController = tabbar.viewControllers![0] as? UINavigationController,
                    navigationVC.viewControllers.count > 0,
                    let discoverViewController: DiscoverViewController = navigationVC.viewControllers[0] as? DiscoverViewController
                    else { break }
                discoverViewController.swipeMenuView.jump(to: 1, animated: false)
                tabbar.selectedIndex = 0
                break
            case 1:
                // open "Search" page with people tab
                guard
                    let tabbar = tabBarController,
                    tabbar.viewControllers!.count > 1,
                    let navigationVC: UINavigationController = tabbar.viewControllers![1] as? UINavigationController,
                    navigationVC.viewControllers.count > 0,
                    let searchViewController: SearchViewController = navigationVC.viewControllers[0] as? SearchViewController
                    else { break }
                if searchViewController.swipeMenuView != nil {
                    searchViewController.swipeMenuView.jump(to: 0, animated: false)
                }
                tabbar.selectedIndex = 1
                break
            case 2:
                // open "Upload" page
                guard let tabbar = tabBarController as? TabBarController else { break }
                tabbar.post(UIButton())
                break
            default:
                break
            }
        }
    }
    
    private func convert<T>(_ notification: HackCell.PayloadType) -> PushNotification<T> {
        let convertedNotification = PushNotification<T>.init()
        convertedNotification.id = notification.id
        convertedNotification.timestamp = notification.timestamp
        convertedNotification.type = notification.type
        convertedNotification.payload = try? notification.payload?.trimmingCharacters(in: ["\""]).data(using: String.Encoding.utf8)?.convert(T.self)
        return convertedNotification
    }
    
    private func checkPermissions() {
        
        guard !UserDefaults.bool(key: UserDefaultsKey.notificationAlertShownv2.rawValue) else { return }
        
        if LocationService.shared.isDenied() {
            LocationService.shared.openSettings(parent: tabBarController!)
            return
        }
        
        self.registerForPush()
    }
    
    private func registerForPush() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .authorized:
                // does not need to ask user again
                break
            case .notDetermined, .denied, .ephemeral, .provisional:
                self.getPermissions()
            @unknown default:
                // shouldn't be needed, maybe future proof
                self.getPermissions()
            }
        }
    }
    
    private func getPermissions() {
        DispatchQueue.main.sync {
            let alert = PermissionAlertController(title: L10n.NotificationsViewController.PermissionAlert.title, subTitle: L10n.NotificationsViewController.PermissionAlert.subTitle)
            
            alert.addButton(title: L10n.Common.yes, style: .normal, onClick:{
                AmplitudeAnalytics.logEvent(.acceptNotifPermission, group: .notifications)
                
                UserDefaults.save(value: true, forKey: UserDefaultsKey.notificationAlertShownv2.rawValue)
                
                // FCM
                if #available(iOS 10.0, *) {
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: { status, error in
                            AmplitudeAnalytics.setUserProperty(property: .notificationStatus, value: NSNumber(value: status))
                            if (status) {
                                AmplitudeAnalytics.logEvent(.allowNotifPermission, group: .notifications)
                            } else {
                                AmplitudeAnalytics.logEvent(.dontAllowNotifPermission, group: .notifications)
                            }
                        })
                } else {
                    let settings: UIUserNotificationSettings =
                        UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    UIApplication.shared.registerUserNotificationSettings(settings)
                }
                
                UIApplication.shared.registerForRemoteNotifications()
            })
            
            alert.addButton(title: L10n.Common.notNow, style: .additional, onClick:{
                AmplitudeAnalytics.logEvent(.declineNotifPermission, group: .notifications)
                
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    AmplitudeAnalytics.setUserProperty(property: .notificationStatus, value: NSNumber(value: settings.authorizationStatus == .authorized))
                }
                
                UserDefaults.save(value: true, forKey: UserDefaultsKey.notificationAlertShownv2.rawValue)
            })
            
            alert.show(parent: tabBarController!)
        }
    }
}

extension NotificationsViewController: ScrollableProtocol {
    
    func scrollToTop() {
        let topRow = IndexPath(row: 0, section: 0)
        if tableView.indexPathExists(indexPath: topRow) {
            tableView.scrollToRow(at: topRow, at: .top, animated: true)
        }
    }
}

class HackCell: UITableViewCell, Consignee {
    func set(_ something: PushNotification<String>) {
        
    }
}

class CodableObject: Codable {
    
}
