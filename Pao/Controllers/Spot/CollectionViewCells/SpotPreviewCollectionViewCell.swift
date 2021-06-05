//
//  SpotPreviewCollectionViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/1/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import Photos

class SpotPreviewCollectionViewCell: BaseCollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var descriptionContainerView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var profileImageView: ProfileImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var saveCountLabel: UILabel!
    
    @IBOutlet weak var descriptionGradientView: GradientView!
    
    @IBOutlet var descriptionViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: SpotCollectionViewCellDelegate?
    var spot: Spot!
    private let imageCollectionViewController = ImageCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout());
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.addSubview(imageCollectionViewController.view);
        imageCollectionViewController.view.frame = containerView.bounds;
        
        var tapGesture = UITapGestureRecognizer(target: self, action: #selector(tryShowDescription));
        descriptionView.gestureRecognizers = [tapGesture];
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tryShowDescription));
        descriptionContainerView.gestureRecognizers = [tapGesture];
        descriptionContainerView.isUserInteractionEnabled = false;
        
        descriptionGradientView.gradientColors = [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.8)];
        
        descriptionLabel.set(fontSize: UIFont.sizes.small);
        descriptionLabel.lineBreakMode = .byTruncatingTail;
        descriptionLabel.isHidden = true;
        
        timestampLabel.set(fontSize: UIFont.sizes.verySmall);
        nameLabel.set(fontSize: UIFont.sizes.normal);
        saveCountLabel.set(fontSize: UIFont.sizes.small);
       
    }
    
    override func prepareForReuse() {
        imageCollectionViewController.reset();
        descriptionContainerView.isUserInteractionEnabled = false;
        self.collapse();
    }
    
    @objc func tryShowDescription() {
        if descriptionViewHeightConstraint.isActive {

            FirbaseAnalytics.logEvent(.tapTip)
            
            // Expand
            UIView.animate(withDuration: 0.2, animations: {
                self.expand();
            }, completion: { (success) in
                self.descriptionContainerView.isUserInteractionEnabled = true;
            })
        }
        else {
            // Collapse
            UIView.animate(withDuration: 0.2, animations: {
                self.collapse();
            }, completion: { (success) in
                self.descriptionContainerView.isUserInteractionEnabled = false;
            })
        }
    }
    
    func collapse() {
        descriptionViewHeightConstraint.isActive = true;
        descriptionContainerView.backgroundColor = UIColor.clear;
        timestampLabel.text = spot.location?.cityFormatted;
        descriptionLabel.isHidden = true;
        
        self.layoutIfNeeded();
    }
    
    func expand() {
        descriptionViewHeightConstraint.isActive = false;//.constant = 276;
        descriptionContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.7);
        timestampLabel.text =  DataContext.cache.user?.username;
        descriptionLabel.isHidden = false;
        
        self.layoutIfNeeded();
    }
    
    func set(spot: Spot) {
        self.spot = spot;
        if let images = spot.media?.values.sorted(by: {$0.index ?? 0 < $1.index ?? 0}).map({$0}) {
            imageCollectionViewController.set(spotImages: images);
        }
        
        nameLabel.text = DataContext.cache.user?.name;
        timestampLabel.text = spot.location?.cityFormatted;
        descriptionLabel.text = spot.description;
       
        if let profileImageUrl =  DataContext.cache.user?.profileImage?.url {
            profileImageView.kf.setImage(with: profileImageUrl);
        } else {
            profileImageView.image = Asset.Assets.Icons.user.image
        }
    }
    
    func set(spot: Spot, phAssets: [PHAsset]) {
        set(spot: spot);
        imageCollectionViewController.set(phAssets: phAssets);
    }
    
}
