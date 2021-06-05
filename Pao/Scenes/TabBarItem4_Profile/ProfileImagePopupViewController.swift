//
//  ProfileImagePopupViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 11/12/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileImagePopupViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var imageUrl: URL?
    
    init(imageUrl: URL?) {
        super.init(nibName: nil, bundle: nil)
        
        self.imageUrl = imageUrl
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
        applyStyle()
    }
    
    func initialize() {
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(close)))
        self.view.isUserInteractionEnabled = true
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(profileImageTapped)))
        profileImageView.isUserInteractionEnabled = true
        
        profileImageView.image = nil
        profileImageView.kf.indicatorType = .activity
        if let imageUrl = imageUrl, let profileImageUrl = URL(string: "\(imageUrl.absoluteString)=s0") {
            KingfisherManager.shared.retrieveImage(with: profileImageUrl, options: [.downloadPriority(1.0), .transition(.fade(0.2)), .keepCurrentImageWhileLoading], progressBlock: nil, downloadTaskUpdated: nil) { (result) in
                   if let image = try? result.get().image {
                        self.profileImageView.image = image
                   }
            }
        } else {
            profileImageView.image = Asset.Assets.Icons.user.image
        }
    }
    
    func applyStyle() {
        self.view.isOpaque = false
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        
        closeButton.setTitle("", for: .normal)
        closeButton.setImage(Asset.Assets.Icons.close.image, for: .normal)
        closeButton.imageEdgeInsets = UIEdgeInsets.init(top: 20, left: 5, bottom: 10, right: 25)
        
        profileImageView.contentMode = .scaleAspectFill
    }
    
    @IBAction func closePressed(_ sender: UIButton) {
        close()
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func profileImageTapped() {}
}
