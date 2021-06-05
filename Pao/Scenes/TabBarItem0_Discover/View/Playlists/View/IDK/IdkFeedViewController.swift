//
//  IdkFeedViewController.swift
//  Pao
//
//  Created by kant on 22.04.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit
import Motion
import Instructions

class IdkFeedViewController: UIViewController, IMotion {
    
    // MARK: - Outlets
    
    @IBOutlet private var headerContainerView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var labelPlayListName: UILabel!
    @IBOutlet private var labelPlayListLocation: UILabel!
    @IBOutlet private var playListCoverImage: UIImageView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var gradientView: GradientView!
    
    // MARK: - Private properties
    
    lazy var spotsFeedViewController = SpotsFeedViewController()
    private lazy var playList = PlayList()
    
    // MARK: - Internal properties
    
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
        analyticsOpenEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        hideNavigationBar()
        
        if #available(iOS 13.0, *) {}
        else {
            UIApplication.shared.statusBarView?.backgroundColor = .clear
        }
        
        labelPlayListName.text = self.playList.name
        
        if let thumbnailURL = self.playList.cover?.urlFromString {
            playListCoverImage.kf.setImage(with: thumbnailURL)
        } else {
            playListCoverImage.image = Asset.Assets.Backgrounds.defaultCoverPhoto.image
            playListCoverImage.backgroundColor = .clear
        }
    }
    
    // MARK: - Actions
    
    @IBAction func goBack(_ sender: Any) {
        navigationController?.isMotionEnabled = true
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Internal methods
    
    func set(_ playlist: PlayList) {
        self.playList = playlist
    }
    
    // MARK: - Private methods
    
    private func hideNavigationBar() {
        let image = ColorName.navigationBarTint.color.image()
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.isHidden = true
    }
    
    private func initSpotsView() {
        spotsFeedViewController.isFeed = true
        spotsFeedViewController.isTheWorldView = isTheWorldView
        addChild(spotsFeedViewController)
        containerView.addSubview(spotsFeedViewController.view)
        spotsFeedViewController.view.constraintToFit(inContainerView: containerView)
        spotsFeedViewController.didMove(toParent: self)
        
        //Amplitude swipe event
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.spotsFeedViewController.spotCollectionViewController.amplitudeEventSwipe = .idkSwipe
            self.spotsFeedViewController.spotCollectionViewController.amplitudeEventGroup = .viewSpots
        }
    }
    
    private func setupChildControllers() {
        containerView.backgroundColor = .clear
    }
    
    private func setupLabels() {
        labelPlayListName.font = UIFont.appMedium.withSize(UIFont.sizes.veryLarge)
        labelPlayListLocation.font = .appNormal
        labelPlayListLocation.text = playList.description ?? L10n.IdkFeedViewController.PlayList.description
        setupGradient()
    }
    
    private func setupGradient() {
        gradientView.gradientColors = [
            ColorName.background.color.withAlphaComponent(0.5),
            ColorName.background.color
        ]
        gradientView.gradientLocations = [0, 1]
    }
    
    // MARK: - Analytics
    
    private func analyticsOpenEvent() {
        AmplitudeAnalytics.logEvent(.idk, group: .viewSpots)        
        FirbaseAnalytics.trackScreen(name: .idk)
    }
}
