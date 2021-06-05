//
//  GoPhotosCollectionViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 03/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class GoPhotosCollectionViewController: CollectionViewController<GoPhotoCollectionViewCell> {
    
    private var spot: Spot!
    var spotDidUpdateCallBack: ((_ spot: Spot)->Void)?
    
    init(spot: Spot) {
        super.init();
        
        self.spot = spot;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews();
        
        view.frame = view.superview!.bounds;
    }
    
    override func getPayloads(completionHandler: @escaping ([Spot]?) -> Void) -> PayloadTask? {
        let params = GoPhotosParams(skip: collection.count, take: collection.bufferSize);
        let vars = GoPhotosVars(googlePlaceId: spot.location!.googlePlaceId!);
        return App.transporter.get([Spot].self, for: type(of: self), pathVars: vars, queryParams: params, completionHandler: completionHandler);
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? GoPhotoCollectionViewCell {
            cell.delegate = self;
        }
    }
    
    @objc func goBack() {
        presentedViewController?.dismiss(animated: true, completion: nil);
    }
}

extension GoPhotosCollectionViewController: GoPhotoCollectionDelegate {
    func showProfile(user: User?) {
        guard let user = user else {return};
        let vc = UserProfileViewController.init(user: user);
        let navigationController = UINavigationController.init(rootViewController: vc);
        self.present(navigationController, animated: true, completion: nil);
        
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.leftArrowNav.image,
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
    }
    
    func showSpot(spot: Spot?) {
        FirbaseAnalytics.logEvent(.goPageViewSpot)
        guard let spot = spot else {return};
        
        let vc = ManualSpotsViewController.init(spots: [spot]);
        vc.title = spot.location?.name
        let navigationController = UINavigationController.init(rootViewController: vc);
        self.present(navigationController, animated: true, completion: nil);
        
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.leftArrowNav.image,
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
        vc.dataDidUpdate = { (spot: Spot) in
            // update spot data
            if let index = self.collection.firstIndex(of: spot) {
                self.collection[index] = spot
                self.collectionView.reloadData()
                self.spotDidUpdateCallBack?(spot)
            }
        }
    }
}

extension GoPhotosCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 3 // Number of columns in a row
        let spacing: CGFloat = 3 // inter space between cell
        let cellWidth = (collectionView.frame.width - spacing * columns-1) / columns;
        return CGSize(width: cellWidth, height: cellWidth)
    }
}
