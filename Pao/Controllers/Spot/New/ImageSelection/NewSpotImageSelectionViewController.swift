//
//  NewSpotImageSelectionViewController.swift
//  Pao
//
//  Created by Developer on 2/22/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos

class NewSpotImageSelectionViewController: BaseViewController {
    @IBOutlet weak var carouselContainerView: UIView!
    @IBOutlet weak var imagePickerContainerView: UIView!
    @IBOutlet weak var carouselContainerBottomView: UIView!
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    
    ///Used for expanding and collapsing of CarousalContainerView
    var lastTranslation: CGPoint?
    var isMovingUpperView = false
    //var isFirstLoad = true
    
    let previewCarouselViewController = PreviewCarouselViewController(collectionViewLayout: UICollectionViewFlowLayout())
    let imagePickerViewController = ImagePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
    
    let smartAlbums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: nil)
    let albums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)
    
    var albumDetailsCollecton: [AlbumDetail] = []
    let albumNameButton =  UIButton(type: .custom)
    var selectedAlbumName = "Camera Roll"
    var albumSelectNavigationController: UINavigationController?
    
    var spot = Spot()

    var allAssets: [String: ImagesAsset] = [:]
    var allSelectedAssets: [PHAsset] = []

    struct ImagesAsset: Equatable {
        var assets: [PHAsset] = []
        var indexPathForSelectedItems: [IndexPath] = []
        var startIndex: Int = -1

        var count: Int {
            return assets.count
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Image Upload"

        setupNavBar()
        setupChildControllers()
        setupCarousalBottomView()
        imagePickerViewController.scrolledCallback = {[unowned self] (position, translation,contentOffset,velocity) in return self.scrolledCollection(at: position, translation: translation, contentOffset: contentOffset,velocity: velocity)
        }
        imagePickerViewController.selectionWasChanged = { [weak self] tupple in
            self?.imagePickerSelectionChanged(tupple: tupple)
        }
        
        let titleView = UIView.init(frame: CGRect(x: 0, y: 0, width: 135, height: 40))
         albumNameButton.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
         albumNameButton.setTitle(selectedAlbumName, for: .normal)
        // albumNameButton.addTarget(self, action: #selector(clickOnButton), for: .touchUpInside)
         albumNameButton.isUserInteractionEnabled = false
         titleView.addSubview(albumNameButton)
         
         let downArrow = Asset.Assets.Icons.arrowdown.image
         let imageView = UIImageView(image: downArrow)
         imageView.frame = CGRect(x: 125, y: 15, width: 10, height: 10)
         titleView.addSubview(imageView)
         
         let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(showAlbums))
         titleView.addGestureRecognizer(tapGesture)
         titleView.isUserInteractionEnabled = true
         
         navigationItem.titleView = titleView
    }
    
    @objc func showAlbums() {
        albumSelectNavigationController!.modalPresentationStyle = .fullScreen
        self.present(albumSelectNavigationController!, animated:true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13.0, *) {
            self.title = "All Photos"
        }
        else {
            self.title = "Camera Roll"
        }
        //if !isFirstLoad, spot.mediaCount ?? 0 > 0 {
        //spot.media?.values.forEach({ (spotMediaItem) in
        //        if spotMediaItem.url != nil {
        //            try? FileManager.default.removeItem(at: //spotMediaItem.url!)
             //   }
           // })
        //}
        //isFirstLoad = false
    }
    
    func setupChildControllers() {
        // CarouselViewController
        self.addChild(previewCarouselViewController)
        previewCarouselViewController.view.frame = carouselContainerView.bounds
        carouselContainerView.addSubview(previewCarouselViewController.view)
        previewCarouselViewController.didMove(toParent: self)
        
        // ImagePickerViewController
        self.addChild(imagePickerViewController)
        imagePickerViewController.view.frame = imagePickerContainerView.bounds
        imagePickerContainerView.addSubview(imagePickerViewController.view)
        imagePickerViewController.didMove(toParent: self)
        
        //AlbumSelectionViewController
        var albumsTogether = [PHAssetCollection]()
        smartAlbums.enumerateObjects({(collection, index, object) in
            albumsTogether.append(collection)
        })
        albums.enumerateObjects({(collection, index, object) in
            albumsTogether.append(collection)
        })
        let albumSelectViewController = AlbumSelectTableViewController(phAssetCollections: albumsTogether, albums: self.albumDetailsCollecton, selectedAlbumName: selectedAlbumName )
        albumSelectViewController.indexSelectedCallback = { [weak self] selectedIndex in
            self?.setAlbum(index: selectedIndex!)
        }
        albumSelectNavigationController = UINavigationController(rootViewController: albumSelectViewController)
    }
    
    private func setupNavBar() {
        let nextBarButton = UIBarButtonItem(title: L10n.Common.NextButton.text, style: .done, target: self, action: #selector(nextClicked))
        nextBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = nextBarButton
        
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(cancelClicked))
        self.navigationItem.leftBarButtonItem = cancelBarButton
        
        var albumNames = [String]()
        // NOTE: Order matters
        if #available(iOS 13.0, *) {
            albumNames.append("All Photos")
        }
        albumNames.append(contentsOf: getAlbumNames(albums: smartAlbums))
        albumNames.append(contentsOf: getAlbumNames(albums: albums))
        
        // TODO: revisit this to allow actual user albums
        var defaultIndex = 0
        if #available(iOS 13.0, *) {
        } else {
            defaultIndex = albumNames.firstIndex(of: "Camera Roll") ?? albumNames.firstIndex(of: "All Photos") ?? albumNames.firstIndex(of: "Moments") ?? 0
        }
        
        setAlbum(index: defaultIndex)
    }
    
    private func getAlbumNames(albums: PHFetchResult<PHAssetCollection>) -> [String] {
        var albumNames = [String]()
        
        if #available(iOS 13.0, *) {
            albumNames.append("All Photos")
            let album = AlbumDetail()
            album.albumName = "All Photos"
            self.albumDetailsCollecton.append(album)
        }
        
        albums.enumerateObjects({(collection, index, object) in
            albumNames.append(collection.localizedTitle ?? "N/A")
            let album = AlbumDetail()
            album.id = collection.localIdentifier
            album.albumName = collection.localizedTitle ?? "N/A"
            self.albumDetailsCollecton.append(album)
        })
        
        return albumNames
    }
    
    private func setAlbum(index: Int) {

        var selectedAlbum: PHAssetCollection?
        if #available(iOS 13.0, *), index == 0 {
            imagePickerViewController.album = nil
        } else {
            var index = index
            if #available(iOS 13.0, *) {
                index  -= index < smartAlbums.count ? 1 : 2
            }
            if (index < smartAlbums.count) {
                imagePickerViewController.album = smartAlbums.object(at: index)
                selectedAlbum = smartAlbums.object(at: index)
            } else {
                imagePickerViewController.album = albums.object(at: index - smartAlbums.count)
                selectedAlbum = albums.object(at: index - smartAlbums.count)
            }
        }
        var title = ""
        if #available(iOS 13.0, *) {
            title = "All Photos"
        }
        else {
            title = "Camera Roll"
        }

        albumNameButton.setTitle(selectedAlbum?.localizedTitle ?? title, for: .normal)
        selectedAlbumName = selectedAlbum?.localizedTitle ?? title

        if allAssets[selectedAlbumName] == nil {
            allAssets[selectedAlbumName] = ImagesAsset(
                assets: [],
                indexPathForSelectedItems: [],
                startIndex: -1)
        }
        if allAssets[selectedAlbumName]?.startIndex ?? 0 < 0 {
            var index = 0
            allAssets.forEach {
                if $0.key != selectedAlbumName, $0.value.startIndex != -1 {
                    index += 1
                }
            }
            allAssets[selectedAlbumName]?.startIndex = index
        }

        var count = 0
        allAssets.forEach {
            if $0.key != selectedAlbumName, $0.value.startIndex < allAssets[selectedAlbumName]?.startIndex ?? 0 {
                count += $0.value.count
            }
        }

        imagePickerViewController.currentSelection = count
        imagePickerViewController.indexPathForSelectedItems = allAssets[selectedAlbumName]?.indexPathForSelectedItems ?? []
    }

    @objc
    func nextClicked(_ sender: UIBarButtonItem) {
        FirbaseAnalytics.logEvent(.selectLocation)
        AmplitudeAnalytics.logEvent(.selectPhotos, group: .upload)
        
        let viewController = NewSpotLocationViewControllerUpdated()
        viewController.spot = spot
        viewController.cropDataList = previewCarouselViewController.cropDataList
        viewController.phAssets = allSelectedAssets
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func cancelClicked(_ sender: UIBarButtonItem) {
        //menuView.hide()
        navigationController?.dismiss(animated: true, completion: nil)
    }

    func imagePickerSelectionChanged(tupple: SelectionChangedTuple) {
        var removedIndex = -1
        if tupple.isAdded {
            if let lastElement = imagePickerViewController.selectedPHAssets.last {
                allSelectedAssets.append(lastElement)
            }
        } else {
            if let removedAsset = allAssets[selectedAlbumName]?.assets[tupple.index] {
                if let index = allSelectedAssets.firstIndex(of: removedAsset) {
                    allSelectedAssets.remove(at: index)
                    removedIndex = index
                }
            }
        }
        allAssets[selectedAlbumName]?.assets = imagePickerViewController.selectedPHAssets
        allAssets[selectedAlbumName]?.indexPathForSelectedItems = imagePickerViewController.indexPathForSelectedItems

        previewCarouselViewController.phAssets = allSelectedAssets

        self.navigationItem.rightBarButtonItem?.isEnabled = previewCarouselViewController.phAssets.count > 0
        let indexPaths = [IndexPath(item: self.allSelectedAssets.count-1, section: 0)]
        if tupple.isAdded {
            previewCarouselViewController.collectionView?.insertItems(at: indexPaths)
            if let indexPath = indexPaths.last {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                    self.previewCarouselViewController.collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                }
            }
        } else {
            let indexPath = IndexPath(item: removedIndex, section: 0)
            if previewCarouselViewController.collectionView.indexPathsForVisibleItems.contains(indexPath) {
                previewCarouselViewController.collectionView?.deleteItems(at: [indexPath])
            } else {
                previewCarouselViewController.collectionView?.reloadData()
                previewCarouselViewController.collectionView?.scrollToLast()
            }
        }
    
    }
    
    private func setupCarousalBottomView() {
        carouselContainerView.bringSubviewToFront(carouselContainerBottomView)
        carouselContainerBottomView.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(panHandler(recognizer:))))
        carouselContainerBottomView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapHandler(recognizer:))))
        carouselContainerBottomView.isUserInteractionEnabled = true
    }
    
    @objc func panHandler(recognizer: UIPanGestureRecognizer) {
        handlePaneGesture(recognizer: recognizer)
    }
    
    @objc func tapHandler(recognizer: UITapGestureRecognizer) {
        handleTapGesture(recognizer: recognizer)
    }
}
