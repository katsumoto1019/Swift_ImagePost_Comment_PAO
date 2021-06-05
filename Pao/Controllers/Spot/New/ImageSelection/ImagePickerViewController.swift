//
//  ImagePickerViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/28/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos

typealias SelectionChangedTuple = (isAdded: Bool, index: Int)

class ImagePickerViewController: BasicCollectionViewController {
    
    static let ImagePickerSelectionChangedNotification = "ImagePickerSelectionChangedNotification"
    var selectionWasChanged: ((SelectionChangedTuple) -> ())?
    override var cellsPerRow: Int { return 4 }
    
    private let maxVideoSize: Float = 30 //MBs

    var currentSelection = 0
    private let maxSelection = 10
    var indexPathForSelectedItems = [IndexPath]()
    
    //Used for translating imagePickerContainerView in NewSpotImageSelctionViewController
    private var freezContentOffset = CGPoint.zero
    var scrolledCallback: ((_ position: CGPoint?, _ translation: CGPoint?,_ contentOffset: CGPoint?, _ velocity: CGPoint?) -> Bool)?
    ///
    
    weak var delegate: ImagePickerViewDelegate?
    
    var album: PHAssetCollection? {
        didSet {
            let fetchOptions = PHFetchOptions()
            if self.includeVideos {
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
            } else {
                fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
            }
            
            if let album = album {
                fetchResult = PHAsset.fetchAssets(in: album, options: fetchOptions)
            } else {
                fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: true)]
                fetchResult = PHAsset.fetchAssets(with: fetchOptions)
            }
            
            collectionView?.reloadData()
            if collectionView?.numberOfItems(inSection: 0) ?? 0 > 0 {
                collectionView?.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
            }
            indexPathForSelectedItems.removeAll()
        }
    }

    var selectedPHAssets: [PHAsset] {
        var phAssets = [PHAsset]()
        for indexPath in indexPathForSelectedItems {
            let phAsset = fetchResult[reverseIndex(indexPath)]
            phAssets.append(phAsset)
        }

        return phAssets
    }
    
    var fetchResult: PHFetchResult<PHAsset>!
    var includeVideos: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register cell classes
        self.collectionView?.backgroundColor = .clear
        self.collectionView?.register(SelectableImageCollectionViewCell.self)
        
        self.collectionView?.allowsMultipleSelection = true
        self.collectionView?.alwaysBounceVertical = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        selectIndexies(indexies: indexPathForSelectedItems)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func selectionIndex(ofCell: UICollectionViewCell) -> Int {
        guard
            let indexPath = collectionView?.indexPathForItem(at: ofCell.frame.origin),
            let index = indexPathForSelectedItems.firstIndex(of: indexPath) else {
            return 0
        }
        
        return index + currentSelection
    }

    func selectIndexies(indexies: [IndexPath]) {
        indexies.forEach { [weak self] item in
            guard let self = self else { return }
            self.collectionView.selectItem(at: item, animated: true, scrollPosition: .centeredVertically)
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectableImageCollectionViewCell.reuseIdentifier, for: indexPath) as! SelectableImageCollectionViewCell
        
        cell.set(phAsset: fetchResult[reverseIndex(indexPath)])
        cell.delegate = self
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return checkAssetSize(indexPath: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectionCount = collectionView.indexPathsForSelectedItems?.count,
            selectionCount + currentSelection <= maxSelection else {
                collectionView.deselectItem(at: indexPath, animated: false)
                return
        }
        indexPathForSelectedItems.append(indexPath)
		NotificationCenter.default.post(
			name: NSNotification.Name(rawValue: ImagePickerViewController.ImagePickerSelectionChangedNotification),
			object: nil)
        selectionWasChanged?((true, indexPathForSelectedItems.count - 1 + currentSelection))
        delegate?.didSelect(controller: self)
    }
    
	override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		guard let index = indexPathForSelectedItems.firstIndex(of: indexPath) else { return }
		indexPathForSelectedItems.remove(at: index)
		NotificationCenter.default.post(
			name: NSNotification.Name(rawValue: ImagePickerViewController.ImagePickerSelectionChangedNotification),
			object: nil)
		selectionWasChanged?((false, index))
	}
    
    private func checkAssetSize(indexPath: IndexPath) -> Bool {
        let index = reverseIndex(indexPath)
        let phAsset = fetchResult[index]
        
        if phAsset.mediaType == .video {
            let resources = PHAssetResource.assetResources(for: phAsset) // your PHAsset
            var sizeOnDisk: Int64 = 0
            
            if
                let resource = resources.first,
                let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong {
                let pattern = UInt64(unsignedInt64)
                sizeOnDisk = Int64(bitPattern: pattern)
            }
            
            let size = Double(sizeOnDisk) / (1024.0 * 1024.0)
            
            if sizeOnDisk != 0, Float(size) > maxVideoSize {
                let message = L10n.ImagePickerViewController.message((Int(maxVideoSize)))
                navigationController?.topViewController?.showMessagePrompt(message: message, customized: true)
                AmplitudeAnalytics.logEvent(.tooLargeVideo, group: .uploadEvents, properties: ["error" : message])
                return false
            }
        }
        return true
    }
}

//Mark - Freezing scrolling and sending callbacks
extension ImagePickerViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.panGestureRecognizer.location(in: self.view)
        let translation = scrollView.panGestureRecognizer.translation(in: self.view)
        
        if (scrollView.panGestureRecognizer.state == .changed || scrollView.panGestureRecognizer.state == .began) &&
            (scrolledCallback?(position,translation,scrollView.contentOffset, nil) ?? false) {
            scrollView.contentOffset = freezContentOffset
        } else {
            //Freeze scrolling
            freezContentOffset = scrollView.contentOffset
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        _ = scrolledCallback?(nil,nil,nil,scrollView.panGestureRecognizer.velocity(in: self.view))
    }
}

extension ImagePickerViewController {
    func reverseIndex(_ indexPath: IndexPath) -> Int {
        return fetchResult.count - 1 - indexPath.item
    }
}

protocol ImagePickerViewDelegate: class {
    func didSelect(controller: ImagePickerViewController)
}
