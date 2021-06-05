//
//  PreviewCarouselViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/28/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos
import CropViewController

class PreviewCarouselViewController: UICollectionViewController {
    
    var phAssets: [PHAsset] = [PHAsset]() {
        didSet {
            self.collectionView.backgroundView?.isHidden =  phAssets.count > 0;
        }
    }
    
    //cropData details
    var cropDataList = [PHAsset:CropData]()
    
    var isLoaded = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        registerCells()
        self.collectionView?.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if isLoaded {
            return;
        }
        isLoaded = true;
        
        let carouselFlowLayout = UPCarouselFlowLayout();
        carouselFlowLayout.itemSize.width = collectionView!.bounds.width - 130;
        carouselFlowLayout.itemSize.height = collectionView!.bounds.height - 24;
        carouselFlowLayout.sideItemAlpha = 1;
        carouselFlowLayout.sideItemScale = 0.9;
        carouselFlowLayout.spacingMode = .overlap(visibleOffset: 50);
        carouselFlowLayout.scrollDirection = .horizontal;
        
        self.collectionView?.collectionViewLayout = carouselFlowLayout;
        self.collectionView.backgroundView = emptyView;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews();
        
        emptyView.frame = self.collectionView.bounds;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerCells() {
        collectionView.register(ImageCollectionViewCell.self);
        collectionView.register(VideoCollectionViewCell.self);
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return phAssets.count;
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let phAsset = phAssets[indexPath.row];
        
        if phAsset.mediaType == .image {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell;
            
            //cell.set(phAsset: phAssets[indexPath.row]);
            
            if let cropData = cropDataList[phAssets[indexPath.row]], let croppedImage = cropData.cropedImage {
                cell.thumbnailImageView.image = croppedImage
             } else {
                cell.set(phAsset: phAssets[indexPath.row])
                cropDataList[phAssets[indexPath.row]] = CropData()
            }
            cell.thumbnailImageView.cropData = cropDataList[phAssets[indexPath.row]]
            cell.thumbnailImageView.delegate = self

            return cell;
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.reuseIdentifier, for: indexPath) as! VideoCollectionViewCell;
            
            cell.set(phAsset: phAssets[indexPath.row]);
            
            return cell;
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(name:.carouselSwipe, object: nil);
    }
    
    private var emptyView:UIView = {
        var stackView = UIStackView()
        stackView.axis = .vertical;
        stackView.backgroundColor = UIColor.clear;
        stackView.spacing = 8.0
        
        stackView.addArrangedSubview(UILabel.init(text: L10n.PreviewCarouselViewController.selectCoverPhoto, font: UIFont.app.withSize(UIFont.sizes.normal), color: .white, textAlignment: .center))
        stackView.addArrangedSubview(UILabel.init(text: L10n.PreviewCarouselViewController.chooseUpto10, font: UIFont.app.withSize(UIFont.sizes.small), color: .lightGray, textAlignment: .center))
        stackView.arrangedSubviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        var containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.addSubview(stackView)
        stackView.constraintToFitInCenter(inContainerView: containerView)
        stackView.constraintToFitHorizontally(inContainerView: containerView)
        
        return containerView
    }()
}

extension PreviewCarouselViewController: CarouselPickerImageViewDelegate {
    func showCropper(cropViewController: CropViewController) {
        cropViewController.modalPresentationStyle = .fullScreen
        self.parent?.present(cropViewController, animated: false);
    }
}

class CropData {
    var cropFrame: CGRect?
    var cropAngle:Int?
    var originalImage: UIImage?
    var cropedImage: UIImage?
}
