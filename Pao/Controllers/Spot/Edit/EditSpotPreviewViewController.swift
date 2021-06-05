//
//  EditSpotPreviewViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 13/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload

import RocketData

class EditSpotPreviewViewController: NewSpotPreviewViewController {

    init(_ spot: Spot) {
        super.init(nibName: String(describing: NewSpotPreviewViewController.self), bundle: nil);
        self.spot = spot;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        screenName = "Edit Preview";
    }
    
    override func createSpotAndTryUpload() {
        guard let spotId = spot.id else {return}
        
        let new = Spot();
        new.description = self.spot.description;
        new.category = self.spot.category;
        new.categories = self.spot.categories;
        
        App.transporter.put(new, returnType: Spot.self , pathVars:  SpotVars(spotId: spotId)) { (spot) in
            self.navigationController?.dismiss(animated: true, completion: nil);
            let dataProvider = DataProvider<Spot>();
            dataProvider.setData(spot);
        }
    }
}
