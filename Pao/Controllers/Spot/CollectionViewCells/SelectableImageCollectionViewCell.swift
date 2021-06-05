//
//  SelectableImageCollectionViewCell
//  Pao
//
//  Created by Developer on 2/22/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos

class SelectableImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    
    weak var delegate: ImagePickerViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        NotificationCenter.default.addObserver(
			self,
			selector: #selector(selectionChangedNotification),
			name: Notification.Name(ImagePickerViewController.ImagePickerSelectionChangedNotification), object: nil)
        
        setupCounter();
        prepareForReuse();
        gradientView.gradientColors = [UIColor.black.withAlphaComponent(0), UIColor.black.withAlphaComponent(0.8)];
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = isSelected ? 2 : 0;
            self.layer.borderColor = isSelected ? UIColor.white.cgColor : UIColor.clear.cgColor;
            self.counterLabel.isHidden = !isSelected;
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse();
        
        self.layer.borderWidth = 0;
        self.counterLabel.isHidden = true;
        self.gradientView.isHidden = true;
        self.thumbnailImageView.image = nil;
    }
    
    private func setupCounter() {
        counterLabel.textColor = UIColor.black;
    }
    
    func set(phAsset: PHAsset) {
        let imageSize = thumbnailImageView.frame.size;
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .opportunistic;
        requestOptions.isNetworkAccessAllowed = true //allow access to iCloud photos
        
        PHImageManager.default().requestImage(for: phAsset, targetSize: imageSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
            guard let image = image else {
                return;
            }
            self.thumbnailImageView.image = image;
        });
        
        let videoDuration = phAsset.duration;
        if (!videoDuration.isNaN && !videoDuration.isInfinite && !videoDuration.isZero) {
            showDuration(seconds: videoDuration);
        }

        selectionChangedNotification()
    }

    @objc func selectionChangedNotification() {
        if let index = delegate?.selectionIndex(ofCell: self) {
            self.counterLabel.text = String(index + 1);
        }
    }
    
    private func showDuration(seconds: Double) {
        let secs = Int(seconds);
        let hours = secs / 3600;
        let minutes = (secs % 3600) / 60;
        let seconds = (secs % 3600) % 60;
        
        if (hours != 0) {
            timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds);
        } else {
            timeLabel.text = String(format: "%02d:%02d", minutes, seconds);
        }
        
        gradientView.isHidden = false;
    }
}
