//
//  AlbumSelectTableViewController.swift
//  Pao
//
//  Created by MACBOOK PRO on 26/06/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Payload
import Photos

class AlbumSelectTableViewController: UITableViewController {
    
    var phAssetCollections = [PHAssetCollection]();
    
    /// list of whole albums passed to this viewController
    var albums: [AlbumDetail] = [];
    
    /// list of only albums which are not empty
    var albumsSelected: [AlbumDetail] = [];
    
    var indexSelectedCallback: ((_ selectedIndex: Int?) -> Void)?
    let albumNameButton =  UIButton();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(AlbumSelectTableViewCell.self);
        self.disablePullToRefresh()
        
        self.tableView.separatorStyle = .none;
        self.navigationController?.navigationBar.barTintColor = UIColor.white;
        self.tableView.backgroundColor = ColorName.background.color
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.leftArrowNav.image,
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
    }
    
    init(phAssetCollections: [PHAssetCollection], albums: [AlbumDetail] , selectedAlbumName: String) {
        super.init(nibName: nil, bundle: nil);
        
        self.phAssetCollections = phAssetCollections;
        self.albums = albums;
        self.albumsSelected = albums;
        
        self.prepareData(albumsDetail: self.albums);
        
        let titleView = UIView.init(frame: CGRect(x: 0,y: 0,width: 135,height: 40));
        albumNameButton.frame = CGRect(x: 0, y: 0, width: 120, height: 40);
        albumNameButton.setTitle(selectedAlbumName , for: .normal);
        albumNameButton.setTitleColor(UIColor.white, for: .normal)
        albumNameButton.isUserInteractionEnabled = false
        //albumNameButton.addTarget(self, action: #selector(clickOnButton), for: .touchUpInside);
        titleView.addSubview(albumNameButton);
        
        let downArrow = Asset.Assets.Icons.arrowupblack.image
        let imageView = UIImageView(image: downArrow)
        imageView.frame = CGRect(x: 125, y: 15, width: 10, height: 10);
        titleView.addSubview(imageView)
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(showAlbums))
        titleView.addGestureRecognizer(tapGesture)
        titleView.isUserInteractionEnabled = true
        
        navigationItem.titleView = titleView;
    }
    
    @objc func showAlbums() {
        dismiss(animated: true, completion: nil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    @IBAction func goBack(_ sender: Any) {
        dismiss(animated: true, completion: nil);
    }
}

// MARK: - TableView dataSource and delegate functions
extension AlbumSelectTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albumsSelected.count;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumSelectTableViewCell.reuseIdentifier) as! AlbumSelectTableViewCell;
        cell.set(albumsSelected[indexPath.row]);
        return cell;
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if albumsSelected[indexPath.item].id != nil {
            indexSelectedCallback?(albums.firstIndex(where: {$0.id == albumsSelected[indexPath.item].id!})!);
            dismiss(animated: true, completion: nil);
        } else {
            indexSelectedCallback?(0);
            dismiss(animated: true, completion: nil);
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85;
    }
}

// MARK: - fetch coveriamge, imageCount, and remove empty albums
extension AlbumSelectTableViewController {
    
    func prepareData(albumsDetail: [AlbumDetail]) {
        var albumsSelected = [AlbumDetail]()
        let fetchOptions = PHFetchOptions();
        var fetchResult: PHFetchResult<PHAsset>!
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)];
        fetchOptions.fetchLimit = 1;
        
        if #available(iOS 13.0, *) {
            if let selectedAlbum = albumsDetail.first(where: {$0.id == nil}) {
                if let phAsset = PHAsset.fetchAssets(with: fetchOptions).firstObject {
                    selectedAlbum.phAsset = phAsset
                }
                albumsSelected.append(selectedAlbum)
            }
        }
        
        self.tableView.reloadData()
        
        DispatchQueue.background(background: {
            // do something in background
            
            for index in 0..<self.phAssetCollections.count {
                let phAssetCollection = self.phAssetCollections[index];
                
                guard let selectedAlbum = albumsDetail.first(where: {$0.id == phAssetCollection.localIdentifier}) else {continue}
                
                if (selectedAlbum.includeVideos) {
                    fetchOptions.predicate = NSPredicate(format: "mediaType = %d || mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
                } else {
                    fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                }
                
                fetchResult = PHAsset.fetchAssets(in: phAssetCollection, options: fetchOptions);
                //            selectedAlbum.imagesCount = 0;
                
                if let fetchResult = fetchResult, fetchResult.count > 0 {
                    //                selectedAlbum.imagesCount = fetchResult.count;
                    let phAsset = fetchResult[0];
                    selectedAlbum.phAsset = phAsset;
                    albumsSelected.append(selectedAlbum);
                }
            }
            
            self.albumsSelected = albumsSelected;
        }, completion:{
            // when background job finished, do something in main thread
            self.tableView.reloadData()
        })
    }
}
