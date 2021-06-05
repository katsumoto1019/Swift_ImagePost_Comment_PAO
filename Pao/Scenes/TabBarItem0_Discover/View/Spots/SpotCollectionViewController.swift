//
//  SpotCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/1/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import Payload
import NVActivityIndicatorView

class SpotCollectionViewController: CollectionViewController<SpotCollectionViewCell> {
    
    // MARK: - Private properties
    
    private let refreshOffset: CGFloat = -15
    
    // MARK: - Analytics
    
    /// Google analytics
    private var currentPage = 0 //used for detecting rigth/left swipe
    private var actionRightSwipe: EventAction = .spotSwipe
    private var actionLeftSwipe: EventAction = .spotSwipe
    private var actionImageSwipe: EventAction = .spotScrollImages
    
    private var startingIndex = 0
    private var lastScrollOffset: CGFloat = 0
    
    /// Amplitude analytics
    var amplitudeEventSwipe: EventName?
    var amplitudeEventGroup: EventGroup = .viewSpots
    
    var comesFrom: ComesFrom?
    /// Playlist properties
    var playListProperties: [String: Any] = [:]
    
    // MARK: - Internal properties
    
    var isReloading = false
    var isTheWorldView = false
    var isHorizontalPullToRefreshConfigured = false
    var isCollectionReload = true
    
    lazy var centerSpinnerView: NVActivityIndicatorView? =
        NVActivityIndicatorView(
            frame: CGRect(x: 0, y: 0, width: 40, height: 40),
            type: .circleStrokeSpin,
            color: ColorName.textGray.color,
            padding: 8)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startingIndex = UserDefaults.standard.integer(forKey: UserDefaultsKey.curatedFeedIndex.rawValue)
        collectionView?.showsHorizontalScrollIndicator = false
        
        refreshControl?.endRefreshing()
        
        let carouselFlowLayout = UPCarouselFlowLayout()
        
        carouselFlowLayout.sideItemAlpha = 1
        carouselFlowLayout.sideItemScale = 0.85
        carouselFlowLayout.spacingMode = .overlap(visibleOffset: 8)
        carouselFlowLayout.scrollDirection = .horizontal
        
        collectionView?.collectionViewLayout = carouselFlowLayout
        
