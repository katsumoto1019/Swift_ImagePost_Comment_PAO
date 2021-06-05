//
//  SpotsViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/26/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import Payload

import NVActivityIndicatorView
import RocketData

class SpotsViewController: BaseViewController, SpotCollectionViewCellDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Internal properties
    
    lazy var collection = RocketCollection<Spot>()
    var spotCollectionViewController: SpotCollectionViewController!
    var spotTableViewController: SpotTableViewController!
    var activeViewController: SpotsProtocol!
    
    var isCacheLoaded = false
    var isTheWorldView = false
    var addPaoLogoAndSearchButton = false
    var hideEmptySpotsView = false
    
    //used for FirebaseAnalytics, to distinguish feed viewControlelrs and other instances spotsViewController.
    var isFeed = false
    var swipeToCallback: ((_ indexPath: IndexPath) -> Void)?
    var comesFrom: ComesFrom?
    // MARK: - Private properties
    
    private var emailContactService: EmailContactService!
    private let presentedBorderWidth: CGFloat = 1.5
    private let searchMotionIdentifier = "search_icon_search_bar"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        setCacheKey()
        super.viewDidLoad()
        setupNavigationController()
        setupChildController()
        setupSpotUpdatedObserver()
        setupEmailContactService()
        if !hideEmptySpotsView {
            setDefaultBackgroundView(backgroundView: EmptySpotsView.loadFromNibNamed(nibNamed: "EmptySpotsView")!)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationItems()
        
        if isFeed {
            spotCollectionViewController.amplitudeEventSwipe = type(of: self) is SpotsFeedViewController.Type ? .theWorldSwipe : .yourPeopleSwipe
        }
        refreshFeedIfEmpty()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .carouselSwipe, object: nil)
        super.viewWillDisappear(animated)
    }
    
    // MARK: - BaseViewController implementation
    
    override func applyStyle() {
        super.applyStyle()
        containerView.backgroundColor = .clear
    }
    
    // MARK: - Internal methods
    
    private func setupNavigationItems() {
        if addPaoLogoAndSearchButton {
            addPaoLogo()
            addSearchButton()
        }
    }
    
    private func addPaoLogo() {
        if let logoImage = UIImage(named: "logo") {
            let button: UIButton = UIButton(type: .custom)
            button.setImage(logoImage, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            let ratio = logoImage.size.width / logoImage.size.height
            let height: CGFloat = 24
            let width = height * ratio
            button.widthAnchor.constraint(equalToConstant: width).isActive = true
            button.heightAnchor.constraint(equalToConstant: height).isActive = true
            
            let spacer = UIBarButtonItem.init(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            spacer.width = 20
            self.navigationItem.leftBarButtonItems = [spacer, UIBarButtonItem(customView: button)]
        }
    }
    
    private func addSearchButton() {
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
    
    func setCacheKey() {
        collection.cacheKey = "Feed"
    }
    
    func setDefaultBackgroundView(backgroundView: UIView) {
        spotCollectionViewController.collectionView?.backgroundView = backgroundView
        spotCollectionViewController.collectionView?.backgroundView?.isHidden = true
        spotTableViewController.tableView?.backgroundView = backgroundView
    }
    
    func toggleLayout(indexPath: IndexPath? = nil) {
        
        let fadeSpeed: Double = 0.2
        let isCollectionViewLayout = spotCollectionViewController.view.superview != nil
        
        UIView.animate(withDuration: fadeSpeed, animations: {
            self.containerView.alpha = 0
        }) { (animated) in
            isCollectionViewLayout ? self.showTableView() : self.showCollectionView()
            self.activeViewController.scrollTo(indexPath: indexPath, animated: false)
            
            UIView.animate(withDuration: fadeSpeed, animations: {
                self.containerView.alpha = 1
            })
        }
    }
    
    func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        
        bfprint("-= SOS =- getPayloads spots")
        
        let directory = getDocumentsDirectory().appendingPathComponent("feed")
        let skip = spotCollectionViewController.isReloading ? 0 : spotCollectionViewController.collection.count
        let take = spotCollectionViewController.collection.bufferSize
        let params = SpotsParams(skip: skip, take: take)
        
        if
            collection.isEmpty,
            !isCacheLoaded,
            let cachedSpotsData = try? Data(contentsOf: directory),
            let cachedSpots = try? JSONDecoder().decode([Spot].self, from: cachedSpotsData),
            cachedSpots.count > 0 {
            let uploadingSpots = self.getUploadingSpotsFromCache()
            if uploadingSpots.count > 0 {
                collection.append(contentsOf: uploadingSpots + cachedSpots)
            } else {
                collection.append(contentsOf: cachedSpots)
            }
            isCacheLoaded = true
            
            if (tabBarController as? TabBarController)?.IsDummyDisplay ?? false { return nil }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.spotCollectionViewController.refresh()
            }
            return nil
        }
        
        let url = App.transporter.getUrl([Spot].self, for: type(of: self), httpMethod: .get, queryParams: params)
        return APIManager.callAPIForWebServiceOperation(model: Spot(), urlPath: url, methodType: "GET") { (apiStatus, spots: [Spot]?, responseObject, statusCode) in
            if(apiStatus){
                self.isCacheLoaded = true
                if self.collection.isEmpty {
                    let data = try! JSONEncoder().encode(spots ?? [])
                    try? data.write(to: self.getDocumentsDirectory().appendingPathComponent("feed"))
                }
                var finalSpots = spots
                if UserDefaults.bool(key: UserDefaultsKey.isSpotUploading.rawValue) {
                    if spots != nil, spots!.count > 0 {
                        // spot upload failed
                        self.handleUploadFailStatusForAllWithLive(spots: spots!)
                        UserDefaults.save(value: false, forKey: UserDefaultsKey.isSpotUploading.rawValue)
                    }
                }
                if self.spotCollectionViewController.isCollectionReload {
                    let uploadingSpots = self.getUploadingSpotsFromCache()
                    if uploadingSpots.count > 0, spots != nil {
                        finalSpots = uploadingSpots + spots!
                    }
                }
                completionHandler(finalSpots)
            }else{
                completionHandler(nil)
            }
        } as? PayloadTask
    }
    
    func getUploadingSpotsFromCache() -> [Spot] {
        let directory = getDocumentsDirectory().appendingPathComponent("upload")
        if let uploadSpotsData = try? Data(contentsOf: directory) {
            if let uploadSpots = try? JSONDecoder().decode([Spot].self, from: uploadSpotsData) {
                return uploadSpots
            }
        }
        return []
    }
    
    func findSpotFromCollectionWith(spotId: String) -> (Spot?, Int) {
        var spotToFind: Spot?
        var idx = -1
        for index in 0..<collection.count {
            let spot = collection[index]
            if spot.id == spotId {
                spotToFind = spot
                idx = index
                break
            }
        }
        return (spotToFind, idx)
    }
    
    func addUploadingSpot(spot: Spot) {
        // Add spot to collection
        DispatchQueue.main.async {
            self.collection.insert(spot, at: 0)
            self.spotTableViewController.tableView.reloadData()
        }
        
        // Read spots from cache
        var cachedSpots = getUploadingSpotsFromCache()
        // Add spot to cache
        if cachedSpots.count > 0 {
            cachedSpots.insert(spot, at: 0)
        } else {
            cachedSpots.append(spot)
        }
        // Write cache file
        let data = try! JSONEncoder().encode(cachedSpots)
        try? data.write(to: self.getDocumentsDirectory().appendingPathComponent("upload"))
    }
    
    func removeSpotFromArray(spots: [Spot], spotId: String) -> [Spot] {
        let filteredSpots = spots.filter { (spot) -> Bool in
            return spot.id! != spotId
        }
        return filteredSpots
    }
    
    func deleteMediaFilesFromDocumentDirectory(media: SpotMediaDictionary?) {
        media?.values.forEach({ (spotMediaItem) in
            if spotMediaItem.id != nil {
                let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                if let url = URL(string: "\(path)/\(spotMediaItem.id!)") {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        })
    }
    
    func removeUploadedSpot(spotId: String, reloadData: Bool = true) {
        let (spotToRemove, _) = findSpotFromCollectionWith(spotId: spotId)
        if !reloadData, spotToRemove != nil {
            // Remove spot from collection
            self.remove(spot: spotToRemove!)
        }
        // delete media files from document directory
        self.deleteMediaFilesFromDocumentDirectory(media: spotToRemove?.media)
        
        var cachedSpots = getUploadingSpotsFromCache()
        // Remove spot from cache
        if cachedSpots.count > 0 {
            if spotToRemove != nil {
                if let index = cachedSpots.firstIndex(of: spotToRemove!) {
                    cachedSpots.remove(at: index)
                }
            }
        }
        // Write cache file
        let data = try! JSONEncoder().encode(cachedSpots)
        try? data.write(to: self.getDocumentsDirectory().appendingPathComponent("upload"))
        if reloadData {
            self.spotCollectionViewController.refresh()
        }
    }
    
    func setUploadStatusFor(spotId: String, status: SpotUploadStatus) {
        let (spotToUpdate, index) = findSpotFromCollectionWith(spotId: spotId)
        if spotToUpdate != nil {
            // update status in collection
            spotToUpdate?.uploadStatus = status.rawValue
            DispatchQueue.main.async {
                self.collection[index] = spotToUpdate!
                self.spotTableViewController.tableView.reloadData()
                self.spotCollectionViewController.collectionView.reloadData()
            }
            
            var cachedSpots = getUploadingSpotsFromCache()
            // Update spot upload status
            if cachedSpots.count > 0 {
                if let index = cachedSpots.firstIndex(of: spotToUpdate!) {
                    spotToUpdate?.uploadStatus = status.rawValue
                    cachedSpots[index] = spotToUpdate!
                }
            }
            // Write cache file
            let data = try! JSONEncoder().encode(cachedSpots)
            try? data.write(to: self.getDocumentsDirectory().appendingPathComponent("upload"))
        }
    }
    
    func setUploadFailStatusForAll() {
        var cachedSpots = getUploadingSpotsFromCache()
        // Update spot upload status
        if cachedSpots.count > 0 {
            cachedSpots = cachedSpots.map { (spot) -> Spot in
                if spot.uploadStatus == SpotUploadStatus.uploading.rawValue {
                    spot.uploadStatus = SpotUploadStatus.failed.rawValue
                }
                return spot
            }
            // Write cache file
            let data = try! JSONEncoder().encode(cachedSpots)
            try? data.write(to: self.getDocumentsDirectory().appendingPathComponent("upload"))
        }
    }
    
    func handleUploadFailStatusForAllWithLive(spots: [Spot]) {
        var cachedSpots = getUploadingSpotsFromCache()
        var idsToRemove = [String]()
        for cacheSpot in cachedSpots {
            let foundSpots = spots.filter { (spot) -> Bool in
                var result = false
                if spot.firebaseId == cacheSpot.id,
                   cacheSpot.uploadStatus == SpotUploadStatus.uploading.rawValue {
                    result = true
                }
                return result
            }
            for rSpot in foundSpots {
                self.deleteMediaFilesFromDocumentDirectory(media: rSpot.media)
                idsToRemove.append(rSpot.firebaseId!)
            }
        }
        for id in idsToRemove {
            cachedSpots = removeSpotFromArray(spots: cachedSpots, spotId: id)
        }
        // Update spot upload status
        if cachedSpots.count > 0 {
            cachedSpots = cachedSpots.map { (spot) -> Spot in
                if spot.uploadStatus == SpotUploadStatus.uploading.rawValue {
                    spot.uploadStatus = SpotUploadStatus.failed.rawValue
                }
                return spot
            }
        }
        // Write cache file
        let data = try! JSONEncoder().encode(cachedSpots)
        try? data.write(to: self.getDocumentsDirectory().appendingPathComponent("upload"))
    }
    
    func remove(spot: Spot) {
        DataModelManager.sharedInstance.deleteModel(spot)
    }
    
    // MARK: - Actions
    
    @IBAction private func changeFeedLayout(_ sender: Any) {
        NotificationCenter.default.post(name: .carouselSwipe, object: nil)
        toggleLayout()
    }
    
    // MARK: - SpotCollectionViewCellDelegate implementation
    
    func showProfile(user: User?) {
        guard let user = user else {return}
        
        FirbaseAnalytics.logEvent(isFeed ? .feedClickProfile : .clickProfileIcon)
        if isFeed {
            let source = type(of: self) == SpotsFeedViewController.self ? "the world" : "your people"
            let properties = ["source" : source]
            AmplitudeAnalytics.logEvent(.feedClickProfile, group: .viewSpots)
            AmplitudeAnalytics.logEvent(.viewOtherFromFeed, group: .otherProfile, properties: properties)
        } else if spotCollectionViewController.amplitudeEventSwipe == .swipeTopSpotsFeed {
            //Spot search
            AmplitudeAnalytics.logEvent(.viewOtherFromSpotSearch, group: .otherProfile)
        }
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
		}
		
        present(viewController, animated: true, completion: nil)
    }
    
    func setDarkMode(_ showDarkTheme: Bool) {
        if #available(iOS 13.0, *) {
            UIApplication.shared.keyWindow?.overrideUserInterfaceStyle = showDarkTheme ? .dark : .light
        }
    }
    
    func edit(spot: Spot) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Share Post", style: .default, handler: { (action) in
            
            let spotId = spot.id ?? ""
            let objectsToShare:URL = URL(string: "\(Bundle.main.shareUrl)/spot/\(spotId)")!
            let activityViewController = UIActivityViewController(activityItems : [objectsToShare], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                self.spotCollectionViewController.reloadData()
                FirbaseAnalytics.logEvent(.sharePost)
                let spotLocationName = spot.location?.name ?? ""
                let username = DataContext.cache.user.username ?? ""
                let postId = spot.id ?? ""
                let (category, subCategory) = spot.getCategorySubCategoryNameList()
                var properties = ["spot location name": spotLocationName, "username": username, "post ID": postId, "category": category, "subcategory": subCategory, "from": self.comesFrom?.rawValue ?? "", "to": activityType?.rawValue ?? ""] as [String : Any]
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
        } else {
            addViewersOption(alertController: alertController, spot: spot)
        }
        
        alertController.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil))
        
        present(alertController, animated: true)
    }
	
    func spotDataDidUpdate(updatedSpot: Spot) { }
    
	func showEmojies(emojies: [Emoji: EmojiItem], selectedEmojies selected: Emoji?, savedBy: [User]) {
		let viewController = SpotUsersViewController(emojies: emojies, selected: selected, savedBy: savedBy)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        present(viewController, animated: true, completion: nil)
    }
    
    func showComments(spot: Spot?) {
        guard let spot = spot else { return }
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        let viewController = CommentsTableViewController(style: .grouped, spot: spot)
        viewController.hidesBottomBarWhenPushed = true
        
        viewController.commentCallback = { (updatedSpot: Spot) in
            self.spotDataDidUpdate(updatedSpot: updatedSpot)
		}
        
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func deleteUploadingSpot(spot: Spot) {
        let alert = UIAlertController(title: nil, message: L10n.SpotsViewController.DeleteUploadingPostAlert.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: L10n.Common.yes, style: .destructive, handler: { (action: UIAlertAction!) in
            if spot.id != nil {
                self.removeUploadedSpot(spotId: spot.id!, reloadData: false)
            }
        }))
        alert.addAction(UIAlertAction(title: L10n.Common.no, style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func retryUpload(spot: Spot) {
        if let tabBar = self.tabBarController as? TabBarController {
            tabBar.retryUploadFor(spot: spot)
        }
    }
    
    @objc
    func didSelect(indexPath: IndexPath) { }
    
    @objc
    func cellWillDisplay(indexPath: IndexPath, cell: UICollectionViewCell) {
        swipeToCallback?(indexPath)
    }
    
    // MARK: - Private methods
    
    private func setupNavigationController() {
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: Asset.Assets.Icons.leftArrowNav.image,
                style: .plain,
                target: self,
                action: #selector(dismissViewController)
            )
        }
        navigationController?.navigationBar.backgroundColor = ColorName.navigationBarTint.color
    }
    
    private func setupSpotUpdatedObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(spotUpdated(_:)), name: .spotUpdate, object: nil)
    }
    
    private func setupEmailContactService() {
        emailContactService = EmailContactService(viewController: self)
    }
    
    //TODO: This function shouldn't be part of this class, logic should be executed by whoever wants a refresh
    private func refreshFeedIfEmpty() {
        guard
            collection.cacheKey == "Feed",
            !collection.canLoadMore,
            collection.filter({ $0.user?.id != DataContext.cache.user.id }).isEmpty,
            !collection.isLoading else { return }
        collection.loadData()
    }
    
    private func setupChildController() {
        collection.courier = getPayloads
        spotCollectionViewController = SpotCollectionViewController(collection: collection)
        spotCollectionViewController.isTheWorldView = isTheWorldView
        spotCollectionViewController.comesFrom = comesFrom
        spotTableViewController = SpotTableViewController(collection: collection)
        
        containerView.clipsToBounds = true
        activeViewController = spotCollectionViewController
        
        addChild(spotCollectionViewController)
        spotCollectionViewController.view.frame = containerView.bounds
        containerView.addSubview(spotCollectionViewController.view)
        spotCollectionViewController.didMove(toParent: self)
        
        addChild(spotTableViewController)
        spotTableViewController.view.frame = containerView.bounds
    }
    
    @objc
    private func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func spotUpdated(_ notification: Notification) {
        guard
            let new = notification.object as? Spot,
            let spotId = new.id,
            let spot = self.collection.first(where: {$0.id == spotId}) else { return }
        spot.description = new.description
        spot.category = new.category
        spot.categories = new.categories
        updateCell(spot: spot)
    }
    
    private func showTableView() {
        spotCollectionViewController.view.removeFromSuperview()
        spotTableViewController.view.frame = containerView.bounds
        containerView.addSubview(spotTableViewController.view)
        spotTableViewController.didMove(toParent: self)
        activeViewController = spotTableViewController
    }
    
    private func showCollectionView() {
        spotTableViewController.view.removeFromSuperview()
        spotCollectionViewController.view.frame = containerView.bounds
        containerView.addSubview(spotCollectionViewController.view)
        spotCollectionViewController.didMove(toParent: self)
        activeViewController = spotCollectionViewController
    }
    
    private func updateCell(spot: Spot) {
        guard
            let row = collection.firstIndex(of: spot),
            activeViewController is SpotCollectionViewController else { return }
        spotCollectionViewController.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
    }
    
    private func addViewersOption(alertController: UIAlertController, spot: Spot) {
        alertController.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.reportPost, style: .destructive, handler: { (action) in
            
            let postId = spot.id ?? ""
            let properties = ["post ID": postId]
            
            let categoryAlert = UIAlertController(title: nil, message: L10n.SpotsViewController.AddViewersOption.CategoryAlert.message, preferredStyle: .actionSheet)
            categoryAlert.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.itsSpam, style: .destructive, handler: { (action) in
                FirbaseAnalytics.logEvent( .spotSpam)
                AmplitudeAnalytics.logEvent(.spotSpam, group: .spot, properties: properties)
                
                self.emailContactService.composeEmail(subject: "\(L10n.SpotsViewController.AddViewersOption.spamPost): " + spot.id!)
            }))
            categoryAlert.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.itsInappropriate, style: .destructive, handler: { (action) in
                FirbaseAnalytics.logEvent(.spotInappropriate)
                AmplitudeAnalytics.logEvent(.spotInappropriate, group: .spot, properties: properties)
                
                self.emailContactService.composeEmail(subject: "\(L10n.SpotsViewController.AddViewersOption.inappropriatePost): " + spot.id!)
            }))
            
            categoryAlert.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil))
            
            self.present(categoryAlert, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.BlockUser.title, style: .destructive, handler: { (action) in
            FirbaseAnalytics.logEvent( .blockUser)
            AmplitudeAnalytics.logEvent(.blockUser, group: .spot)
            
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
            
            FirbaseAnalytics.logEvent(self.isFeed ? .editPostFeed : .editPost)
            if self.isFeed { AmplitudeAnalytics.logEvent(.editPostFromFeed, group: .spot) }
            else if self.tabBarController?.selectedIndex == 4 {
                AmplitudeAnalytics.logEvent(.editPostFromProfile, group: .spot)
            }
            
            let viewController = EditSpotDescriptionViewController(duplicate)
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = self
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: L10n.SpotsViewController.AddUsersOption.deletePost, style: .destructive, handler: { (action) in
            
            FirbaseAnalytics.logEvent(self.isFeed ? .deletePostFeed : .deletePost)
            if self.isFeed { AmplitudeAnalytics.logEvent(.deletePostFromFeed, group: .spot) }
            else if self.tabBarController?.selectedIndex == 4 {
                AmplitudeAnalytics.logEvent(.deletePostFromProfile, group: .spot)
            }
            AmplitudeAnalytics.addUserValue(property: .uploads, value: -1)
            
            self.delete(spot: spot)
        }))
    }
    
    private func delete(spot: Spot) {
        let alertController = UIAlertController(title: nil, message: L10n.SpotsViewController.DeletePostAlert.message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: L10n.Common.yes, style: .destructive, handler: { (action) in
            
            App.transporter.delete(Spot.self, returnType: DeleteResponse.self, pathVars: "", queryParams: IdParam(id: spot.id!), completionHandler: { (deleteResponse) in
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
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

// MARK: - UIViewControllerTransitioningDelegate implementation

extension SpotsViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = PullUpPresentationController(presentedViewController: presented, presenting: presenting)
        controller.style  = .borderdCorners(width: presentedBorderWidth)
        if let heightPrecent: CGFloat = [SpotUsersViewController.typeName: 0.5][String(describing: type(of: presented))] {
            controller.heightPercent = heightPrecent
        }
        controller.onDismiss = { [unowned self] in
            var screenName = self.screenName
            if self is SpotsFeedViewController {
                screenName = ScreenNames.theWorld.rawValue
            } else if !(self is ManualSpotsViewController || self is BoardSpotsViewController) {
                //If this is not one of above three viewontrollers, then it is spotsViewController for "Feed".
                screenName = ScreenNames.yourPeople.rawValue
            }
            FirbaseAnalytics.trackScreen(name: screenName)
        }
        return controller
    }
}
