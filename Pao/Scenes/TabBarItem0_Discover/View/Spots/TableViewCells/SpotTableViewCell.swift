//
//  SpotTableViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/4/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos
import Payload


class SpotTableViewCell: UITableViewCell, Consignee {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var attributeLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    weak var delegate: SpotCollectionViewCellDelegate?
    var spot: Spot!
    
    var isMySpot = false;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        applyStyle();
        
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showProfile)));
        userImageView.isUserInteractionEnabled = true;
        
        saveButton.isHidden = true;
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func applyStyle() {
        titleLabel.set(fontSize: UIFont.sizes.small);
        subTitleLabel.set(fontSize: UIFont.sizes.verySmall);
        attributeLabel.textColor = UIColor.lightText;
        userImageView.makeCornerRound();
        thumbnailImageView.contentMode = .scaleAspectFill;
        thumbnailImageView.clipsToBounds = true;
    }
    
    func set(_ spot: Spot) {
        self.spot = spot;
        
        if let media = spot.media?.values.sorted(by: {$0.index ?? 0 < $1.index ?? 0}).first {
            let url = media.type == 0 ? media.url : media.thumbnailUrl;
            thumbnailImageView.kf.setImage(with: url);
        }
        
        if !userImageView.isHidden, let url = spot.user?.profileImage?.url {
            userImageView.kf.setImage(with: url);
        }
        else {
            userImageView.image = Asset.Assets.Icons.user.image
        }
        
        //saveButton.isSelected = spot.isSavedByViewer == true;
        
        //        titleLabel.text = spot.location?.name;
        //        subTitleLabel.text = spot.location?.city;
        //        attributeLabel.text = spot.user?.name;
        
        titleLabel.text = spot.location?.name;
        subTitleLabel.text = spot.location?.cityFormatted;
        attributeLabel.text = spot.location?.typeFormatted;
    }
    
    func setFavorites() {
        saveButton.setImage(Asset.Assets.Icons.starselected.image, for: .selected);
        saveButton.setImage(Asset.Assets.Icons.star.image, for: .normal);
        
        saveButton.isSelected = spot.isFavorite == true;
        saveButton.isHidden = false;
        isMySpot = true;
        
        if !spot.isUserSpot {
            saveButton.isUserInteractionEnabled = false;
            saveButton.isHidden = !saveButton.isSelected;
        }
    }
    
    func set(spot: Spot, phAssets: [PHAsset]) {
        let imageSize = thumbnailImageView.frame.size;
        let requestOptions = PHImageRequestOptions();
        requestOptions.deliveryMode = .opportunistic;
        requestOptions.isNetworkAccessAllowed = true //allow access to iCloud photos
        
        PHImageManager.default().requestImage(for: phAssets[0], targetSize: imageSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
            guard let image = image else {
                return;
            }
            self.thumbnailImageView.image = image;
        })
        
        set(spot);
    }
}

extension SpotTableViewCell {
    @objc func showProfile() {
        if let delegate = delegate, let user = spot.user {
            delegate.showProfile(user: User(user: user))
        }
    }
    
    @IBAction func save(_ sender: UIButton) {
        guard !isMySpot else {star(sender, spotToStar: self.spot); return; }
        
        let action: SpotAction = sender.isSelected ? .unsave : .save;
        sender.isSelected = !sender.isSelected;
        
        let spotToSave = Spot();
        spotToSave.id = spot.id;
        
        App.transporter.post(spotToSave, to: action) { (success) in
            if success == true {
                NotificationCenter.spotSaved();
                self.spot?.isSavedByViewer = sender.isSelected;
            } else {
                sender.isSelected = !sender.isSelected;
            }
        }
    }
    
    private func star(_ sender: UIButton, spotToStar: Spot) {
        let action: SpotAction = sender.isSelected ? .unfavorite : .favorite;
        sender.isSelected = !sender.isSelected;
        spotToStar.isFavorite = sender.isSelected;
        
        FirbaseAnalytics.logEvent(.starSpot, parameters: ["value": action == .favorite ? 1 : 0])
        AmplitudeAnalytics.logEvent(.starSpot, group: .myProfile)
        
        let spotToFavorite = Spot();
        spotToFavorite.id = spotToStar.id;
        
        App.transporter.post(spotToFavorite, returnType: ResponseStatus.self, to: action) { (result) in
            guard result?.status != true else {
                return;
            }
            
            spotToStar.isFavorite = !spotToStar.isFavorite!;
            
            if spotToFavorite.id == self.spot.id {
                sender.isSelected = !sender.isSelected;
            }
            
            if result?.code == 504 {
                //Maximum limit reached
                self.parentViewController?.showMessagePrompt(message: L10n.SpotTableViewCell.MessagePrompt.message, title: L10n.SpotTableViewCell.MessagePrompt.title, customized: true, handler: { (alertAction) in
                    print("Testing")
                });
            }
        }
    }
}


class ResponseStatus: Codable {
    var status: Bool?
    var code: Int?//504
    var message: String?
}
