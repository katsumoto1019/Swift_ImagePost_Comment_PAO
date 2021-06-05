//
//  PlayListCollectionViewController.swift
//  Pao
//
//  Created by MACBOOK PRO on 17/09/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Payload
import Motion

class PlayListCollectionViewController: CollectionViewController<PlayListCollectionViewCell>  {
    
    override var cellsPerRow: Int { return 2 }
    override var cellSpacing: CGFloat { return 0 }
    public static var isUpdateNeededForPlaylist = false
    
    // MARK: - Internal properties
    
    var isTheWorldView = false
    
    // MARK: - Private properties
    
    private var playLists = [PlayList]()
    private let stackTopInset: CGFloat = 81
    private lazy var cacher = Cacher<String, [PlayList]>(entryLifetime: 1 * 60 * 60) // 1 hour
    private let key = "PlayList"
    private let searchMotionIdentifier = "search_icon_search_bar"
    
    private lazy var emptyView: UIView = {
        var noResultText = NSMutableAttributedString(
            string: L10n.PlayListCollectionViewController.EmptyView.text)
        
        noResultText.addAttribute(.font, value: UIFont.appNormal.withSize(18), range: NSRange(location: 0, length: 8))
        
        let label = UILabel()
        label.font = UIFont.app.withSize(UIFont.sizes.small)
        label.attributedText = noResultText
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
    
    // MARK: - Lifecycle

    override func viewDidLoad() {

        collection.bufferSize = 30
        registerNibsForViewController()
        setupCollectionView()
        super.viewDidLoad()

        setupGradient()
        addHeader()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playlistUpdateNotificationAvailable), name: .playlistUpdateNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func playlistUpdateNotificationAvailable() {
        bfprint("-= PPL UPDATE =- 1 PlayListCollectionViewController")
        bfprint("-= PPL UPDATE =- 2 isUpdateNeededForPlaylist was \(PlayListCollectionViewController.isUpdateNeededForPlaylist ? "true" : "false")")
        PlayListCollectionViewController.isUpdateNeededForPlaylist = true

        switch(UIApplication.shared.applicationState) {
        case .active:
            bfprint("-= PPL UPDATE =- 3 \(UIApplication.shared.applicationState) active")
            self.fetchNetworkData()
        case .inactive:
            bfprint("-= PPL UPDATE =- 3 \(UIApplication.shared.applicationState) inactive")
        case .background:
            bfprint("-= PPL UPDATE =- 3 \(UIApplication.shared.applicationState) background")
        @unknown default:
            bfprint("-= PPL UPDATE =- 3 \(UIApplication.shared.applicationState) default")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        bfprint("-= PPL UPDATE =- viewWillAppear")
        
        super.viewWillAppear(animated)
        
        setupNavigationItems()
        setupCellSize()
        
        loadIfIsUpdateNeeeded()
    }
    
    @objc func willEnterForeground() {
        bfprint("-= PPL UPDATE =- willEnterForeground")
        
        loadIfIsUpdateNeeeded()
    }

    func loadIfIsUpdateNeeeded()
    {
        bfprint("-= PPL UPDATE =- loadIfIsUpdateNeeeded")
        
        if (PlayListCollectionViewController.isUpdateNeededForPlaylist) {
            // seems like a refresh started but didn't complete
            self.fetchNetworkData()
        } else if playLists.count == 0 {
            fetchData()
        }
    }
    
    // MARK: - CollectionViewController<T> implementation
    
    override func getPayloads(completionHandler: @escaping ([PlayList]?) -> Void) -> PayloadTask? {
        completionHandler(nil)
        return nil
    }
    
    // MARK: - UICollectionViewDataSource implementation

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionsCount
    }

    private var sectionsCount: Int {
        return Set(playLists.compactMap { $0.target }).count
    }
    
    private var globalPlayLists: [PlayList] {
        return playLists.filter { $0.target == "global" }
    }
    
    private var featuredPlayLists: [PlayList] {
        return playLists.filter { $0.target == "featured" }
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        guard
            kind == UICollectionView.elementKindSectionHeader,
            let sectionHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "header",
                for: indexPath
                ) as? SectionHeader else { return UICollectionReusableView() }

        let title = sectionsCount > 1 ? (indexPath.section == 0 ? L10n.PlayListCollectionViewController.Section.titleFeaturedToday : L10n.PlayListCollectionViewController.Section.titleBestOfPao) : L10n.PlayListCollectionViewController.Section.titleBestOfPao
        let subtitle = sectionsCount > 1 ? (indexPath.section == 0 ? L10n.PlayListCollectionViewController.Section.subTitleHereForTodayOnly : L10n.PlayListCollectionViewController.Section.subTitleNewSpotsUpdatedEveryFriday) : L10n.PlayListCollectionViewController.Section.subTitleNewSpotsUpdatedEveryFriday

        sectionHeader.titleLabel.text = title
        sectionHeader.subtitleLabel.text = subtitle

        return sectionHeader
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let featuredItemsCount = playLists.filter { $0.target == "featured" }.count
        let globalItemsCount = playLists.filter { $0.target == "global" }.count
        
        return sectionsCount > 1 ? (section == 0 ? featuredItemsCount : globalItemsCount) : globalItemsCount
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "playListCollectionViewCell",
            for: indexPath
            ) as? PlayListCollectionViewCell else { return UICollectionViewCell() }
        
