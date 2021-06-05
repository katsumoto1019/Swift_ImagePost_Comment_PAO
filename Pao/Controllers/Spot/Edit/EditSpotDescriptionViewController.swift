//
//  EditSpotDescriptionViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 13/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class EditSpotDescriptionViewController: NewSpotDescriptionViewController {
    
    init(_ spot: Spot) {
        super.init(nibName: String(describing: NewSpotDescriptionViewController.self), bundle: nil);
        self.spot = spot;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Edit Tip";
        
        title = L10n.EditSpotDescriptionViewController.title
        descriptionTextView.text = spot.description;
        textViewDidChange(descriptionTextView);
        
         self.navigationItem.leftBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action:#selector(cancelClicked))
        
        FirbaseAnalytics.logEvent(.editTip)
    }
    
    @objc func cancelClicked() {
        dismiss(animated: true, completion: nil);
    }
    
//    override func backClicked() {
//        //block going back in Edit mode
//    }
    
    override func showNextController() {
        FirbaseAnalytics.logEvent(.editCategory)
        
        let viewController = EditSpotCategoryViewController(spot);
        self.navigationController?.pushViewController(viewController, animated: false);
    }
}
