//
//  BoardCollectionViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 4/25/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

class BoardCollectionViewCell: UICollectionViewCell, Consignee {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    
    var activityIndicator = UIActivityIndicatorView(style: .white);
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.set(fontSize: UIFont.sizes.small);
        thumbnailImageView.contentMode = .scaleAspectFill;
        gradientView.gradientColors = [UIColor.black.withAlphaComponent(0.8), UIColor.black.withAlphaComponent(0)];
    }
    
    func set(_ board: Board) {
        if board.isLocalBoard == true {
            self.localBoard();
            return;
        }
        
        activityIndicator.removeFromSuperview();
        
        let spotMediaItem = board.thumbnail;
        
        if let placeholderColor = spotMediaItem?.placeholderColor {
            thumbnailImageView.backgroundColor = UIColor(hex: placeholderColor);
        }
        
        thumbnailImageView.kf.indicatorType = .none;
        
        let servingUrl = spotMediaItem?.url?.imageServingUrl(cropSize: Int(frame.height * UIScreen.main.scale));
        thumbnailImageView.kf.setImage(with: servingUrl, options: [.transition(.fade(0.1))]);
        titleLabel.text = board.title?.uppercased();
    }
    
    private func localBoard() {
        titleLabel.text = nil;
        thumbnailImageView.image = nil;
        thumbnailImageView.backgroundColor = ColorName.placeholder.color

        self.addSubview(activityIndicator);
        activityIndicator.center = center;
        activityIndicator.startAnimating();
    }
}
