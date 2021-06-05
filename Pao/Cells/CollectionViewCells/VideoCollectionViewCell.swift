//
//  VideoCollectionViewCell.swift
//  Pao
//
//  Created by Parveen Khatkar on 18/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import AVFoundation
import Kingfisher

class VideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoOverlayView: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let videoNode = ASVideoNode();
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconImageView.addShadow(offset: CGSize(width: 0, height: 0), color: UIColor.black, radius: 1, opacity: 1);
        
        backgroundColor = UIColor.black;
        
        videoOverlayView.backgroundColor = .clear;
        videoOverlayView.isUserInteractionEnabled = false;
        iconImageView.superview?.isUserInteractionEnabled = false
        
        progressView.progressViewStyle = .bar;
        activityIndicator.hidesWhenStopped = true;
        
        videoNode.gravity = AVLayerVideoGravity.resizeAspectFill.rawValue;
        videoNode.muted = false;
        videoNode.delegate = self;
        videoView.addSubnode(videoNode);
        
        NotificationCenter.default.addObserver(self, selector: #selector(pausePlayer(notification:)), name: .carouselSwipe, object: nil);
        
        prepareForReuse();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        layoutIfNeeded();
        
        videoNode.frame = videoView.bounds;
    }
    
    override func prepareForReuse() {
        super.prepareForReuse();
        
        iconImageView.superview?.isHidden = false;
        progressView.progress = 0;
    }

    func set(spotMediaItem: SpotMediaItem?) {
        guard let url = spotMediaItem?.url else {return}
        let asset = AVAsset(url: url)
        videoNode.asset = asset
        
        if let placeholderColor = spotMediaItem?.placeholderColor {
            videoNode.placeholderColor = UIColor(hex: placeholderColor);
        }
        
        let size = CGSize(width: frame.width * UIScreen.main.scale, height: frame.height * UIScreen.main.scale);
        guard let servingUrl = spotMediaItem?.thumbnailUrl?.imageServingUrl(cropSize: size) else {return}
        KingfisherManager.shared.retrieveImage(with: servingUrl, options: nil, progressBlock: nil, downloadTaskUpdated: nil) { (result) in
              if let image = try? result.get().image {
                self.videoNode.image = image
              }
        }
    }
    
    func set(phAsset: PHAsset) {
        let videoRequestOptions = PHVideoRequestOptions();
        videoRequestOptions.deliveryMode = .highQualityFormat;
        videoRequestOptions.isNetworkAccessAllowed = true;
        
        PHImageManager.default().requestAVAsset(forVideo: phAsset, options: videoRequestOptions, resultHandler: { (avAsset, avAudioMix, info) in
            DispatchQueue.main.sync {
                self.videoNode.asset = avAsset;
            }
        })
    }
    
    @objc func pausePlayer(notification: Notification) {
        videoNode.pause();
        iconImageView.superview?.isHidden = false;
    }
}

extension VideoCollectionViewCell: ASVideoNodeDelegate {
    func didTap(_ videoNode: ASVideoNode) {
        if videoNode.playerState == ASVideoNodePlayerState.playing {
            videoNode.pause();
        } else {
            videoNode.didExitPreloadState(); //https://stackoverflow.com/questions/64208749/portrait-videos-no-longer-retain-aspect-ratio-in-ios-14/64456029#64456029
            videoNode.play();
            iconImageView.superview?.isHidden = true;
        }
    }
    
    func videoDidPlay(toEnd videoNode: ASVideoNode) {
        videoNode.player?.seek(to: CMTime(seconds: 0, preferredTimescale: 60));
    }
    
    func videoNode(_ videoNode: ASVideoNode, didPlayToTimeInterval timeInterval: TimeInterval) {
        guard let asset = videoNode.asset else {return}
        progressView.progress = Float(timeInterval / asset.duration.seconds);
    }
    
    func videoNode(_ videoNode: ASVideoNode, willChange state: ASVideoNodePlayerState, to toState: ASVideoNodePlayerState) {
        if toState == .playing {
            progressView.isHidden = false;
            iconImageView.superview?.isHidden = true;
        }
        else {
            iconImageView.superview?.isHidden = false;
            progressView.isHidden = true;
        }
        
        if toState == .loading {
            activityIndicator.startAnimating();
        } else {
            activityIndicator.stopAnimating();
        }
    }
}
