//
//  ProfileImagePickerViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 21/04/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Photos

class ProfileImagePickerViewController: UIViewController {
    
     let smartAlbums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.any, options: nil)
     let albums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.any, options: nil)
    
    var albumDetailsCollecton: [AlbumDetail] = []
    let albumNameButton =  UIButton(type: .custom)
    var selectedAlbumName = "Camera Roll"
    var albumSelectNavigationController: UINavigationController?
    
    lazy var imagePickerViewController = ImagePickerViewController(collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavBar()
        setupChildControllers()
        
        let titleView = UIView.init(frame: CGRect(x: 0,y: 0,width: 135,height: 40))
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
    }
    
    func setupChildControllers() {
        // ImagePickerViewController
        addChild(imagePickerViewController)
        imagePickerViewController.view.frame = view.bounds
        view.addSubview(imagePickerViewController.view)
        imagePickerViewController.didMove(toParent: self)
        imagePickerViewController.includeVideos = false
        
        //AlbumSelectionViewController
        var albumsTogether = [PHAssetCollection]()
        smartAlbums.enumerateObjects({(collection, index, object) in
            albumsTogether.append(collection)
        })
        albums.enumerateObjects({(collection, index, object) in
            albumsTogether.append(collection)
        })
        let albumSelectViewController = AlbumSelectTableViewController(phAssetCollections: albumsTogether, albums: self.albumDetailsCollecton, selectedAlbumName: selectedAlbumName )
        albumSelectViewController.indexSelectedCallback = { [weak self](selectedIndex) in
            self!.setAlbum(index: selectedIndex!)
        }
        albumSelectNavigationController = UINavigationController(rootViewController: albumSelectViewController)
    }
    
    private func setupNavBar() {
        let cancelBarButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(cancelClicked))
        self.navigationItem.rightBarButtonItem = cancelBarButton
        
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
        self.selectedAlbumName = selectedAlbum?.localizedTitle ?? title
    }
    
    @objc func cancelClicked(_ sender: UIBarButtonItem) {
        //menuView.hide()
        dismiss(animated: true)
    }
}
