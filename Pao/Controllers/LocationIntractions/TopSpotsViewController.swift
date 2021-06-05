//
//  SpotsAtLocationViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 08/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

import RocketData

class TopSpotsViewController: BaseViewController {
    
    @IBOutlet var buttons: [GradientButton]!
    @IBOutlet weak var tabsView: UIView!
    
    var pagerViewControllers = [UIViewController]()
    var pageViewController: UIPageViewController = UIPageViewController.init(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
    
    var spotCollectionViewController: LocationSpotCollectionViewController!
    var spotTableViewController: LocationSpotTableViewController!
    var spotMapViewController: SpotMapViewController!
    var emailContactService: EmailContactService!
    
    let collection = PayloadCollection<Spot>()
    var activeViewController: UIViewController!
    
    let buttonTitles = [L10n.TopSpotsViewController.titleList, L10n.TopSpotsViewController.titleMap, L10n.TopSpotsViewController.titleScroll]
    
    private var backStack = [UIViewController]()
    
    var searchRadius:Double = 10000
    var mapReloading = false
    var reloadData = false
    var locationViewport: Region? {
           didSet {
               if let viewport = locationViewport {
                let center = viewport.center
                self.location.coordinate = Coordinate(latitude: center.latitude, longitude: center.longitude)
                searchRadius = viewport.radius
                self.collection.loadData(true)
               }
           }
       }
    
    var location: Location!
    var categories: String? {
        didSet {
            if oldValue != categories {
                spotMapViewController.categories = categories

                spotTableViewController.refresh()
                spotCollectionViewController.reloadingView()
                spotMapViewController.reloadingView()
                emptyView.isHidden = true
            }
        }
    }
    var comesFrom: ComesFrom?
    
    @IBOutlet weak var separator: UIView!
    
    private var screenPrefix: String  {
        get{
            return (type(of: self) == YourPeopleSpotsViewController.self) ? L10n.Common.titleYourPeople : L10n.Common.titleTopSpots
        }
    }
    
    var  noResultText = L10n.LocationsSearchTableViewController.noResultText
    lazy var emptyView: UIView = {
        let label = UILabel()
        label.font = UIFont.app.withSize(UIFont.sizes.small)
        label.text = noResultText
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = ColorName.textWhite.color
        
        let view = UIView()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constraintToFit(inContainerView: view)
        view.isHidden = true
        return view
    }()
    
    
    init(location: Location) {
        super.init(nibName: String(describing: TopSpotsViewController.self), bundle: nil)
        
        self.location = location.duplicate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupButtons()
        setupChildControllers()
        setupPager()
        spotTableViewController.disablePullToRefresh()
        spotCollectionViewController.disablePullToRefresh()

        separator.backgroundColor = ColorName.textLightGray.color
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        FirbaseAnalytics.trackScreen(name: "\(screenPrefix) \(buttonTitles[buttons.firstIndex(where: {$0.isSelected}) ?? 0]) (Locations)")
    }
    
    func setupButtons() {
        for button in buttons {
            button.setTitleColor(UIColor.white, for: .normal)
            button.titleLabel?.font = UIFont.appNormal
            button.setBackgroundImage(UIColor.clear.as1ptImage(), for: .normal)
            button.setBackgroundImage(ColorName.accent.color.as1ptImage(), for: .highlighted)
            button.setBackgroundImage(UIColor.gradientImageWithBounds(colors: [ColorName.gradientTop.color.cgColor, ColorName.gradientBottom.color.cgColor]), for: .selected)
            button.drawBorder(color: UIColor.white,borderWidth: 0.5,cornerRadius: 5)
            button.clipsToBounds = true
            button.setTitle(buttonTitles[buttons.firstIndex(of: button)!], for: .normal)
            button.clipsToBounds = true
            button.layer.opacity = 0.82
            
            switch buttons.firstIndex(of: button) {
            case 0:
                button.addTarget(self, action: #selector(showSpotsList(sender:)), for: .touchUpInside)
                break
            case 1:
                button.addTarget(self, action: #selector(showSpotsMap(sender:)), for: .touchUpInside)
                break
            case 2:
                button.addTarget(self, action: #selector(showSpotsCollection(sender:)), for: .touchUpInside)
                break
            default:break
            }
        }
        
        buttons[0].isSelected = true
    }
    
    func loadData() {
        setupPager()
    }
    
    func setupPager() {
        collection.courier = getPayloads
        pageViewController.isPagingEnabled = false
        
        spotTableViewController = LocationSpotTableViewController(collection: collection)
        spotTableViewController.tableView.backgroundView = emptyView
        
        spotCollectionViewController = LocationSpotCollectionViewController(collection: collection)
        spotCollectionViewController.collectionView.backgroundView = emptyView
        spotCollectionViewController.comesFrom = comesFrom
        
        spotMapViewController = SpotMapViewController(collection: collection, location: self.location)
        spotMapViewController.parentController = self
        
        pagerViewControllers = [
            spotTableViewController,
            spotMapViewController,
            spotCollectionViewController
        ]
        
        spotTableViewController.delegate = self
        (pagerViewControllers[1] as! SpotMapViewController).delegate = self
        (pagerViewControllers[2] as! LocationSpotCollectionViewController).delegate = self
        
        (pagerViewControllers[1] as! SpotMapViewController).refreshCallback = {[weak self] (latitude, longitude, radius) in
            guard let self = self else { return }
            
            self.searchRadius = radius
            self.location.coordinate = Coordinate.init(latitude: latitude, longitude: longitude)
            self.location.googlePlaceId = nil
            
            /*
             self.mapReloading = true
            self.collection.loadData(true)
            self.mapReloading = false
            */
        }
        
        //HACK: Loading [pagerViewControllers[2]] is required to fulfil a requirement.
        pageViewController.setViewControllers([pagerViewControllers[2]], direction: .reverse, animated: false, completion: nil)
        
        //move tablvView down to avoid it comming under the tabs-containing view in parent viewController.
        if let tableView = (pagerViewControllers[0]  as? SpotTableViewController)?.tableView {
            tableView.contentInset = UIEdgeInsets(top: tabsView.frame.size.height + tableView.contentInset.top, left: 0, bottom: 0, right: 0)
        }
        
        //move collectionView down to avoid it comming under the tabs-containing view in parent viewController.
        if let collectionView = (pagerViewControllers[2]  as? LocationSpotCollectionViewController)?.collectionView {
            collectionView.contentInset = UIEdgeInsets(top: tabsView.frame.size.height + collectionView.contentInset.top, left: 0, bottom: 0, right: 0)
        }
        
        showSpotsList(sender: buttons[0])
    }
    
    private func setupChildControllers() {
        pageViewController.view.frame = self.view.bounds
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        view.sendSubviewToBack(pageViewController.view)
    }
    
    @objc func showSpotsList(sender: UIButton) {
        FirbaseAnalytics.logEvent(.listViewSearch)
        FirbaseAnalytics.trackScreen(name: "\(screenPrefix) \(buttonTitles[0]) (Locations)")
        AmplitudeAnalytics.logEvent(((type(of: self) == YourPeopleSpotsViewController.self) ? .searchLocRecent : .searchLocTopSpots), group: .search, properties: ["view" : "list"])

        pageViewController.setViewControllers([pagerViewControllers[0]], direction: .reverse, animated: false, completion: nil)
        activeViewController = pagerViewControllers[0]
        
        buttons.forEach { $0.isSelected = $0 == sender }
        tabsView.backgroundColor = ColorName.background.color
        
        separator.isHidden = false
        
        backStack.removeAll()
    }
    
    @objc func showSpotsMap(sender: UIButton) {
        FirbaseAnalytics.logEvent(.mapViewSearch)
        FirbaseAnalytics.trackScreen(name: "\(screenPrefix) \(buttonTitles[1]) (Locations)")
        AmplitudeAnalytics.logEvent(((type(of: self) == YourPeopleSpotsViewController.self) ? .searchLocRecent : .searchLocTopSpots), group: .search, properties: ["view" : "map"])
        AmplitudeAnalytics.logEvent(.searhLocMapView, group: .search)
        
        pageViewController.setViewControllers([pagerViewControllers[1]], direction: (pagerViewControllers.firstIndex(of: activeViewController) == 0 ? .forward : .reverse), animated: false, completion: nil)
        activeViewController = pagerViewControllers[1]
        
        buttons.forEach { $0.isSelected = $0 == sender }
        tabsView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        
        separator.isHidden = true
        
        //backStack
        if let index = backStack.firstIndex(of: pagerViewControllers[1]) {
            backStack.remove(at: index)
        }
        backStack.append(pagerViewControllers[1])
    }
    
    @objc func showSpotsCollection(sender: UIButton) {
        FirbaseAnalytics.logEvent(.scrollViewSearch)
        FirbaseAnalytics.trackScreen(name: "\(screenPrefix) \(buttonTitles[2]) (Locations)")
        AmplitudeAnalytics.logEvent(((type(of: self) == YourPeopleSpotsViewController.self) ? .searchLocRecent : .searchLocTopSpots), group: .search, properties: ["view" : "scroll"])
        AmplitudeAnalytics.logEvent(.searchLocScrollView, group: .search)

        pageViewController.setViewControllers([pagerViewControllers[2]], direction: .forward, animated: false, completion: nil)
        activeViewController = pagerViewControllers[2]
        
        buttons.forEach { $0.isSelected = $0 == sender }
        tabsView.backgroundColor = ColorName.background.color
        
        separator.isHidden = true
        
        //backStack
        if let index = backStack.firstIndex(of: pagerViewControllers[2]) {
            backStack.remove(at: index)
        }
        backStack.append(pagerViewControllers[2])
    }
    
    /// if action is consumed, then returns true, else return false
    func backPressed() -> Bool {
        if backStack.isEmpty {
            return false
        }
        
        _ = backStack.popLast()
        
        if  backStack.isEmpty {
            showSpotsList(sender: buttons[0])
        } else if (backStack.last as? SpotMapViewController) != nil {
            showSpotsMap(sender: buttons[1])
        } else {
            showSpotsCollection(sender: buttons[2])
        }
        
        return true
    }
    
    func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        if locationViewport == nil {
            return nil
        }
        if (categories == nil ) {
            noResultText = L10n.LocationsSearchTableViewController.noResultText
        } else {
            noResultText = L10n.TopSpotsViewController.noResultText
        }
        
        spotTableViewController.tableView.backgroundView = {
            let label = UILabel()
            label.font = UIFont.app.withSize(UIFont.sizes.small)
            label.text = noResultText
            label.numberOfLines = 0
            label.textAlignment = .center
            label.textColor = ColorName.textWhite.color
            
            let view = UIView()
            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.constraintToFit(inContainerView: view)
            view.isHidden = true
            return view
        }()
        
        if let type = location.type, !mapReloading {
            let params = LocationSpotsParams(skip: mapReloading ? 0 : collection.count, take: collection.bufferSize, long: location.coordinate!.longitude!, lat: location.coordinate!.latitude!, placeId: nil, following: false, radius: Int(searchRadius * 1.5), categories: categories, type: type, name: location.name, recent: false)
            return App.transporter.get([Spot].self, queryParams: params, completionHandler: completionHandler)
        }
        let params = LocationSpotsParams(skip: mapReloading ? 0 : collection.count, take: collection.bufferSize, long: location.coordinate!.longitude!, lat: location.coordinate!.latitude!, placeId: nil, following: false, radius: Int(searchRadius * 1.5), categories: categories, name: location.name, recent: false)
        return App.transporter.get([Spot].self, queryParams: params, completionHandler: completionHandler)
    }
    
    open func remove(spot: Spot) {
        DataModelManager.sharedInstance.deleteModel(spot)
    }
}

extension TopSpotsViewController: SpotCollectionViewCellDelegate {
	
    func cellWillDisplay(indexPath: IndexPath, cell: UICollectionViewCell) {
    }
    
    func updateCell(spot: Spot) {
        guard let row = collection.firstIndex(of: spot) else {return}
        
        if activeViewController is SpotCollectionViewController {
            spotCollectionViewController.collectionView.reloadItems(at: [IndexPath(row: row, section: 0)])
        }
    }
    
    func showProfile(user: User?) {
        guard let user = user else {return}
        
        FirbaseAnalytics.logEvent(.clickProfileIcon)
        AmplitudeAnalytics.logEvent(.viewOtherFromLocSearch, group: .otherProfile)
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
                // update data in collection
                if let index = self.collection.firstIndex(of: updatedSpot) {
                    self.collection[index] = updatedSpot
                }
                self.updateCell(spot: updatedSpot)
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

                self.emailContactService.composeEmail(subject: "\(L10n.SpotsViewController.AddViewersOption.spamPost): " + spot.id!)
            }))
            categoryAlert.addAction(UIAlertAction(title: L10n.SpotsViewController.AddViewersOption.itsInappropriate, style: .destructive, handler: { (action) in
                
                FirbaseAnalytics.logEvent(.commentInappropriate)

                self.emailContactService.composeEmail(subject: "\(L10n.SpotsViewController.AddViewersOption.inappropriatePost): " + spot.id!)
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
            navigationController?.setNavigationBarHidden(false, animated: false)            
            let viewController = CommentsTableViewController(style: .grouped, spot: spot)
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func didSelect(indexPath: IndexPath) {
        if activeViewController == pagerViewControllers[0] {
            //Map screen have implemented GoogleAnalytics inside.So we only handle List screen here.
//            FirbaseAnalytics.trackEvent(category: .uiAction, action: .tapSpotCell, label: collection[indexPath.row].id ?? "")
        }
        
        AmplitudeAnalytics.logEvent(.selectSpotFromCitySearchResult, group: .search, properties: ["view" : buttons[0].isSelected ? "list" : buttons[1].isSelected ? "map" : "scroll"])
        
        spotCollectionViewController.scrollTo(indexPath: indexPath)
        spotCollectionViewController.collectionView.layoutSubviews()
        buttons[0].isSelected = false
        buttons[2].isSelected = true
        showSpotsCollection(sender: buttons[2])
    }
}

extension TopSpotsViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = PullUpPresentationController(presentedViewController: presented, presenting: presenting)
        if let heightPrecent: CGFloat = [SpotUsersViewController.typeName: 0.5][String(describing: type(of: presented))] {
                  controller.heightPercent = heightPrecent
              }
        controller.onDismiss = {[unowned self] in
            FirbaseAnalytics.trackScreen(name: "\(self.screenPrefix) \(self.buttonTitles[2]) (Locations)")
        }
        return controller
    }
}
