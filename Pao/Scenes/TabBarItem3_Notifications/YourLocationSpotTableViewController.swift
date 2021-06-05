//
//  YourLocationSpotTableViewController.swift
//  Pao
//
//  Created by OmShanti on 08/12/20.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit
import RocketData
import Payload

class YourLocationSpotTableViewController: TableViewController<HackCell> {

    var locationSpotCollectionVC: LocationSpotCollectionViewController!
    var emailContactService: EmailContactService!
    var scrollViewDidScrollCallback: ((_ scrollView: UIScrollView) -> Void)?
    var scrollViewDidEndDeceleratingCallback: ((_ scrollView: UIScrollView) -> Void)?
    var backgroundSessionCompletionHandler: (([HackCell.PayloadType]?) -> Void)? = nil
    var passedCollection = PayloadCollection<PushNotification<String>>()
    var spotsCollection = PayloadCollection<Spot>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(LocationNotificationCell.self)
        tableView.separatorStyle = .none
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func willEnterForeground() {
        loadIfIsUpdateNeeeded()
    }
    
    func loadIfIsUpdateNeeeded() {
        if (NotificationsViewController.isUpdateNeededForLocationNotifications || collection.count == 0) {
            passedCollection.removeAll()
            self.refresh()
        }
    }
    
    override func getPayloads(completionHandler: @escaping ([PushNotification<String>]?) -> Void) -> PayloadTask? {
        
        bfprint("-= SOS =- getPayloads your locaction")
        
        if passedCollection.count > 0 {
            let array = passedCollection.map { (element) -> PushNotification<String> in
             return element
            }
            passedCollection.removeAll()
            completionHandler(array)
            didLoadNotifications()
            return nil
        } else {
            print("*** getPayloads start YourLocationSpotTableViewController 1")
            let params = NotificationParams(skip: collection.count, take: collection.bufferSize, type: .location)
            let url = App.transporter.getUrl([String].self, for: NotificationsViewController.self, httpMethod: .get, queryParams: params)
            return APIManager.callAPIForWebServiceOperation(model: PushNotification<String>(), urlPath: url, methodType: "GET") { (apiStatus, _: PushNotification<String>?, responseObject, statusCode) in
                if(apiStatus){
                    do{
                        let array = responseObject as? NSArray ?? []
                        let notificationArray = array.map({ (dictionary) -> PushNotification<String> in
                            let dic = dictionary as? NSDictionary ?? [:]
                            let notification = PushNotification<String>()
                            notification.id = dic["id"] as? String
                            notification.type = PushNotificationType(rawValue: dic["type"] as? Int ?? 0)
                            notification.timestamp = Date.init(timeIntervalSince1970: TimeInterval((dic["timestamp"] as? Int ?? 0)/1000))
                            let payloadData = try? JSONSerialization.data(withJSONObject: dic["payload"] as Any, options: JSONSerialization.WritingOptions.sortedKeys)
                            notification.payload = String(data: payloadData ?? Data(), encoding: String.Encoding.utf8)
                            return notification
                        })
                        completionHandler(notificationArray)
                        self.didLoadNotifications()
                    }catch{
                        completionHandler(nil)
                        return
                    }
                }else{
                    return
                }
            } as? PayloadTask
        }
    }
    
    private func didLoadNotifications() {
        let filtered = collection.filter { $0.type == .location }
        if let tabBarController = tabBarController as? TabBarController,
           filtered.first?.timestamp?.timeIntervalSince1970 ?? 1 > lastLocationNotificationDate() {
            tabBarController.newNotificationsAvailable(notification: nil, true, isLocationNotification: true)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            if appDelegate.showLocationNotification {
                appDelegate.showLocationNotification = false
                let genericNotification = collection[0]
                let notification: PushNotification<LocationNotification> = convert(genericNotification)
                let title = notification.payload?.title ?? ""
                let spotId = notification.payload?.spot?.id ?? ""
                var userInfo = [String: AnyObject]()
                userInfo["spotId"] = spotId as NSString
                userInfo["type"] = "\(genericNotification.type.rawValue)" as NSString
                appDelegate.showPopupNotification(message: title, userInfo: userInfo)
            }
        }
        spotsCollection.removeAll()
        for element in filtered {
            let notification: PushNotification<LocationNotification> = convert(element)
            if let spot = notification.payload?.spot {
                spotsCollection.append(spot)
            }
        }
        collection.removeAll()
        collection.append(contentsOf: filtered)
        tableView.reloadData()

        // this is the last step when completing the refresh, if it does not reach here
        // i.e. due to background mode, then it knows it's pending still [EG]
        NotificationsViewController.isUpdateNeededForLocationNotifications = false
    }
    
