//
//  NewSpotDescriptionViewController.swift
//  Pao
//
//  Created by Developer on 3/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos
import IQKeyboardManagerSwift

class NewSpotDescriptionViewController: BaseViewController {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    //@IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    
    var spot: Spot!;
    var phAssets: [PHAsset] = []
    //var phAssetsDictionary = [String: PHAsset]()
    //var uploadImagesDictionary = [String:UIImage]()
    
    let maxDescriptionLength = 600;
    var descriptionTextView = UITextView()
    
    var cropDataList = [PHAsset:CropData]()
    
    //private var firstTimeChangedTip = true;
    //private var changedTip = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Tip Upload"
        
        initialize()
        loadUserProfile()
        title = L10n.NewSpotDescriptionViewController.title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addTextView()
        descriptionTextView.keyboardAppearance = .dark
        descriptionTextView.keyboardType = .twitter
        descriptionTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        spot.description = descriptionTextView.text ?? ""
    }
    
    private func addTextView() {
        var descriptionFrame = placeholderLabel.frame
        descriptionFrame.size.height = 100
        descriptionFrame.origin.y = descriptionFrame.origin.y - 8
        descriptionFrame.origin.x = descriptionFrame.origin.x - 5
        descriptionTextView.frame = descriptionFrame
        self.view.addSubview(descriptionTextView)
        descriptionTextView.set(fontSize: UIFont.sizes.normal)
    }
    
    private func initialize() {
        descriptionTextView.delegate = self
        setupNavBar()
        setupDescription()
        setupLocation()
        updateCounter()
    }
    
    override func applyStyle() {
        super.applyStyle()
        
        headingLabel.set(fontSize: UIFont.sizes.large)
        
        addressLabel.set(fontSize: UIFont.sizes.normal)
        addressLabel.superview?.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        
        placeholderLabel.textColor = ColorName.placeholder.color
        placeholderLabel.set(fontSize: UIFont.sizes.normal)
    }
    
    private func checkCanProceed() {
        if let descriptionText = self.descriptionTextView.text, descriptionText.count > 0 {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func setupDescription() {
        if let description = spot.description, !description.isEmptyOrWhitespace {
            descriptionTextView.text = description
            placeholderLabel.isHidden = true
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        headingLabel.text = L10n.NewSpotDescriptionViewController.headingLabel
    }
    
    private func setupLocation() {
        let name = (spot.location?.name != nil) ? spot.location!.name! + ", " : String.empty;
        let formattedAddress = spot.location?.formattedAddress ?? String.empty;
        addressLabel.text = name + formattedAddress;
        
        addressLabel.superview?.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(locationLabelClicked)))
        addressLabel.superview?.isUserInteractionEnabled = true
    }
    
    private func setupNavBar() {
        let nextBarButton = UIBarButtonItem(title: L10n.Common.NextButton.text, style: .done, target: self, action: #selector(nextClicked))
        nextBarButton.isEnabled = false
        navigationItem.rightBarButtonItem = nextBarButton
    }
    
    private func loadUserProfile() {
        if let url = DataContext.cache.user?.profileImage?.url {
        self.profileImageView.kf.setImage(with: url)
        }
    }
    
    @objc func nextClicked(_ sender: UIBarButtonItem) {
        if self is EditSpotDescriptionViewController && !(spot.description?.elementsEqual(descriptionTextView.text) ?? true) {
           // FirbaseAnalytics.trackEvent(category: .uiAction, action: .enterText, label: .editPostTip)
        }
        showNextController()
    }
    
        @objc func locationLabelClicked() {
            if !(self is EditSpotDescriptionViewController) {
                self.navigationController?.popViewController(animated: true)
           }
         }

    
    func showNextController() {
        FirbaseAnalytics.logEvent(.selectCategory)
        AmplitudeAnalytics.logEvent(.enterTip, group: .upload)

        let viewController = NewSpotCategorySubcategoryViewController()
        viewController.spot = spot
        viewController.phAssets = phAssets
        viewController.cropDataList = cropDataList
        //viewController.phAssetsDictionary = phAssetsDictionary
        //viewController.uploadImagesDictionary = uploadImagesDictionary
        self.navigationController?.pushViewController(viewController, animated: false)
    }
}

extension NewSpotDescriptionViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let textLength = (countTextCharacters(textView.text) + countTextCharacters(text) - range.length)
        return (textLength > maxDescriptionLength) ? false : true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        checkCanProceed()
    }
    
    func textViewDidChange(_ textView: UITextView) {
       /* // TODO: Come up with better solution than this.
        // NOTE: First is automatic and should be ignored.
        if (firstTimeChangedTip) {
            firstTimeChangedTip = false;
        } else if (!changedTip && self is EditSpotDescriptionViewController) {
            changedTip = true;
            GoogleAnalytics.trackEvent(category: .uiAction, action: .enterText, label: .editPostTip);
        }
        */
        placeholderLabel.isHidden = !textView.text.isEmpty
        updateCounter()
        checkCanProceed()
    }
    
    func updateCounter() {
        counterLabel.text = String(format: "%d/%d", countTextCharacters(descriptionTextView.text), maxDescriptionLength);
    }
    
    func countTextCharacters(_ text: String?) -> Int {
        guard let text = text else { return 0 }
        
        let newLineSet = text.filter { (character ) -> Bool in
            return character == "\n"
        }
        return text.count - newLineSet.count + (newLineSet.count *  13)
    }
}

