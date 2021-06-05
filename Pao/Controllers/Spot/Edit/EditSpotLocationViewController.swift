//
//  EditSpotLocationViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 13/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class EditSpotLocationViewController: NewSpotLocationViewController {
    
    init(_ spot: Spot) {
        super.init(nibName: String(describing: NewSpotLocationViewController.self), bundle: nil);
        self.spot = spot;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.EditSpotLocationViewController.title
        locationLabel.text = spot.location?.formattedAddress;
        navigationItem.rightBarButtonItem?.isEnabled = true;
    }
    
    override func showNextController() {
        let viewController = EditSpotDescriptionViewController(spot);
        viewController.modalPresentationStyle = .fullScreen;
        navigationController?.pushViewController(viewController, animated: true);
    }
}