    private func lastLocationNotificationDate() -> Double {
        return UserDefaults.standard.double(forKey: UserDefaultsKey.lastLocationNotificationDate.rawValue)
    }
    
    private func convert<T>(_ notification: HackCell.PayloadType) -> PushNotification<T> {
        let convertedNotification = PushNotification<T>.init()
        convertedNotification.id = notification.id
        convertedNotification.timestamp = notification.timestamp
        convertedNotification.type = notification.type
        convertedNotification.payload = try? notification.payload?.trimmingCharacters(in: ["\""]).data(using: String.Encoding.utf8)?.convert(T.self)
        return convertedNotification
    }
    
    func updatedNotificationObect(index: PayloadCollection<Spot>.Index, updatedSpot: Spot) -> PushNotification<String> {
        let notification = collection[index]
        let payloadObject = try? notification.payload?.trimmingCharacters(in: ["\""]).data(using: String.Encoding.utf8)?.convert(LocationNotification.self)
        payloadObject?.spot = updatedSpot
        if let payloadData = try? JSONEncoder().encode(payloadObject) {
            notification.payload =  String(data: payloadData, encoding: .utf8)
        }
        return notification
    }
    
    // MARK: - Table view data source
    
    override open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // (indexPath.row + collection.bufferDelta >= collection.count) { // normally
        if (indexPath.row >= collection.count + 5) {
            loadData();
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LocationNotificationCell = tableView.dequeueReusableCell(withIdentifier: LocationNotificationCell.reuseIdentifier, for: indexPath) as! LocationNotificationCell
        let genericNotification = collection[indexPath.row]
        let notification: PushNotification<LocationNotification> = convert(genericNotification)
        cell.set(notification)
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect(indexPath: indexPath)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !(tableView.refreshControl?.isRefreshing ?? false) {
            scrollViewDidScrollCallback?(scrollView)
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !(tableView.refreshControl?.isRefreshing ?? false) {
            scrollViewDidEndDeceleratingCallback?(scrollView)
        }
    }
    
    open func remove(spot: Spot) {
        DataModelManager.sharedInstance.deleteModel(spot)
    }
}

extension YourLocationSpotTableViewController: SpotCollectionViewCellDelegate {
    
    func cellWillDisplay(indexPath: IndexPath, cell: UICollectionViewCell) {
    }
    
    func updateCell(spot: Spot) {
        guard let row = self.spotsCollection.firstIndex(of: spot) else {return}
        locationSpotCollectionVC.collection[row] = spot
        if locationSpotCollectionVC != nil {
            locationSpotCollectionVC.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
        }
    }
    
    func showProfile(user: User?) {
        guard let user = user else {return}
        
        //FirbaseAnalytics.logEvent(.clickProfileIcon)
        //AmplitudeAnalytics.logEvent(.viewOtherFromLocSearch, group: .otherProfile)
        
        if let navController = navigationController {
            navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
            let viewController = UserProfileViewController(user: user)
            viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
            navController.pushViewController(viewController, animated: true)
        }
    }
    
