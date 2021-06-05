//
//  PlayListTableViewController.swift
//  Pao
//
//  Created by OmShanti on 24/02/21.
//  Copyright © 2021 Exelia. All rights reserved.
//

import UIKit
import Payload

class PlayListTableViewController: TableViewController<PlayListTableViewCell>, UICollectionViewDataSource, UICollectionViewDelegate {

    public static var isUpdateNeededForPlaylist = false
    
    // MARK: - Internal properties
    
    var isTheWorldView = false

    // MARK: - Private properties
    
    private var sectionArray = [PlayListSection]()
    private lazy var cacher = Cacher<String, [PlayListSection]>(entryLifetime: 1 * 60 * 60) // 1 hour
    private let key = "PlayListSections"
    private let searchMotionIdentifier = "search_icon_search_bar"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        collection.bufferSize = 30
        registerNibsForViewController()
        setupTableView()
        super.viewDidLoad()

        setupGradient()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playlistUpdateNotificationAvailable), name: .playlistUpdateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        bfprint("-= PPL T UPDATE =- viewWillAppear")
        
        super.viewWillAppear(animated)
        
        setupNavigationItems()
        
        loadIfIsUpdateNeeeded()
    }
    
    @objc func willEnterForeground() {
        bfprint("-= PPL T UPDATE =- willEnterForeground")
        
        loadIfIsUpdateNeeeded()
    }

    func loadIfIsUpdateNeeeded() {
        bfprint("-= PPL T UPDATE =- loadIfIsUpdateNeeeded")
        
        bfprint("-= PPL T UPDATE =- isUpdateNeededForPlaylist was \(PlayListTableViewController.isUpdateNeededForPlaylist ? "true" : "false")")
        
        if (PlayListTableViewController.isUpdateNeededForPlaylist) {
            // seems like a refresh started but didn't complete
            self.fetchNetworkData()
        } else if sectionArray.count == 0 {
            fetchData()
        }
    }
    
    // MARK: - CollectionViewController<T> implementation
    
    override func getPayloads(completionHandler: @escaping ([PlayList]?) -> Void) -> PayloadTask? {
        completionHandler(nil)
        return nil
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "playListTableViewCell",
            for: indexPath
            ) as? PlayListTableViewCell else { return UITableViewCell() }
        
        if sectionArray.count > 0 {
            //cell.set(playLists[0])
            guard let sectionDict = sectionArray[safe: indexPath.row],
                  let title = sectionDict.title,
                  let layout = sectionDict.layout
            else { return UITableViewCell() }
            
            cell.titleLabel.text = title
            cell.collectionView.reloadData()
        
            cell.collectionView.tag = indexPath.row
            cell.collectionView.register(
                UINib(nibName: "CirclePlayListCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "circlePlayListCollectionViewCell"
            )
            cell.collectionView.register(
                UINib(nibName: "SquarePlayListCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "squarePlayListCollectionViewCell"
            )
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            let newSize = setupCellSize(collectionViewLayout: cell.collectionView.collectionViewLayout, isRoundCell: layout == .circle, style: sectionDict.style ?? .spots)
            cell.collectionViewHeightConstraint.constant = newSize.height > 0 ? newSize.height+14 : 165
        }
        return cell
    }
    
    // MARK: - Section Collection View data source methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionDict = sectionArray[safe: collectionView.tag],
              let items = sectionDict.items else { return 0 }
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = sectionArray[safe: collectionView.tag],
              let items = section.items,
              let layout = section.layout
        else { return UICollectionViewCell() }
        
        switch layout {
        case.square:
            if let spots = items as? [Spot] {
              guard let cell = collectionView.dequeueReusableCell(
                  withReuseIdentifier: "squarePlayListCollectionViewCell",
                  for: indexPath
                  ) as? SquarePlayListCollectionViewCell else { return UICollectionViewCell() }
              cell.set(spots[indexPath.item])
              cell.locationImageView.motionIdentifier = nil
              return cell
            }
        
        case .circle:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "circlePlayListCollectionViewCell",
                for: indexPath
                ) as? CirclePlayListCollectionViewCell else { return UICollectionViewCell() }
            if let playlists = items as? [PlayList] {
                cell.set(playlists[indexPath.item])
            } else if let locations = items as? [Location] {
                cell.setLocation(locations[indexPath.item])
            } else if let users = items as? [User] {
                cell.setUser(users[indexPath.item])
            }
            cell.thumbnailImage.motionIdentifier = nil
            return cell
        }
        return UICollectionViewCell()
    }

    // MARK: - UICollectionViewDelegate implementation
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playListSection = sectionArray[collectionView.tag]
        switch playListSection.style {
        case .spots: // Hidden Gems
            guard let items = playListSection.items as? [Spot] else { return }
            guard let spot = items[safe: indexPath.item] else { return }
            let postId = spot.id ?? ""
            let spotLocationName = spot.location?.name ?? ""
            let username = DataContext.cache.user.username ?? ""
            let (category, subCategory) = spot.getCategorySubCategoryNameList()
            let dateLaunched = spot.timestamp?.formateToISO8601String() ?? ""
            let properties = ["spot location name": spotLocationName, "username": username, "post ID": postId, "date launched": dateLaunched, "category": category, "subcategory": subCategory] as [String : Any]
            FirbaseAnalytics.logEvent(.hiddenGems)
            AmplitudeAnalytics.logEvent(.hiddenGems, group: .viewSpots, properties: properties)
            
            let viewController = ManualSpotsViewController(spots: items)
            viewController.title = playListSection.title
            viewController.scrolltoIndex = IndexPath(row: indexPath.item, section: 0)
            viewController.dataDidUpdate = { (updatedSpot: Spot) in
                self.cacher.removeFullData(forKey: self.key)
            }
            viewController.comesFrom = .hiddenGems
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        case .lists:
            guard let items = playListSection.items as? [PlayList] else { return }
            let playList = items[indexPath.item]
            let isIDKBubble = playList.name?.lowercased() == "Idk, Inspire me".lowercased()
            let viewController: IMotion = isIDKBubble ? IdkFeedViewController() : PlayListDetailsViewController()
            
            guard
                let cell = collectionView.cellForItem(at: indexPath) as? CirclePlayListCollectionViewCell,
                let rootViewController = viewController as? UIViewController else { return }
            
            let playlistNumber = playList.order ?? indexPath.row
            let properties = [
                "play list number":"\(playlistNumber)",
                "play list name":playList.name ?? "",
                "play list ID":playList.playlistId ?? "",
                "date launched":playList.start ?? ""
            ]
            FirbaseAnalytics.logEvent("daily_play_list_\(playlistNumber)", parameters: properties)
            AmplitudeAnalytics.logEvent(.playList, group: .viewSpots, properties: properties)
            
            cell.thumbnailImage.motionIdentifier = "section_\(indexPath.section)_row_\(indexPath.row)"
            viewController.isTheWorldView = isTheWorldView
            viewController.animationIdentifier = cell.thumbnailImage.motionIdentifier
            viewController.set(playList)

            (viewController as? PlayListDetailsViewController)?.playListLocation = "Global"
            (viewController as? PlayListDetailsViewController)?.playListIndex = indexPath.row

            let navigationController = UINavigationController(rootViewController: rootViewController)
            navigationController.isMotionEnabled = true
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        case .locations:
            guard let items = playListSection.items as? [Location] else { return }
            let location = items[indexPath.item]
            FirbaseAnalytics.logEvent(.searchBubbleLocation, parameters: ["location_name": location.name ?? ""])
            AmplitudeAnalytics.logEvent(.clickLocationBubble, group: .search, properties: ["city name": location.line1 ?? ""])
            
            let viewController = LocationInteractionViewController(location: location)
            viewController.comesFrom = .featuredCity
            let navigationController = UINavigationController(rootViewController:  viewController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true)
        case .people:
            guard let items = playListSection.items as? [User] else { return }
            let user = items[indexPath.item]
            if let navController = navigationController {
                FirbaseAnalytics.logEvent(.searchBubblePeople, parameters: ["user_id": user.id!])
                AmplitudeAnalytics.logEvent(.clickPeopleBubble, group: .search)
                
                navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
                let viewController = UserProfileViewController(user: user)
                viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
                navController.pushViewController(viewController, animated: true)
            }
        default:
            debugPrint("PlayListStyle is nil")
        }
    }
    
    // MARK: - Private methods
    
    private func registerNibsForViewController() {
        tableView.register(
            UINib(nibName: "PlayListTableViewCell", bundle: nil),
            forCellReuseIdentifier: "playListTableViewCell"
        )
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        //tableView.contentInset = UIEdgeInsets(top: stackTopInset, left: 0, bottom: 0, right: 0)
    }

    private func setupGradient() {
        let gradientView = SplashGradientView()
        gradientView.startPoint = .init(x: 0.4, y: 0)
        gradientView.endPoint = .init(x: 0.5, y: 0.6)
        gradientView.location = [0, 0.5]
        gradientView.style = .playListBackground
        tableView.backgroundView = gradientView
    }
        
    @objc private func playlistUpdateNotificationAvailable() {
        bfprint("-= PPL T UPDATE =- 1 PlayListTableViewController")
        bfprint("-= PPL T UPDATE =- 2 isUpdateNeededForPlaylist was \(PlayListTableViewController.isUpdateNeededForPlaylist ? "true" : "false")")
        
        PlayListTableViewController.isUpdateNeededForPlaylist = true

        switch(UIApplication.shared.applicationState) {
        case .active:
            bfprint("-= PPL T UPDATE =- 3 \(UIApplication.shared.applicationState) active")
            self.fetchNetworkData()
        case .inactive:
            bfprint("-= PPL T UPDATE =- 3 \(UIApplication.shared.applicationState) inactive")
        case .background:
            bfprint("-= PPL T UPDATE =- 3 \(UIApplication.shared.applicationState) background")
        @unknown default:
            bfprint("-= PPL T UPDATE =- 3 \(UIApplication.shared.applicationState) default")
        }
    }
    
    private func fetchData() {
        bfprint("-= PPL T UPDATE =- fetchData")
        
        DispatchQueue.global(qos: .default).async {
            if let sectionlists = self.cacher.getData(with: self.key) {
                self.sectionArray = sectionlists
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.reloadData()
                }
            } else {
                self.fetchNetworkData()
            }
        }
    }
    
    @objc private func fetchNetworkData() {
        bfprint("-= PPL T UPDATE =- 4 fetchNetworkData enter")
        
        let url = App.transporter.getUrl([PlayListSection].self, httpMethod: .get)
        APIManager.callAPIForWebServiceOperation(model: PlayList(), urlPath: url, methodType: "GET") { (apiStatus, playlistSections: [PlayListSection]?, responseObject, statusCode) in
            if(apiStatus){
                self.sectionArray = playlistSections ?? [PlayListSection]()
                self.reloadData()
                self.cacher.save(playlistSections, key: self.key)
                
                bfprint("-= PPL T UPDATE =- 7 fetchNetworkData done")
            }
        }
        
        bfprint("-= PPL T UPDATE =- 5 fetchNetworkData exit")
    }
    
    private func reloadData() {
        bfprint("-= PPL T UPDATE =- reloadData")
        
        refresh()
        activityIndicatorView?.stopAnimating()
        
        // changed to, this is a hack but I can't figure this out
        // it seems that removing the pull to refresh broke this
        // and makes it scroll by 81 only for new data and not cache
//        self.collectionView.setContentOffset(CGPoint(x: 0.0, y: -self.stackTopInset), animated: true)
        
        // this is the last step when completing the refresh, if it does not reach here [EG]
        bfprint("-= PPL T UPDATE =- 6 isUpdateNeededForPlaylist was \(PlayListTableViewController.isUpdateNeededForPlaylist ? "true" : "false")")
        PlayListTableViewController.isUpdateNeededForPlaylist = false
    }
    
    private func setupNavigationItems() {
        addDiscoverTitle()
        addSearchButton()
        navigationController?.navigationBar.isTranslucent = false
    }
    
    private func addDiscoverTitle() {
        let label = UILabel()
        label.text = L10n.PlayListTableViewController.title
        label.font = UIFont.appBold.withSize(UIFont.sizes.large)
        label.textColor = ColorName.accent.color
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: label)
    }
    
    private func addSearchButton() {
        let searchButton = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        searchButton.setImage(UIImage(named: "search-teal"), for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchButton.motionIdentifier = searchMotionIdentifier
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
    }
    
    @objc private func searchButtonTapped() {
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
    
    private func setupCellSize(collectionViewLayout: UICollectionViewLayout, isRoundCell: Bool = true, style: PlayListStyle) -> CGSize {
        let cellSpacing: CGFloat = 0
        let cellsPerRow: CGFloat = 2.5
        let cellRow = CGFloat(cellsPerRow - 1)
        let viewWidth = view.frame.size.width - cellSpacing * cellRow
        let cellWidth = viewWidth / CGFloat(cellsPerRow)
        var height: CGFloat = cellWidth - 22 * 2 + 47
        if !isRoundCell {
            height = (cellWidth - 25) + 41
        } else if style == .people {
            height = height + 44
        }
        guard let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }

        let newSize = CGSize(width: cellWidth, height: height)
        collectionViewFlowLayout.itemSize = newSize
        collectionViewFlowLayout.minimumLineSpacing = cellSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = cellSpacing
        return newSize
    }
}
