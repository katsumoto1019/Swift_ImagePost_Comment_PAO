//
//  BoardMenuViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 22/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class BoardMenuViewController: UIViewController {
    
    var needOpenCoverPhotoCallback: (() -> Void)?
    var centerClosePoint: CGPoint?

    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(Asset.Assets.Icons.close.image, for: .normal)
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)
        button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        return button
    }()

    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.semanticContentAttribute = .forceRightToLeft
        button.titleLabel?.set(fontSize: UIFont.sizes.large)
        button.setTitle(L10n.DropDownView.Menu.CoverPhoto.title, for: .normal)
        button.setImage(Asset.Assets.Icons.addPhoto.image, for: .normal)
        button.backgroundColor = UIColor.clear
        button.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
        button.contentHorizontalAlignment = .right
        button.contentVerticalAlignment = .center
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        return button
    }()

    init(centerClosePoint: CGPoint?) {
        self.centerClosePoint = centerClosePoint

        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        applyStyle()

        view.addSubview(closeButton)
        view.addSubview(menuButton)

        closeButton.frame.size = CGSize(width: 30.0, height: 30.0)
        closeButton.center = centerClosePoint ?? CGPoint(x: view.frame.width - closeButton.frame.size.width/2 - 12.0,
                                                         y: view.center.y * 0.9)

        menuButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            menuButton.trailingAnchor.constraint(equalTo: closeButton.trailingAnchor),
            menuButton.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 30.0),
            menuButton.heightAnchor.constraint(equalToConstant: 30.0),
            menuButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9)
        ])
    }
    
    private func applyStyle() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.85)
    }

    @objc
    private func tapButton() {
        dismiss(animated: true) { [weak self] in
            self?.needOpenCoverPhotoCallback?()
        }
    }

    @objc
    private func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
}
