//
//  SpotCollectionViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/1/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Firebase
import Photos
import Payload

import RocketData

class SpotCollectionViewCell: BaseCollectionViewCell, Consignee {
    
    // MARK: - Outlets
    
    @IBOutlet var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var descriptionContainerView: UIView!
    @IBOutlet private var descriptionView: UIView!
    @IBOutlet private var profileImageView: ProfileImageView!
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var timestampLabel: UILabel!
    @IBOutlet private var descriptionTitleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    
    @IBOutlet private var actionContainerStackView: UIStackView! {
        didSet {
            actionContainerStackView.alignment = .center
            actionContainerStackView.distribution = .fill
            actionContainerStackView.axis = .horizontal
            actionContainerStackView.spacing = 3
        }
    }
    @IBOutlet var saveButton: UIButton! {
        didSet {
            saveButton.addTarget(self, action: #selector(saveBookmark(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet private var savesCountButton: UIButton! {
        didSet {
            savesCountButton.addTarget(self, action: #selector(showSavers(_:)), for: .touchUpInside)
        }
    }
    @IBOutlet var goButton: UIButton!
    @IBOutlet private var editButton: UIButton! {
        didSet {
            editButton.setTitle("•••", for: .normal)
            editButton.titleLabel?.font = UIFont.appHeavy.withSize(UIFont.sizes.veryLarge)
            editButton.sizeToFit()
        }
    }
    @IBOutlet private var commentButton: UIButton! {
        didSet {
            commentButton.setTitleColor(ColorName.accent.color, for: .normal)
            commentButton.titleLabel?.set(fontSize: UIFont.sizes.small)
            commentButton.addTarget(self, action: #selector(showComments), for: .touchUpInside)
        }
    }

    @IBOutlet private var descriptionGradientView: GradientView!
    @IBOutlet weak var uploadingOverlay: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    // MARK: - Constraints
    
    @IBOutlet var actionContainerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var descriptionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var bottomPaddingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var uploadSpotImageView: UIImageView! {
        didSet {
            uploadSpotImageView.layer.borderWidth = 0.8
            uploadSpotImageView.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @IBOutlet weak var uploadProgressLabel: UILabel!
    
    @IBOutlet weak var failUploadView: UIView!
    @IBOutlet weak var uploadFailLabel: UILabel!
    
    // MARK: - Internal properties
    
    var isRandomTextLoaded = false
    weak var delegate: SpotCollectionViewCellDelegate?
    lazy var imageCollectionViewController = ImageCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
    var isTheWorldView = false {
        didSet {
            guard isTheWorldView != oldValue else { return }
            titleLabel.isHidden = true
        }
    }
    
    var comesFrom: ComesFrom?
    
    /// Playlist properties
    var playListProperties: [String: Any] = [:]
    
    var pulsatingLayer: CAShapeLayer!
    var shapeLayer: CAShapeLayer!
    let percentageLabel: UILabel = {
            let label = UILabel()
            label.text = L10n.SpotCollectionViewCell.labelUploading
            label.textAlignment = .center
            label.set(fontSize: UIFont.sizes.veryLarge)
            return label
        }()
    
    // MARK: - Private properties
    
    private var spot: Spot!
    private var cropDataList = [PHAsset: CropData]()
    private lazy var cyrcleMenu = CyrcleMenuView()
    private class LongEmojiTapGesture: UILongPressGestureRecognizer {
        var emoji: Emoji?
    }

    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupContainerView()
        setupLabels()
        setupButtons()
        setupViews()

        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress(_:)), name: .newSpotUplodingProgress, object: nil)
        uploadFailLabel.font = UIFont.appMedium.withSize(UIFont.sizes.normal)
        failUploadView.backgroundColor = ColorName.backgroundHighlight.color
    }
    
    // MARK: - Actions
    
    @IBAction private func showGo(_ sender: Any) {
        FirbaseAnalytics.logEvent(.clickGo)
        let (category, subCategory) = spot.getCategorySubCategoryNameList()
        let postId = spot.id ?? ""
        let properties = ["post ID": postId, "category": category, "subcategory": subCategory] as [String : Any]
        AmplitudeAnalytics.logEvent(.go, group: .spot, properties: properties)
        
        delegate?.showGo(spot: spot)
    }

    @objc
    func saveBookmark(_ sender: UIButton) {
        let action: SpotAction = sender.isSelected ? .unsave : .save
        FirbaseAnalytics.logEvent(action == .save ? .clickSaveIcon : .clickUnSaveIcon)
        
        let (category, subCategory) = spot.getCategorySubCategoryNameList()
        let type = action == .save ? "save" : "unsave"
        let postId = spot.id ?? ""
        
        // spot - save
        let from: String = comesFrom?.rawValue ?? ""
        let properties = ["post ID": postId, "type": type, "from": from, "category": category, "subcategory": subCategory] as [String : Any]
        AmplitudeAnalytics.logEvent(.save, group: .spot, properties: properties)
        
        // view_spots - save from play list
        if comesFrom == .playList {
            playListProperties["type"] = type
            playListProperties["post ID"] = postId
            AmplitudeAnalytics.logEvent(.saveFromPlayList, group: .viewSpots, properties: playListProperties)
        }
        
        toggleSaved(sender: sender)
        
        let spotToSave = Spot()
        spotToSave.id = spot.id
        
        App.transporter.post(spotToSave, to: action) { (success) in
            if success == true {
                NotificationCenter.spotSaved()
            } else {
                self.toggleSaved(sender: sender)
            }
        }
    }
    
    private func toggleSaved(sender: UIButton) {
        guard var savers = self.spot.savedBy else { return }
        
        sender.isSelected = !sender.isSelected
        spot.isSavedByViewer = sender.isSelected
        spot.saves = (self.spot.saves ?? 0) + (sender.isSelected ?  1 : -1)
        if sender.isSelected, !savers.contains(where: { $0.id == DataContext.cache.user.id }) {
            savers.append(DataContext.cache.user)
        } else {
            savers.removeAll(where: { $0.id == DataContext.cache.user.id })
        }
        self.spot.savedBy = savers
        savesCountButton.setTitle(String(self.spot.saves ?? 0), for: .normal)
        updateData()
    }
    
    @IBAction private func edit(_ sender: Any) {
        delegate?.edit(spot: spot)
    }
    
    @objc
    private func showSavers(_ sender: Any) {
		self.showReactionList(emoji: nil)
    }
    
    @objc
    private func showComments(_ sender: Any) {
        FirbaseAnalytics.logEvent(.clickCommentIcon)
        
        delegate?.showComments(spot: spot)
    }
    
    @IBAction func retryUpload(_ sender: Any) {
        self.delegate?.retryUpload(spot: self.spot)
    }
    
    @IBAction func deleteUploadSpot(_ sender: Any) {
        self.delegate?.deleteUploadingSpot(spot: self.spot)
    }
    
    // MARK: - Internal methods
    
    func expand() {
        UIView.animate(withDuration: 0.2, animations: {
            self.descriptionViewHeightConstraint.isActive = false//.constant = 276
            self.descriptionContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            self.timestampLabel.text = self.spot?.user?.username
            self.descriptionLabel.isHidden = false
            self.descriptionTitleLabel.isHidden = false
            self.layoutIfNeeded()
        })
    }
    
    func set(_ spot: Spot) {
        if spot.id != self.spot?.id, let images = spot.media?.values.sorted(by: {$0.index ?? 0 < $1.index ?? 0}).map({$0}) {
            imageCollectionViewController.set(spotImages: images)
        }

        DataModelManager.sharedInstance.modelFromCache(spot.modelIdentifier, context: nil) { (model: Spot?, error) in
            if let spotModel = model {
                self.setEmojiStackView(for: spotModel)
                self.spot = spotModel
            }
        }

        nameLabel.text = spot.user?.name
        descriptionTitleLabel.text = spot.location?.name
        descriptionLabel.text = spot.description
        
        titleLabel.text = spot.timestamp?.timeElapsedString()
        
        timestampLabel.text = spot.location?.cityFormatted

        setEmojiStackView(for: spot)

        saveButton.isSelected = spot.isSavedByViewer == true
        savesCountButton.setTitle((spot.saves ?? 0).abbreviated, for: .normal)
        savesCountButton.sizeToFit()
        let title: String
        if let count = spot.commentsCount, count > 0 {
			if count == 1 {
				title = L10n.SpotCollectionViewCell.MessageButtonOne.title
			} else {
				title = L10n.SpotCollectionViewCell.MessageButton.title(String(count))
			}
        } else {
			title = L10n.SpotCollectionViewCell.MessageButtonEmpty.title
        }
        commentButton.setTitle(title, for: .normal)

        if let profileImageUrl = spot.user?.profileImage?.url {
            profileImageView.kf.setImage(with: profileImageUrl)
        } else {
            profileImageView.image = Asset.Assets.Icons.user.image
        }
        
        saveButton.isEnabled = !spot.isUserSpot
        if spot != self.spot {
            for layer in self.containerView.layer.sublayers! {
               if layer.isKind(of: CAShapeLayer.self) {
                  layer.removeFromSuperlayer()
               }
            }
        }
        
        if spot.uploadStatus == SpotUploadStatus.uploading.rawValue {
            uploadingOverlay.isHidden = false
            bottomView.isHidden = true
            descriptionGradientView.isHidden = true
            imageCollectionViewController.pageControl.superview?.isHidden = true
            self.isUserInteractionEnabled = false
            //goButton.isHidden = true
            titleLabel.isHidden = true
            editButton.isHidden = true
            failUploadView.isHidden = true
            if spot != self.spot {
                DispatchQueue.main.async {
                    self.showLoader()
                }
            }
            if !isRandomTextLoaded {
                isRandomTextLoaded = true
                App.transporter.get(UploadMessgae.self) { (uploadMessage) in
                    if (uploadMessage != nil) {
                        self.uploadProgressLabel.text = uploadMessage?.text
                        self.uploadProgressLabel.isHidden = false
                    }
                }
            } else {
                self.uploadProgressLabel.isHidden = false
            }
            
        } else if spot.uploadStatus == SpotUploadStatus.failed.rawValue {
            uploadingOverlay.isHidden = false
            bottomView.isHidden = true
            descriptionGradientView.isHidden = true
            imageCollectionViewController.pageControl.superview?.isHidden = true
            self.isUserInteractionEnabled = true
            uploadProgressLabel.isHidden = true
            //goButton.isHidden = true
            titleLabel.isHidden = true
            editButton.isHidden = true
            failUploadView.isHidden = false
            
        } else if spot.uploadStatus == SpotUploadStatus.preview.rawValue {
            uploadingOverlay.isHidden = true
            bottomView.isHidden = true
            descriptionGradientView.isHidden = false
            imageCollectionViewController.pageControl.superview?.isHidden = false
            self.isUserInteractionEnabled = true
            uploadProgressLabel.isHidden = true
            goButton.isHidden = true
            titleLabel.isHidden = true
            editButton.isHidden = true
            failUploadView.isHidden = true
        } else {
            uploadingOverlay.isHidden = true
            bottomView.isHidden = false
            descriptionGradientView.isHidden = false
            imageCollectionViewController.pageControl.superview?.isHidden = false
            self.isUserInteractionEnabled = true
            uploadProgressLabel.isHidden = true
            if spot != self.spot {
                goButton.isHidden = spot.location == nil
            }
            titleLabel.isHidden = isTheWorldView
            editButton.isHidden = false
            failUploadView.isHidden = true
        }
        self.spot = spot
    }

    private func setEmojiStackView(for spot: Spot) {

        actionContainerStackView
            .arrangedSubviews
            .forEach({ $0.removeFromSuperview() })

        guard let emoji = spot.emoji else {
            addEmojiMenu()
            return
        }

        emoji.dictionary?
            .sorted(by: {
                return $0.key < $1.key

            })
            .forEach {
                guard let valueCount = $0.value.reactedBy?.count, valueCount > 0  else { return }
                let button = EmojiButton(emoji: $0.key)
                let selected = $0.value.reactedBy?.contains(where: {$0.id == DataContext.cache.user.id}) ?? false
                button.set(count: valueCount)
                button.isSelected = selected
                button.setContentHuggingPriority(.required, for: .horizontal)
                button.onClick = { select, emoji in
                    self.updateReaction(selected: select, emoji: emoji)
                }
                let longPress = LongEmojiTapGesture(target: self, action: #selector(longPressAction(sender:)))
                longPress.emoji = $0.key
                button.addGestureRecognizer(longPress)
                actionContainerStackView.addArrangedSubview(button)
        }
        actionContainerStackView.subviews.count < 5 ? addEmojiMenu() : addSpaceView()
    }

    @objc private func longPressAction(sender: LongEmojiTapGesture) {
        if sender.state == .began {
            guard let emoji = sender.emoji else { return }
            let (category, subCategory) = spot.getCategorySubCategoryNameList()
            let postId = spot.id ?? ""
            let properties = ["post ID": postId, "category": category, "subcategory": subCategory] as [String : Any]
            AmplitudeAnalytics.logEvent(.pressEmoji, group: .spot, properties: properties)
            FirbaseAnalytics.logEvent(.pressEmoji)
			self.showReactionList(emoji: emoji)
        }
    }

	private func showReactionList(emoji: Emoji?) {
		let emojies = actionContainerStackView.subviews.compactMap{ ($0 as? EmojiButton)?.emoji }
        let list = spot.emoji?.dictionary?.filter({
            return emojies.contains($0.key)
		})
        delegate?.showEmojies(emojies: list ?? [:], selectedEmojies: emoji, savedBy: spot.savedBy ?? [])
	}

    private func addEmojiMenu() {
        let emptyButton = EmojiButton()
        
        if let emoji = Emoji(rawValue: 0) {
            let longPress = LongEmojiTapGesture(target: self, action: #selector(longPressAction(sender:)))
            longPress.emoji = emoji
            emptyButton.addGestureRecognizer(longPress)
        }
        
        emptyButton.onShowMenu = { [weak self] in
			let count: Int = UserDefaults.standard.integer(forKey: UserDefaultsKey.addEmojiCount.rawValue)
			if count == 10 {
				// show popup #2
                let alert = EmojiMeaningRevisitInstructionAlertController(title: "", subTitle: L10n.SpotCollectionViewCell.EmojiMeaningRevisitInstructionAlert.subTitle)
                alert.addButton(title: "\(L10n.Common.gotIt)!") {
					alert.dismiss()
                        self?.showEmojiMenu(emptyButton: emptyButton, showText: false)
					}
                var rootViewController = UIApplication.shared.keyWindow!.rootViewController!
                if let navigationController = rootViewController as? UINavigationController {
                    rootViewController = navigationController.viewControllers.first!
                }
                if let tabBarController = rootViewController as? UITabBarController {
                    rootViewController = tabBarController.selectedViewController!
                    if let nav1 = rootViewController as? UINavigationController {
                        rootViewController = nav1.viewControllers.first!
                        if let nav2 = rootViewController.presentedViewController as? UINavigationController {
                            rootViewController = nav2.viewControllers.first!
                        }
                    }
                }
				alert.show(parent: rootViewController)
			} else {
				self?.showEmojiMenu(emptyButton: emptyButton, showText: count < 11)
			}
			if count < 11 {
				UserDefaults.save(value: count + 1, forKey: UserDefaultsKey.addEmojiCount.rawValue)
			}
        }
        actionContainerStackView.addArrangedSubview(emptyButton)

        addSpaceView()
    }

    private func showMenu(centerPoint: CGPoint, withText: Bool) {
        self.cyrcleMenu.showWith(
            emojies: Emoji.allCases,
            center: centerPoint,
            _withText: withText)
    }

	 private func showEmojiMenu(emptyButton: EmojiButton, showText: Bool) {
		let mainView = UIApplication.shared.keyWindow
		cyrcleMenu.frame = UIScreen.main.bounds
		mainView?.addSubview(cyrcleMenu)
		let centerPoint = actionContainerStackView?.convert(emptyButton.frame.center, to: nil) ?? .zero
		cyrcleMenu.chooseEmoji = { [weak self] emoji in
            let emojies = self?.actionContainerStackView.subviews.compactMap { $0 as? EmojiButton }
            let selected = emojies?.contains(where: { $0.isSelected == true && $0.emoji == emoji }) ?? false
			self?.updateReaction(selected: !selected, emoji: emoji)
		}
		showMenu(centerPoint: centerPoint, withText: showText)
	}

    private func addSpaceView() {
        let view = UIView()
        view.setContentHuggingPriority(.sceneSizeStayPut, for: .horizontal)
        actionContainerStackView.addArrangedSubview(view)
    }

    // MARK: emoji
    private func updateReaction(selected: Bool, emoji: Emoji) {
        guard let id = self.spot.id  else { return }
        if selected {
            AmplitudeAnalytics.addUserValue(property: .emojis, value: 1)
        }
        let action: SpotAction = selected ? .reactEmoji : .unreactEmoji
        let reactModel = EmojiReactModel(spotId: id, emojiId: emoji.id)

        if spot.emoji?.dictionary == nil {
            spot.emoji = EmojiDictionary(id: id)
        } else {
            spot.emoji?.id = id
        }
        if spot.emoji?.dictionary?[emoji] == nil {
            spot.emoji?.dictionary?[emoji] = EmojiItem()
        }
        spot.emoji?.dictionary?[emoji]?.setReaction(id: DataContext.cache.user.id ?? "", selected: selected)
        updateData()
        setEmojiStackView(for: spot)

        let (category, subCategory) = spot.getCategorySubCategoryNameList()
        var emojiType = ""
        var eventName: EventName
        var actionName = action == .reactEmoji ? "select" : "deselect"
        var faAaction: EventAction
        switch emoji {
        case .heart_eyes:
            emojiType = "heart"
            eventName = .heartEmoji
            faAaction = action == .reactEmoji ? .heartEmoji : .deselectHeartEmoji
        case .clap:
            emojiType = "clap"
            eventName = .clapEmoji
            faAaction = action == .reactEmoji ? .clapEmoji : .deselectClapEmoji
        case .drooling_face:
            emojiType = "drool"
            eventName = .droolEmoji
            faAaction = action == .reactEmoji ? .droolEmoji : .deselectDroolEmoji
        case .round_pushpin:
            eventName = .verifySpot
            actionName = action == .reactEmoji ? "verify" : "unverify"
            faAaction = action == .reactEmoji ? .verifySpot : .unverifySpot
            emojiType = actionName
        case .gem:
            emojiType = "gem"
            eventName = .gemEmoji
            faAaction = action == .reactEmoji ? .gemEmoji : .deselectGemEmoji
        }
        // existing event
        AmplitudeAnalytics.logEvent(eventName, group: .spot, properties: ["type": actionName])
        
        switch comesFrom {
        case .yourPeopleFeed:
            let spotLocationName = spot.location?.name ?? ""
            let username = DataContext.cache.user.username ?? ""
            let postId = spot.id ?? ""
            let properties = ["spot location name": spotLocationName, "username": username, "post ID": postId, "emojitype": emojiType, "type": actionName, "category": category, "subcategory": subCategory] as [String : Any]
            AmplitudeAnalytics.logEvent(.emojiFromSearch, group: .spot, properties: properties)
        case .hiddenGems:
            let spotLocationName = spot.location?.name ?? ""
            let username = DataContext.cache.user.username ?? ""
            let postId = spot.id ?? ""
            let dateLaunched = spot.timestamp?.formateToISO8601String() ?? ""
            let properties = ["spot location name": spotLocationName, "username": username, "post ID": postId, "date launched": dateLaunched, "emojitype": emojiType, "type": actionName, "category": category, "subcategory": subCategory] as [String : Any]
            AmplitudeAnalytics.logEvent(.emojiFromHiddenGems, group: .spot, properties: properties)
        case .playList:
            playListProperties["emojitype"] = emojiType
            playListProperties["type"] = actionName
            playListProperties["spot location name"] = spot.location?.name
            playListProperties["post ID"] = spot.id
            playListProperties["category"] = category
            playListProperties["subcategory"] = subCategory
            AmplitudeAnalytics.logEvent(.emojiFromPlayList, group: .spot, properties: playListProperties)
        default:
            break
        }
        let spotLocationName = spot.location?.name ?? ""
        let username = DataContext.cache.user.username ?? ""
        let postId = spot.id ?? ""
        let from: String = comesFrom?.rawValue ?? ""
        let properties = ["spot location name": spotLocationName, "username": username, "post ID": postId, "from": from, "emojitype": emojiType, "type": actionName, "category": category, "subcategory": subCategory] as [String : Any]
        AmplitudeAnalytics.logEvent(.emoji, group: .spot, properties: properties)
        FirbaseAnalytics.logEvent(faAaction)
        
        App.transporter.post(
            reactModel,
            returnType: UpdatedStatus.self,
            to: action) { result in
                if result?.modifiedCount == 1 {
                    self.updateData()
                } else {
                    if self.spot.emoji == nil {
                        self.spot.emoji?.dictionary = [emoji: EmojiItem()]
                    }
                    self.spot.emoji?.dictionary?[emoji]?.setReaction(id: DataContext.cache.user.id ?? "", selected: !selected)
                    self.setEmojiStackView(for: self.spot)
                }
        }
    }
    
    func set(spot: Spot, phAssets: [PHAsset]) {
        set(spot)
        imageCollectionViewController.set(phAssets: phAssets)
    }
    
    func set(spot: Spot, phAssets: [PHAsset], cropDataList: [PHAsset:CropData]) {
        set(spot)
        self.cropDataList = cropDataList
        imageCollectionViewController.set(phAssets: phAssets,cropDataList: cropDataList)
    }
    
    func showLoader() {
        setupCircleLayers()
        animatePulsatingLayer()
    }
    
    @objc func updateProgress(_ notification: Notification) {
        DispatchQueue.main.async {
            if self.shapeLayer != nil {
                let progress: Double = notification.userInfo!["progress"] as! Double
                self.shapeLayer.strokeEnd = CGFloat(progress)
                self.uploadProgressLabel.isHidden = false
            }
        }
    }
    
    // MARK: - Private methods
    
    private func setupViews() {
        setupContainerView()
        setupGradienView()
        setupImageView()
    }
    
    private func setupContainerView() {
        containerView.addSubview(imageCollectionViewController.view)
        imageCollectionViewController.view.frame = containerView.bounds
        
        descriptionContainerView.isUserInteractionEnabled = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleDescription(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    private func setupGradienView() {
        descriptionGradientView.gradientColors = [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.8)]
    }
    
    private func setupImageView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showProfile))
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupLabels() {
        titleLabel.textColor = ColorName.textGray.color
        titleLabel.set(fontSize: UIFont.sizes.tiny)
        
        descriptionLabel.set(fontSize: UIFont.sizes.small)
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.isHidden = true
        
        descriptionTitleLabel.set(fontSize: UIFont.sizes.small)
        descriptionTitleLabel.lineBreakMode = .byTruncatingTail
        descriptionTitleLabel.textColor = ColorName.accent.color
        descriptionTitleLabel.isHidden = true
        
        timestampLabel.set(fontSize: UIFont.sizes.verySmall)
        nameLabel.set(fontSize: UIFont.sizes.normal)
        
        uploadProgressLabel.set(fontSize: UIFont.sizes.normal);
        uploadProgressLabel.layer.masksToBounds = true
        uploadProgressLabel.layer.cornerRadius = self.uploadProgressLabel.bounds.size.height / 2
        uploadProgressLabel.textColor = ColorName.accent.color
        
        uploadSpotImageView.layer.cornerRadius = uploadSpotImageView.frame.size.height / 2
        uploadSpotImageView.contentMode = .center
    }
    
    private func setupButtons() {
        goButton.setTitle(L10n.SpotCollectionViewCell.goButton, for: .normal)
        goButton.titleLabel?.font = UIFont.appMedium.withSize(UIFont.sizes.small + 1)
        
        let buttonFont = UIFont.appLight.withSize(UIFont.sizes.normal + 1)
        savesCountButton.titleLabel?.font = buttonFont

    }
    
    private func setupCircleLayers() {
        pulsatingLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: ColorName.pulsatingLayer.color)
        self.containerView.layer.addSublayer(pulsatingLayer)
        
        let trackLayer = createCircleShapeLayer(strokeColor: .black, fillColor: .white)
        self.containerView.layer.addSublayer(trackLayer)
        
        shapeLayer = createCircleShapeLayer(strokeColor: ColorName.accent.color, fillColor: .clear)
        
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        self.containerView.layer.addSublayer(shapeLayer)
        self.bringSubviewToFront(uploadSpotImageView)
    }

    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.toValue = 1.25
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity
        
        pulsatingLayer.add(animation, forKey: "pulsing")
    }

    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 35, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 7
        layer.fillColor = fillColor.cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        layer.position = self.uploadSpotImageView.center
        return layer
    }

    private func setupPercentageLabel() {
        containerView.addSubview(percentageLabel)
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = containerView.center
    }
    
    @objc
    private func toggleDescription(_ tapRecognizer: UITapGestureRecognizer) {
        let touchPoint = tapRecognizer.location(in: self)
        let containerViewFrame = self.convert(self.containerView.frame, from: self.containerView)
        if !containerViewFrame.contains(touchPoint) {
            return
        }
        isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(400)) {
            self.isUserInteractionEnabled = true
        }
        FirbaseAnalytics.logEvent(.tapTip)
        
        let isExpand = descriptionViewHeightConstraint.isActive
        if isExpand {
            let (category, subCategory) = spot.getCategorySubCategoryNameList()
            let postId = spot.id ?? ""
            let properties = ["post ID": postId, "category": category, "subcategory": subCategory] as [String : Any]
            AmplitudeAnalytics.logEvent(.tip, group: .spot, properties: properties)
            AmplitudeAnalytics.setUserProperty(property: .tappedTip, value: NSNumber(booleanLiteral: true))
        }
        self.goButton.isHidden = (isExpand || self.spot.location == nil)
        isExpand ? self.expand() : self.collapse()
    }
    
    func collapse(_ animate: Bool = true) {
        self.descriptionViewHeightConstraint.isActive = true
        if animate {
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            } completion: { (finished) in
                self.descriptionContainerView.backgroundColor = UIColor.clear
                self.timestampLabel.text = self.spot.location?.cityFormatted
                self.descriptionLabel.isHidden = true
                self.descriptionTitleLabel.isHidden = true
            }
        } else {
            self.descriptionContainerView.backgroundColor = UIColor.clear
            self.timestampLabel.text = self.spot.location?.cityFormatted
            self.descriptionLabel.isHidden = true
            self.descriptionTitleLabel.isHidden = true
            self.layoutIfNeeded()
        }
    }
    
    @objc
    private func showProfile() {
        FirbaseAnalytics.logEvent(.clickProfileIcon)
        if let user = spot?.user, let delegate = delegate {
            delegate.showProfile(user: User(user: user))
        }
    }
    
    private func updateData() {
        delegate?.spotDataDidUpdate(updatedSpot: spot)
        DataModelManager.sharedInstance.updateModel(spot)
    }
}