    func showGo(spot: Spot) {
        let viewController = GoViewController(spot: spot)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        viewController.selectBookmarkCallBack = { (updatedSpot: Spot) in
            self.spotDataDidUpdate(updatedSpot: updatedSpot)
            DispatchQueue.main.async {
                self.updateCell(spot: updatedSpot)
                // update data in collection
                if let index = self.spotsCollection.firstIndex(of: updatedSpot) {
                    self.spotsCollection[index] = updatedSpot
                    self.collection[index] = self.updatedNotificationObect(index: index, updatedSpot: updatedSpot)
                    self.tableView.reloadData()
                }
            }
        }
        present(viewController, animated: true, completion: nil)
    }
    
    func setDarkMode(_ showDarkTheme: Bool) {
        if #available(iOS 13.0, *) {
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = showDarkTheme ? .dark : .light
        }
    }
    
    func edit(spot: Spot) {
        FirbaseAnalytics.logEvent(.editPost)

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        alertController.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { (action) in
            
            let spotId = spot.id ?? ""
            let objectsToShare:URL = URL(string: "\(Bundle.main.shareUrl)/spot/\(spotId)")!
            let activityViewController = UIActivityViewController(activityItems : [objectsToShare], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                self.locationSpotCollectionVC.reloadData()
                FirbaseAnalytics.logEvent(.sharePost)
                let spotLocationName = spot.location?.name ?? ""
                let username = DataContext.cache.user.username ?? ""
                let postId = spot.id ?? ""
                let (category, subCategory) = spot.getCategorySubCategoryNameList()
                var properties = ["spot location name": spotLocationName, "username": username, "post ID": postId, "category": category, "subcategory": subCategory, "from": self.locationSpotCollectionVC.comesFrom?.rawValue ?? "", "to": activityType?.rawValue ?? ""] as [String : Any]
                AmplitudeAnalytics.logEvent(.sharePost, group: .spot, properties: properties)
                
                if !completed {
                    // User canceled
                    if activityType == nil {
                        self.setDarkMode(false)
                    }
                    return
                }
                // User completed activity
                self.setDarkMode(false)
                properties["to"] = activityType?.rawValue
                AmplitudeAnalytics.logEvent(.completeShare, group: .spot, properties: properties)
            }
            self.setDarkMode(true)
            self.present(activityViewController, animated: true, completion: nil)
        }))
        if spot.isUserSpot {
            addUsersOption(alertController: alertController, spot: spot)
        }
        else {
            addViewersOption(alertController: alertController, spot: spot)
        }
        
        alertController.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
    
    func spotDataDidUpdate(updatedSpot: Spot) { }
    
    private func addViewersOption(alertController: UIAlertController, spot: Spot) {
        alertController.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.reportPost, style: .destructive, handler: { (action) in
            
            let categoryAlert = UIAlertController(title: nil, message: L10n.SpotsViewController.AddViewersOption.CategoryAlert.message, preferredStyle: .actionSheet)
            categoryAlert.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.itsSpam, style: .destructive, handler: { (action) in
                
                FirbaseAnalytics.logEvent(.commentSpam)

                if let id = spot.id {
                    self.emailContactService.composeEmail(subject: "\(L10n.SpotsViewController.AddViewersOption.spamPost): " + id)
                }
            }))
            categoryAlert.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.itsInappropriate, style: .destructive, handler: { (action) in
                
                FirbaseAnalytics.logEvent(.commentInappropriate)

                if let id = spot.id {
                    self.emailContactService.composeEmail(subject: "\(L10n.SpotsViewController.AddViewersOption.inappropriatePost): " + id)
                }
            }))
            
            categoryAlert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil))
            categoryAlert.show(self, sender: nil)
            self.present(categoryAlert, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.BlockUser.title, style: .destructive, handler: { (action) in
            
            FirbaseAnalytics.logEvent(.blockUser)

            let userBlock = UserBlock()
            userBlock.id = spot.user?.id
            App.transporter.post(userBlock, completionHandler: { (isSuccess) in
                if isSuccess == true {
                    self.showMessagePrompt(message: L10n.SpotsViewController.AddViewersOption.BlockUser.message)
                }
            })
        }))
    }
    
    private func addUsersOption(alertController: UIAlertController, spot: Spot) {
        guard let duplicate = spot.duplicate() else {return}
        
        alertController.addAction(UIAlertAction(title: L10n.SpotsViewController.AddUsersOption.editPost, style: .default, handler: { (action) in
            
            FirbaseAnalytics.logEvent(.editPost)

            let viewController = EditSpotDescriptionViewController(duplicate)
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = self
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
            
        }))
        
        alertController.addAction(UIAlertAction(title: L10n.SpotsViewController.AddUsersOption.deletePost, style: .destructive, handler: { (action) in
            FirbaseAnalytics.logEvent(.deletePost)
            AmplitudeAnalytics.addUserValue(property: .uploads, value: -1)

            self.delete(spot: spot)
        }))
    }
    
    func delete(spot: Spot) {
        guard let id = spot.id else {
            self.showMessagePrompt(message: L10n.SpotsViewController.DeletePostAlert.errorMessage)
            return
        }
        let alertController = UIAlertController(title: nil, message: L10n.SpotsViewController.DeletePostAlert.message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: L10n.Common.yes, style: .destructive, handler: { (action) in
                        
            App.transporter.delete(Spot.self, returnType: DeleteResponse.self, pathVars: "", queryParams: IdParam(id: id), completionHandler: { (deleteResponse) in
                if let board = deleteResponse?.board {
                    self.remove(spot: spot)
                    DataContext.cache.loadUser()
                    DataContext.cache.updateBoard(board: board)
                } else {
                    self.showMessagePrompt(message: L10n.SpotsViewController.DeletePostAlert.errorMessage)
                }
            })
        }))
        
        alertController.addAction(UIAlertAction(title: L10n.Common.no, style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
    
    func deleteUploadingSpot(spot: Spot) {
        //
    }
    
    func retryUpload(spot: Spot) {
        //
    }

    func showEmojies(emojies: [Emoji: EmojiItem], selectedEmojies: Emoji?, savedBy: [User]) {

        let viewController = SpotUsersViewController(emojies: emojies, selected: selectedEmojies, savedBy: savedBy)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self

        present(viewController, animated: true, completion: nil)
    }
    
    func showComments(spot: Spot?) {
        if let spot = spot {
            let viewController = CommentsTableViewController(style: .grouped, spot: spot)
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func didSelect(indexPath: IndexPath) {
        let spot = spotsCollection[indexPath.row]
        let notification = collection[indexPath.row]
        let notificationId = notification.id ?? ""
        let bizUsername = spot.user?.username ?? ""
        let spotLocationName = spot.location?.name ?? ""
        let postId = spot.id ?? ""
        let properties = ["notification ID":notificationId, "biz username":bizUsername, "spot location name":spotLocationName, "post id": postId]
        FirbaseAnalytics.logEvent(.bizNotificationToSpot)
        AmplitudeAnalytics.logEvent(.bizNotificationToSpot, group: .notifications, properties: properties)
        
        locationSpotCollectionVC = LocationSpotCollectionViewController(collection: self.spotsCollection)
        locationSpotCollectionVC.collection.courier = getPayloads
        locationSpotCollectionVC.delegate = self
        locationSpotCollectionVC.title = "Boulder, Colorado"
        locationSpotCollectionVC.scrollTo(indexPath: indexPath)
        locationSpotCollectionVC.collectionView.layoutSubviews()
        self.navigationController?.pushViewController(locationSpotCollectionVC, animated: true)
    }
    
    func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        completionHandler(nil)
        return nil
    }
}

extension YourLocationSpotTableViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = PullUpPresentationController(presentedViewController: presented, presenting: presenting)
        if let heightPrecent: CGFloat = [SpotUsersViewController.typeName: 0.5][String(describing: type(of: presented))] {
                  controller.heightPercent = heightPrecent
              }
        controller.onDismiss = {[unowned self] in
            //FirbaseAnalytics.trackScreen(name: "\(self.screenPrefix) \(self.buttonTitles[2]) (Locations)")
        }
        return controller
    }
}
