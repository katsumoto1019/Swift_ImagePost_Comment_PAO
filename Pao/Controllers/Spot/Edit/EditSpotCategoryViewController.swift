//
//  EditSpotCategoryViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 13/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class EditSpotCategoryViewController: NewSpotCategorySubcategoryViewController {
    
    init(_ spot: Spot) {
        super.init(nibName: String(describing: NewSpotCategorySubcategoryViewController.self), bundle: nil);
        self.spot = spot;
        
        if spot.categories == nil && spot.category != nil {
            spot.categories = [spot.category!]
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Edit Category";
        
        navigationItem.rightBarButtonItem?.isEnabled = true;
    }
    
    
    override func showNextController() {
        let viewController = EditSpotPreviewViewController(spot);
        self.navigationController?.pushViewController(viewController, animated: true);
    }
}