        let playList = sectionsCount > 1 ? (indexPath.section == 0 ? featuredPlayLists[indexPath.row] : globalPlayLists[indexPath.row]) : playLists[indexPath.row]
        cell.set(playList)
        cell.thumbnailImage.motionIdentifier = nil
        return cell
    }
    
    // MARK: - UICollectionViewDelegate implementation
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let playList = sectionsCount > 1 ? (indexPath.section == 0 ? featuredPlayLists[indexPath.row] : globalPlayLists[indexPath.row]) : playLists[indexPath.row]
        let isIDKBubble = playList.name?.lowercased() == "Idk, Inspire me".lowercased()
        let viewController: IMotion = isIDKBubble ? IdkFeedViewController() : PlayListDetailsViewController()
        
        guard
            let cell = collectionView.cellForItem(at: indexPath) as? PlayListCollectionViewCell,
            let rootViewController = viewController as? UIViewController else { return }
        
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
        
        let playlistNumber = playList.order ?? indexPath.row
        let properties = [
            "play list number":"\(playlistNumber)",
            "play list name":playList.name ?? "",
            "play list ID":playList.playlistId ?? "",
            "date launched":playList.start ?? ""
        ]
        if sectionsCount > 1 && indexPath.section == 0 {
            FirbaseAnalytics.logEvent("daily_play_list_\(playlistNumber)", parameters: properties)
        }
        AmplitudeAnalytics.logEvent(.playList, group: .viewSpots, properties: properties)
    }
    
    // MARK: - Private methods
    
    private func registerNibsForViewController() {
        
        collectionView.register(
            UINib(nibName: "PlayListCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "playListCollectionViewCell"
        )

        collectionView.register(
            SectionHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "header"
        )
    }
    
    private func setupCollectionView() {
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: stackTopInset, left: 0, bottom: 0, right: 0)
    }

    private func setupGradient() {
        let gradientView = SplashGradientView()
        gradientView.startPoint = .init(x: 0.4, y: 0)
        gradientView.endPoint = .init(x: 0.5, y: 0.6)
        gradientView.location = [0, 0.5]
        gradientView.style = .playListBackground
        collectionView.backgroundView = gradientView
    }
    
    private func addHeader() {
        let headLabel = UILabel()
        headLabel.numberOfLines = 0
        headLabel.text = L10n.PlayListCollectionViewController.Header.text
        headLabel.translatesAutoresizingMaskIntoConstraints = false
        headLabel.font = UIFont.appHeavy.withSize(UIFont.sizes.headerTitle)
        styleLabel(label: headLabel)

        let headerStackView = UIStackView()
        headerStackView.axis = .vertical
        headerStackView.frame = CGRect(x: 0, y: -stackTopInset, width: collectionView.frame.width, height: 81)
        headerStackView.backgroundColor = UIColor.clear
        headerStackView.addArrangedSubview(headLabel)
        
        collectionView.addSubview(headerStackView)
    }
    
    private func styleLabel(label: UILabel) {
        label.textColor = ColorName.gradientTop.color
        label.textAlignment = .center
    }
    
    private func fetchData() {
        bfprint("-= PPL UPDATE =- fetchData")
        
        DispatchQueue.global(qos: .default).async {
            if let playlists = self.cacher.getData(with: self.key) {
                self.playLists = playlists
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.reloadData()
                    
                    // was [EG]
                    //self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            } else {
                self.fetchNetworkData()
            }
        }
    }
    
    @objc private func fetchNetworkData() {
        bfprint("-= PPL UPDATE =- 4 fetchNetworkData enter")
        
        App.transporter.get([PlayList].self) { [weak self] (playlists) in
            guard let self = self else { return }
            self.playLists = playlists ?? [PlayList]()
            self.reloadData()
            
            // was [EG]
            //self.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            
            self.cacher.save(playlists, key: self.key)
            
            bfprint("-= PPL UPDATE =- 6 fetchNetworkData done")
        }
        
        bfprint("-= PPL UPDATE =- 5 fetchNetworkData exit")
    }
    
    private func reloadData() {
        bfprint("-= PPL UPDATE =- reloadData")
        
        refresh()
        activityIndicatorView?.stopAnimating()
        
        // changed to, this is a hack but I can't figure this out
        // it seems that removing the pull to refresh broke this
        // and makes it scroll by 81 only for new data and not cache
        self.collectionView.setContentOffset(CGPoint(x: 0.0, y: -self.stackTopInset), animated: true)
        
        // this is the last step when completing the refresh, if it does not reach here [EG]
        PlayListCollectionViewController.isUpdateNeededForPlaylist = false
    }
    
    private func setupNavigationItems() {
        addDiscoverTitle()
        addSearchButton()
    }
    
    func addDiscoverTitle() {
        let label = UILabel()
        label.text = L10n.PlayListCollectionViewController.title
        label.font = UIFont.appBold.withSize(UIFont.sizes.large)
        label.textColor = ColorName.accent.color
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
    
    private func setupCellSize() {
        let cellRow = CGFloat(cellsPerRow - 1)
        let viewWidth = view.frame.size.width - cellSpacing * cellRow
        let cellWidth = viewWidth / CGFloat(cellsPerRow)
        let height: CGFloat = cellWidth - 22 * 2 + 47
        
        guard let collectionViewFlowLayout = collectionViewLayout as? UICollectionViewFlowLayout else { return }

        collectionViewFlowLayout.headerReferenceSize = CGSize(width: view.frame.size.width, height: 29)
        collectionViewFlowLayout.itemSize = CGSize(width: cellWidth, height: height)
        collectionViewFlowLayout.minimumLineSpacing = cellSpacing
        collectionViewFlowLayout.minimumInteritemSpacing = cellSpacing
    }
}
