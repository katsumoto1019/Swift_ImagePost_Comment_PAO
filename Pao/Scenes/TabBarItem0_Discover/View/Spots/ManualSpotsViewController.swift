//
//  ManualSpotsViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 27/11/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

import Payload
import RocketData

class ManualSpotsViewController: SpotsViewController {
    private var spots: [Spot]!
    
    var isMySpot = false
    var showCommentsOnLoad = false
    
    var retryCount = 0
    
    var scrolltoIndex: IndexPath?
	
    var dataDidUpdate: ((_ spot: Spot)->Void)?
    
    init(spots: [Spot]) {
        super.init(nibName: SpotsViewController.typeName, bundle: nil)
        
        self.spots = spots
        initialize()
    }
    
    init (spotId: String) {
        super.init(nibName: SpotsViewController.typeName, bundle: nil)
        
        initialize()
        loadSpot(spotId: spotId)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    func initialize() {
        hidesBottomBarWhenPushed = true
        setTitle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Spots"
        
        collection.loadData()
        if let scrolltoIndex = scrolltoIndex, collection.count > scrolltoIndex.row {
            DispatchQueue.main.async {
                self.spotCollectionViewController.scrollTo(indexPath: scrolltoIndex, animated: false)
                self.scrolltoIndex = nil
            }
        }
        
        self.spotCollectionViewController.disablePullToRefresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        if self.collection.count > 0 {
            spotCollectionViewController.centerSpinnerView?.stopAnimating()
            spotCollectionViewController.centerSpinnerView = nil
        }
        
        if (title == nil || title == "") {
            setTitle()
        }
    }
    
    func setTitle() {
        if let locationName = self.spots?.first?.location?.name {
            title = locationName
        } else {
            title = L10n.ManualSpotsViewController.title
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        title = ""
    }
    
    override func setCacheKey() {
        collection.cacheKey = nil
    }
    
    override func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        if collection.count <= 0 {
            collection.removeAll()
            completionHandler(spots)
        } else {
            completionHandler(nil)
            collection.canLoadMore = false
        }
        return nil
    }
    
    func loadSpot(spotId: String) {
        App.transporter.get(Spot.self, pathVars: spotId) { (result) in
            guard let result = result else {
                self.retryCount += 1
                if self.retryCount < 5 {
                    self.loadSpot(spotId: spotId)
                }
                return
            }
            
            self.spotDataDidUpdate(updatedSpot: result)
            
            self.spots = [result]
            self.setTitle()
            self.collection.loadData()
            
            if self.showCommentsOnLoad {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                    self.showComments(spot: self.spots.first)
                })
            }
        }
    }
    
    func updateSpots(spots: [Spot]) {
        self.spots = spots
        setTitle()
        self.collection.loadData()
    }
    
    override func remove(spot: Spot) {
        super.remove(spot: spot)
        
        if self.collection.count <= 1 {
            navigationController?.popViewController(animated: true)
        }
    }
	
    override func spotDataDidUpdate(updatedSpot: Spot) {
		dataDidUpdate?(updatedSpot)
        DataModelManager.sharedInstance.updateModel(updatedSpot)
	}
}
