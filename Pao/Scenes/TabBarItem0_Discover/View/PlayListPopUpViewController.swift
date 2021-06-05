//
//  PlayListPopUpViewController.swift
//  Pao
//
//  Created by Podkladov Anatoliy Olegovich on 19.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

class PlayListPopUpViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private var tapView: UIView!
    @IBOutlet private var messageView: SplashGradientView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var circleLabel: UILabel!
    @IBOutlet private var leftImageView: UIImageView!
    @IBOutlet private var centerImageView: UIImageView!
    @IBOutlet private var rightImageView: UIImageView!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var checkItOutButton: UIButton!
    
    // MARK: - Private properties
    
    var checkItOutButtonDidPressed: EmptyCompletion?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLabels()
        setupImages()
        setupButton()
        showView()
    }
    
    // MARK: - Actions
    
    @IBAction private func closePopUp(_ sender: UIButton) {
        checkItOutButtonDidPressed?()
        dismissView()
    }
    
    // MARK: - Private methods
    
    private func setupViews() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        tapView.addGestureRecognizer(tapGesture)
        
        messageView.style = .playListPopUp
        messageView.radius = 8.0
        messageView.makeCornerRound(cornerRadius: 8)
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.79)
    }
    
    private func setupLabels() {
        
        let height = UIScreen.main.bounds.height
        let isIphoneSE = height <= 568
        
        titleLabel.text = L10n.PlayListPopUpViewController.title
        let fontSize: CGFloat = isIphoneSE ? UIFont.sizes.medium : UIFont.sizes.popUpTitle
        titleLabel.font = UIFont.appBold.withSize(fontSize)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        circleLabel.text = L10n.PlayListPopUpViewController.circleLabel
        circleLabel.font = .appBook
        circleLabel.textAlignment = .center
        
        descriptionLabel.text = L10n.PlayListPopUpViewController.description
        descriptionLabel.font = UIFont.appBook.withSize(UIFont.sizes.medium)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
    }
    
    private func setupImages() {
        leftImageView.image = Asset.Assets.PlayListPopUp.playListPopUpLeftImage.image
        centerImageView.image = Asset.Assets.PlayListPopUp.playListPopUpCenterImage.image
        rightImageView.image = Asset.Assets.PlayListPopUp.playListPopUpRightImage.image
    }
    
    private func setupButton() {
        checkItOutButton.layer.cornerRadius = 17
        checkItOutButton.backgroundColor = .black
        checkItOutButton.setTitle(L10n.PlayListPopUpViewController.CheckItOutButton.title, for: .normal)
        checkItOutButton.titleLabel?.font = UIFont.appBook.withSize(UIFont.sizes.medium)
    }
    
    private func showView() {
        view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        view.alpha = 0.0
        
        UIView.animate(withDuration: 0.24) {
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1.0
        }
    }
    
    @objc
    private func dismissView() {
        UIView.animate(withDuration: 0.24, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            self.view.alpha = 0.0
        }) { _ in
            self.view.removeFromSuperview()
        }
    }
}
