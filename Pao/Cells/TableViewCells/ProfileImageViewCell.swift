//
//  ProfileImageViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/23/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class ProfileImageViewCell: BaseTableViewCell {
    @IBOutlet weak var coverImageView: PickerImageView!
    @IBOutlet weak var profileImageView: ProfileImageView!
    
    weak var delegate: UIViewController? {
        didSet {
            coverImageView.delegate = delegate;
            profileImageView.delegate = delegate;
            profileImageView.useCircleCrop = true;
            
            coverImageView.aspectRatio = CGSize(width: 375, height: 262);
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        separatorInset.left = CGFloat.infinity;
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            let inset: CGFloat = 16
            var frame = newFrame
            frame.origin.x -= inset
            frame.size.width += 2 * inset
            super.frame = frame
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(coverImageUrl: URL?, profileImageUrl: URL?) {
        if  !coverImageView.isChanged || coverImageView.image == nil {
            if let coverImageUrl = coverImageUrl {
                coverImageView.kf.indicatorType = .activity;
                coverImageView.kf.setImage(with: coverImageUrl);
            } else {
                self.coverImageView.image = Asset.Assets.Backgrounds.defaultCoverPhoto.image
            }
        }
        
        if  !profileImageView.isChanged || profileImageView.image == nil {
            if let profileImageUrl = profileImageUrl {
                profileImageView.kf.indicatorType = .activity;
                profileImageView.kf.setImage(with: profileImageUrl);
            } else {
                profileImageView.image = Asset.Assets.Icons.user.image
            }
        }
    }
    
    @IBAction func editCoverImage(_ sender: Any) {
        FirbaseAnalytics.logEvent(.editCoverPhoto)
        FirbaseAnalytics.trackScreen(name: .editCoverPhoto)
        
        coverImageView.pickImage();
    }
    
    @IBAction func editProfileImage(_ sender: Any) {
        FirbaseAnalytics.logEvent(.editProfilePhoto)
        FirbaseAnalytics.trackScreen(name: .editProfilePhoto)
        
        profileImageView.pickImage();
    }
}
