//
//  PlayListDetailsViewController.swift
//  Pao
//
//  Created by MACBOOK PRO on 02/10/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Motion
import Instructions

class PlayListDetailsViewController: UIViewController, IMotion {
    
    // MARK: - Outlets
    
    @IBOutlet private var headerContainerView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var labelPlayListName: UILabel!
    @IBOutlet private var labelPlayListLocation: UILabel!
    @IBOutlet private var playListCoverImage: UIImageView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var gradientView: GradientView!
    
    // MARK: - Private properties
    
    lazy var manualSpotViewController = ManualSpotsViewController(spots: [])
    private lazy var playList = PlayList()
    private lazy var cacher = Cacher<String, [Spot]>(entryLifetime: 1 * 60 * 60) // 1 hour
    private var key: String {
        return playList.playlistId ?? ""
    }
    private var event: PlayLists? {
        guard
            let name = playList.name?.lowercased(),
            let event = PlayLists(rawValue: name) else { return nil }
        return event
    }
    
    // MARK: - Internal properties
    
    var coachMarksController = CoachMarksController()
    var tutorialType: SpotTutorialType?
    var tutorialTypeIndexes: [SpotTutorialType: Int]?
    var playListLocation: String = "Global"
    var playListIndex = 0
    var animationIdentifier: String?
    var isTheWorldView = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isMotionEnabled = false
        
        headerContainerView.motionIdentifier = animationIdentifier
        view.backgroundColor = ColorName.navigationBarTint.color
        setupChildControllers()
        setupLabels()
        initSpotsView()
        initTutorialPopups()
        analyticsOpenEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar()
        fetchData()
        
        if #available(iOS 13.0, *) {}
        else {
            UIApplication.shared.statusBarView?.backgroundColor = .clear
        }
        
        labelPlayListName.text = playList.name
        
        if let thumbnailURL = playList.cover?.urlFromString {
            playListCoverImage.kf.setImage(with: thumbnailURL)
        } else {
            playListCoverImage.image = Asset.Assets.Backgrounds.defaultCoverPhoto.image
            playListCoverImage.backgroundColor = .clear
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func goBack(_ sender: Any) {
        navigationController?.isMotionEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Internal methods
    
    func set(_ playlist: PlayList) {
        self.playList = playlist
    }
    
    // MARK: - Private methods
    
    private func initSpotsView() {
        manualSpotViewController.hideEmptySpotsView = true
        manualSpotViewController.isTheWorldView = isTheWorldView
        addChild(manualSpotViewController)
        containerView.addSubview(manualSpotViewController.view)
        manualSpotViewController.view.constraintToFit(inContainerView: containerView)
        manualSpotViewController.didMove(toParent: self)
        analyticsSwipeEventSetup()
		
        manualSpotViewController.dataDidUpdate = { (spot: Spot) in
			self.cacher.removeFullData(forKey: self.key)
		}
    }
    
    private func hideNavigationBar() {
        let image = ColorName.navigationBarTint.color.image()
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.isHidden = true
    }
    
    private func analyticsSwipeEventSetup() {
        //Amplitude swipe event
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.manualSpotViewController.spotCollectionViewController.amplitudeEventSwipe = .playListSwipe
            self.manualSpotViewController.spotCollectionViewController.amplitudeEventGroup = .viewSpots
            let properties = [
                "play list number":"\(self.playList.order ?? self.playListIndex)",
                "play list name":self.playList.name ?? "",
                "play list ID":self.playList.playlistId ?? "",
                "date launched":self.playList.start ?? ""
            ]
            self.manualSpotViewController.spotCollectionViewController.playListProperties = properties
            self.manualSpotViewController.spotCollectionViewController.comesFrom = .playList
        }
    }
    
    private func initTutorialPopups() {
        /// tutorial popups
        let popupTip = UserDefaults.bool(key: UserDefaultsKey.doneTutorialForSpotTip.rawValue)
        let popupSave = UserDefaults.bool(key: UserDefaultsKey.doneTutorialForSpotSaveAction.rawValue)
        
        if !popupTip, !popupSave { /// User has not seen any of the following popup yet.
            tutorialTypeIndexes = [.tip: 3, .save: 5]
        } else if !popupSave { /// user has seen .'Tip' popup only
            tutorialTypeIndexes = [.save: 2]
        }
        if tutorialTypeIndexes != nil {
            setTutorials()
            
            manualSpotViewController.swipeToCallback = { [weak self] indexPath in
                guard
                    let self = self,
                    let popupTypeDic = self.tutorialTypeIndexes?.first(where: { $0.value == indexPath.row }) else {
                    return
                }
                self.startTutorial(type: popupTypeDic.key)
            }
        }
    }
    
    private func setupChildControllers() {
        containerView.backgroundColor = .clear
    }
    
    private func setupLabels() {
        labelPlayListName.font = UIFont.appMedium.withSize(UIFont.sizes.medium+1)
        labelPlayListLocation.font = UIFont.appNormal
        labelPlayListLocation.text = playList.description ?? L10n.PlayListDetailsViewController.PlayList.description
        setupGradient()
    }
    
    private func setupGradient() {
        gradientView.gradientColors = [
            ColorName.background.color.withAlphaComponent(0.5),
            ColorName.background.color
        ]
        gradientView.gradientLocations = [0, 1]
    }
    
    private func fetchData() {
        DispatchQueue.global(qos: .default).async {
            if let spots = self.cacher.getData(with: self.key) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.manualSpotViewController.updateSpots(spots: spots)
                }
            } else {
                self.fetchNetworkData()
            }
        }
    }

    
    private func fetchNetworkData() {
        
        let params = playListSpotParams(skip: 0 , take: 30, playlistId: playList.playlistId, schedule: true)
        App.transporter.get([Spot].self, for: type(of: self), queryParams: params, completionHandler: { [weak self] spots in
            guard let self = self, let spots = spots else { return }
            self.manualSpotViewController.updateSpots(spots: spots)
            
            self.cacher.save(spots, key: self.key)
        })
    }
    
    // MARK: - Analytics
    
    private func analyticsOpenEvent() {
        if let event = event?.analyticName {
            AmplitudeAnalytics.logEvent(event, group: .viewSpots)
        }
        
        if let event = event?.screenName {
            FirbaseAnalytics.trackScreen(name: event)
        }
    }
}
