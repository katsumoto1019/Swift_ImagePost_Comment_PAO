//
//  ImageCollectionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/1/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

class ImageCollectionViewController: StyledCollectionViewController {

    let pageControl = UIPageControl();
    let pageControlView = UIView();
    
    private var imageSources = [Any]();
    private var kingfisherTasks = [Int: DownloadTask]();
    
    private var pageControlViewTopConstraint: NSLayoutConstraint?
    
    var gaSwipeAction: EventAction = .spotScrollImages;
    
    var cropDataList = [PHAsset:CropData]()
    
    //Amplitude
    private var previousCellIndex:Int = 0; //used for detecting up/down swipe

    override func viewDidLoad() {
        super.viewDidLoad();
        
        collectionView?.register(VideoCollectionViewCell.self);
        collectionView?.register(ImageCollectionViewCell.self);
        
        collectionView?.prefetchDataSource = self;
        collectionView?.dataSource = self;
        collectionView?.delegate = self;
        
        collectionView?.isPagingEnabled = true;
      
        collectionView?.showsVerticalScrollIndicator = false;
        collectionView?.showsHorizontalScrollIndicator = false;
        
        setupPageControl();
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarUpdated(notification:)), name: .statusBarFrameUpdate, object: nil);
    }
    
    @objc
    private func statusBarUpdated(notification: Notification) {
        guard let newFrame = notification.object as? CGRect else {return}
        if newFrame.height > 20 {
            pageControlViewTopConstraint?.constant = 16;
        } else {
            pageControlViewTopConstraint?.constant = 8;
        }
    }
    
    private func setupPageControl() {
        pageControl.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false;
        pageControlView.translatesAutoresizingMaskIntoConstraints = false;
        
        view.addSubview(pageControlView);
        
        let initialTopMargin: CGFloat = UIApplication.shared.statusBarFrame.height > 20 ? 16 : 8;
        pageControlViewTopConstraint = pageControlView.topAnchor.constraint(equalTo: view.topAnchor, constant: initialTopMargin);
        pageControlViewTopConstraint?.isActive = true;
        pageControlView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true;
        
        pageControlView.addSubview(pageControl);
        if #available(iOS 14.0, *) {
            pageControl.allowsContinuousInteraction = false;
            pageControl.backgroundStyle = .minimal;
        } else {
            // Fallback on earlier versions
        };
        
        pageControl.centerXAnchor.constraint(equalTo: pageControlView.centerXAnchor).isActive = true;
        pageControl.centerYAnchor.constraint(equalTo: pageControlView.centerYAnchor).isActive = true;
        
        pageControlView.heightAnchor.constraint(equalTo: pageControl.widthAnchor, constant: 2).isActive = true;
        pageControlView.widthAnchor.constraint(equalToConstant: 14).isActive = true;
        
        // note that the below won't work since the pagecontrol has a rotation transform
        //pageControlView.heightAnchor.constraint(equalTo: pageControl.heightAnchor).isActive = true;
        //pageControlView.widthAnchor.constraint(equalTo: pageControl.widthAnchor).isActive = true;
        
        pageControlView.backgroundColor = ColorName.backgroundHighlight.color.withAlphaComponent(0.6);
        pageControlView.makeCornerRound(cornerRadius: 12 / 2);
    }
    
    func set(spotImages: [SpotMediaItem]) {
        self.imageSources = spotImages;
        reload();
    }
    
    func set(phAssets: [PHAsset]) {
        self.imageSources = phAssets;
        reload();
    }
    
    func set(phAssets: [PHAsset], cropDataList: [PHAsset:CropData]) {
        self.imageSources = phAssets
        self.cropDataList = cropDataList
        reload()
    }
    
    private func reload() {
        self.collectionView?.reloadData();
        pageControl.numberOfPages = imageSources.count;
        pageControl.isEnabled = false; //imageSources.count > 1; // now always disabled so there is no interation
        pageControlView.layoutIfNeeded();
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageSources.count;
    }
    
    //TODO: Clean this mess.
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell;
        
        // Better approach to support multi type image sources?
        let imageSource = imageSources[indexPath.row];
        if let spotImage = imageSource as? SpotMediaItem {
            if spotImage.type == 1 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.reuseIdentifier, for: indexPath) as! VideoCollectionViewCell;
                cell.set(spotMediaItem: spotImage);
                return cell;
            }
            cell.set(spotImage: spotImage);
        }
        
        if let phAsset = imageSource as? PHAsset {
            if phAsset.mediaType == .image {
               // cell.set(phAsset: phAsset);
                if let cropData = cropDataList[imageSources[indexPath.row] as! PHAsset], let croppedImage = cropData.cropedImage {
                    cell.thumbnailImageView.image = croppedImage
                 } else {
                    cell.set(phAsset: imageSources[indexPath.row] as! PHAsset)
                    cropDataList[imageSources[indexPath.row] as! PHAsset] = CropData()
                }
                cell.thumbnailImageView.cropData = cropDataList[imageSources[indexPath.row] as! PHAsset]
            }
            else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.reuseIdentifier, for: indexPath) as! VideoCollectionViewCell;
                cell.set(phAsset: phAsset);
                return cell;
            }
        }
        
        return cell;
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let index = self.collectionView?.indexPathsForVisibleItems.first?.item {
            pageControl.currentPage = index;
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: .carouselSwipe, object: nil);
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let currentCellIndex = currentCellIndex else {return};
        let imageSource = imageSources[currentCellIndex];
        guard let spotImage = imageSource as? SpotMediaItem else {return}
        guard let imageId = spotImage.id else {return}
        
        let isDownSwipe = currentCellIndex < self.previousCellIndex
        self.previousCellIndex = currentCellIndex
        
        FirbaseAnalytics.logEvent(gaSwipeAction, parameters: ["image_id": imageId])
        
        AmplitudeAnalytics.logEvent(.scroll, group: .viewSpots, properties: ["scroll direction": isDownSwipe ? "down" : "up"])
    }
}

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0;
    }
}

extension ImageCollectionViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            guard let spotImage = imageSources[indexPath.row] as? SpotMediaItem else {continue}
            guard let url = spotImage.url else {continue}
            let size = CGSize(width: view.frame.width * UIScreen.main.scale, height: view.frame.height * UIScreen.main.scale);
            let servingUrl = url.imageServingUrl(cropSize: size);
            kingfisherTasks[indexPath.row] = KingfisherManager.shared.retrieveImage(with: servingUrl, options: nil, progressBlock: nil, completionHandler: nil);
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            kingfisherTasks[indexPath.row]?.cancel();
        }
    }
}