        setCarouselHeight();
    }
    
    func setCarouselHeight() {
        if let carouselFlowLayout = collectionView?.collectionViewLayout as? UPCarouselFlowLayout {
            
            var height: CGFloat = UIScreen.main.bounds.height;
            if self.parent?.parent as? PlayListDetailsViewController == nil {
                height = height - 24
            }
            if #available(iOS 11.0, *) {
                if let window = UIApplication.shared.keyWindow {
                    height = height - window.safeAreaInsets.bottom
                }
            }
            let top = collectionView?.superview?.convert(collectionView.frame, to: nil).origin.y ?? 0;
            carouselFlowLayout.itemSize.width = UIScreen.main.bounds.width - 56
            var postHeight = carouselFlowLayout.itemSize.width * (UIDevice.hasNotch ? 2 : 16 / 9)
            if (postHeight + top > height) {
                postHeight = height - top
            }
            carouselFlowLayout.itemSize.height = postHeight.rounded(.down)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if
            !isHorizontalPullToRefreshConfigured,
            let activityIndicatorView = activityIndicatorView,
            let superview = view.superview {
            isHorizontalPullToRefreshConfigured = true
            activityIndicatorView.removeFromSuperview()
            superview.addSubview(activityIndicatorView)
            activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            if let centerSpinnerView = centerSpinnerView {
                centerSpinnerView.startAnimating()
                superview.addSubview(centerSpinnerView)
                centerSpinnerView.translatesAutoresizingMaskIntoConstraints = false
                centerSpinnerView.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
                centerSpinnerView.centerYAnchor.constraint(equalTo: superview.centerYAnchor).isActive = true
            }
            collection.elementsChanged.append { _ in
                self.reset()
            }
            
            collection.loaded.append {_ in
                self.reset()
            }
        }
        
        setCarouselHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard let activityIndicatorView = activityIndicatorView else { return }
        var frame = activityIndicatorView.frame
        frame.origin.x = 24
        frame.origin.y = view.frame.height / 2
        activityIndicatorView.frame = frame
        
        setCarouselHeight()
    }
    
    // MARK: - UICollectionViewDelegate implementation
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        if let parent = parent as? SpotCollectionViewCellDelegate {
            (cell as? SpotCollectionViewCell)?.delegate = parent
            parent.cellWillDisplay(indexPath: indexPath, cell: cell)
            
            if isTheWorldView {
                let value: Int = startingIndex + indexPath.item
                UserDefaults.save(value: value, forKey: UserDefaultsKey.curatedFeedIndex.rawValue)
                if
                    !UserDefaults.bool(key: UserDefaultsKey.fiveSwipe.rawValue),
                    UserDefaults.integer(key: UserDefaultsKey.curatedFeedIndex.rawValue) >= 5 {
                    App.transporter.post(ChecklistItem(id: ChecklistItemType.fiveSwipe.rawValue)) { (isSuccess) in
                        let isSuccess: Bool = isSuccess == true
                        UserDefaults.save(value: isSuccess, forKey: UserDefaultsKey.fiveSwipe.rawValue)
                        if isSuccess {
                            NotificationCenter.default.post(name: .newNotifications, object: nil)
                        }
                    }
                }
            }
        }
        
        if let cell = cell as? SpotCollectionViewCell {
            cell.imageCollectionViewController.gaSwipeAction = actionImageSwipe
            cell.isTheWorldView = isTheWorldView
            cell.playListProperties = playListProperties
            cell.comesFrom = self.comesFrom
        }
        
        // Now deprecated, was live in v3.16 and removed for 3.17+
        // this code and method should be deleted
        //showEmojiTipAlertIfNeeded()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: .carouselSwipe, object: nil)
        lastScrollOffset = scrollView.contentOffset.x
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let count = CGFloat(collection.count)
        let pageWidth = collectionView.contentSize.width / count
        let offset = collectionView.contentOffset.x / pageWidth
        let ceilOffset = ceil(offset)
        let currentPage = Int(ceilOffset)
        
        let isRightSwipe = currentPage < self.currentPage
        let action = isRightSwipe ? actionRightSwipe : actionLeftSwipe
        
        if collection.count > currentPage {
            self.currentPage = currentPage
            if let id = collection[currentPage].id {
                FirbaseAnalytics.logEvent(action, parameters: ["spot_id": id])
            }
        }
        
        if let swipeEvent = amplitudeEventSwipe {
            switch comesFrom {
            case .hiddenGems:
                AmplitudeAnalytics.logEvent(.hiddenGemSwipe, group: amplitudeEventGroup, properties: ["direction": isRightSwipe ? "right" : "left"])
            case .playList:
                playListProperties["direction"] = isRightSwipe ? "right" : "left"
                AmplitudeAnalytics.logEvent(swipeEvent, group: amplitudeEventGroup, properties: playListProperties)
            default:
                AmplitudeAnalytics.logEvent(swipeEvent, group: amplitudeEventGroup, properties: ["direction": isRightSwipe ? "right" : "left"])
            }
            if swipeEvent == .theWorldSwipe || swipeEvent == .yourPeopleSwipe {
                AmplitudeAnalytics.addUserValue(property: .postsSwiped, value: 1)
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collection.count > 0 && collectionView.contentSize.width > 0 {
            let pageWidth = collectionView.contentSize.width / CGFloat(collection.count)
            if collection.count > 0 {
                if abs(scrollView.contentOffset.x - lastScrollOffset) > (pageWidth * 0.6) {
                    if let cell = collectionView.cellForItem(at: IndexPath(item: self.currentPage, section: 0)) as? SpotCollectionViewCell {
                        if !cell.descriptionViewHeightConstraint.isActive {
                            cell.collapse(false)
                        }
                        lastScrollOffset = collectionView.contentOffset.x
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(800)) {
                            //cell.imageCollectionViewController.reset()
                            cell.imageCollectionViewController.collectionView.contentOffset = CGPoint(x: 0, y: 0)
                            cell.imageCollectionViewController.pageControl.currentPage = 0
                        }
                    }
                }
            }
        }
        
        guard scrollView.xPosition < refreshOffset else { return }
        refreshIfNeeded()
    }
    
    // MARK: - PayloadCollectionViewController implementation
    
    override func refresh() {

		guard !isReloading else { return }

        FirbaseAnalytics.logEvent(actionRightSwipe, parameters: ["refresh": true])
        
        scrollTo(indexPath: IndexPath(row: 0, section: 0))
        isReloading = true
        activityIndicatorView?.startAnimating()
        collectionView.isUserInteractionEnabled = false
        if let constraints = view.superview?.constraintsAffectingLayout(for: NSLayoutConstraint.Axis.horizontal) {
            constraints.last?.constant = -120
        }
        
        //remove the center spinner which was added on initial View load
        centerSpinnerView?.stopAnimating()
        isCollectionReload = true
        collection.loadData(true)
    }
    
    // MARK: - Private methods
    
    // deprecated - should remove entire method
    private func showEmojiTipAlertIfNeeded() {
        let noNeedShow = UserDefaults.bool(key: UserDefaultsKey.emojiTipAlreadyPresented.rawValue)
        if noNeedShow { return }
        if UserDefaults.getVersionSession() > 1 && collection.count > currentPage {
            let emojis = collection[currentPage].emoji
            if emojis != nil && emojis?.dictionary?.keys.count ?? 0 > 0 {
                let alert = ForceUpdateAlertController(title: L10n.SpotCollectionViewController.ForceUpdateAlert.title, subTitle: L10n.SpotCollectionViewController.ForceUpdateAlert.subTitle);
                alert.addButton(title: L10n.SpotCollectionViewController.ForceUpdateAlert.buttonTitle) {
                    UserDefaults.save(value: true, forKey: UserDefaultsKey.emojiTipAlreadyPresented.rawValue)
                    alert.dismiss()
                }
                alert.show(parent: self);
            }
        }
    }
    
    private func reset() {
        if !isReloading {
            isCollectionReload = false
        }
        isReloading = false
        activityIndicatorView?.stopAnimating()
        collectionView.isUserInteractionEnabled = true
        
        if let constraints = view.superview?.constraintsAffectingLayout(for: NSLayoutConstraint.Axis.horizontal) {
            constraints.last?.constant = 0
        }
        
        //remove the center spinner which was added on initial View load
        centerSpinnerView?.stopAnimating()
    }
    
    private func refreshIfNeeded() {
        guard refreshControl != nil, refreshControl?.isRefreshing == false, (activityIndicatorView as? NVActivityIndicatorView)?.isAnimating == false else { return }
        refresh()
    }
}

extension SpotCollectionViewController: SpotsProtocol {
    
    func scrollTo(indexPath: IndexPath?, animated: Bool = false) {
        guard
            let indexPath = indexPath,
            let collectionView = collectionView,
            collectionView.numberOfItems(inSection: indexPath.section) > indexPath.item else { return }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animated)
        collectionView.layoutSubviews()
    }
    
    func reloadData() {
        collectionView?.reloadData()
        
        // HACK: This fixes cell size issue after reloadData()
        collectionView?.performBatchUpdates({
            
        }, completion: { (result) in
            self.collectionView?.reloadData()
        })
    }
    
    func endRefreshing() {
        collectionView?.refreshControl?.endRefreshing()
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        collectionView?.insertItems(at: indexPaths)
    }
    
    func deleteItems(at indexPaths: [IndexPath]) {
        collectionView?.deleteItems(at: indexPaths)
    }
    
    func crashFix() {
        // CollectionView bug.
        // https://stackoverflow.com/a/46751421
        collectionView?.numberOfItems(inSection: 0)
    }
}
