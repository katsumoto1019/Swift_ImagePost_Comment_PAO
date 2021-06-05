//
//  NewSpotCategorySubcategoryViewController.swift
//  Pao
//
//  Created by Developer on 3/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos
import GameKit

class NewSpotCategorySubcategoryViewController: BaseViewController {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var categoryStackView: MultiToggleButtonStackView!
    @IBOutlet weak var subCategoriesView: UIView!
    
    var spot: Spot!
    var phAssets: [PHAsset] = []
    //var phAssetsDictionary = [String: PHAsset]()
    //var uploadImagesDictionary = [String:UIImage]()
    
    private var firstTimeChangedCategory = true
    
    var categories: [Category]?
    
    var cropDataList = [PHAsset: CropData]()
    
    private var selectedCategory: Category? {
        get {
            return categories?.first(where: { $0.name == categoryStackView.selectedOption })
        }
    }
    
    private var selectedCategoryId: String? {
        get {
            return selectedCategory?.firebaseId
        }
    }
    
    
    lazy var bubbleSizeRatio: CGFloat = {
        return (self.navigationController?.view.frame.width ?? 375.0) / 375.0
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Category Upload"
        
        initialize()
        loadCategories()
        title = L10n.NewSpotCategorySubcategoryViewController.title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadSubCategories(cellOrigins: bubblesOrigins(categoryName: selectedCategory?.name), selectedCategory?.subCategories ?? [])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setCategory()
    }
    
    private func initialize() {
        setupNavBar()
        //        setupCategory()
        categoryStackView.delegate = self
        headingLabel.text = L10n.NewSpotCategorySubcategoryViewController.headingLabel
    }
    
    override func applyStyle() {
        super.applyStyle()
        
        headingLabel.set(fontSize: UIFont.sizes.large)
    }
    
    private func setupNavBar() {
        let nextBarButton = UIBarButtonItem(title: L10n.Common.NextButton.text, style: .done, target: self, action: #selector(nextClicked))
        nextBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = nextBarButton
    }
    
    private func setupCategory() {
        
        guard self.categories != nil else { return }
        
        self.categoryStackView.options = self.categories?.map({$0.name ?? "N/A"}).sorted()
        
        let selectedCategories = self.categories!.filter { (category) -> Bool in
            return category.selected == true ||  ((category.subCategories?.first(where: { $0.selected == true })) != nil)
        }
        
        let selectedCategoryNames = selectedCategories.compactMap({ $0.name })
        
        categoryStackView.selectedOption = selectedCategoryNames.count > 0 ? selectedCategoryNames.sorted().first : nil
        
        categoryStackView.secondarySelectedOptions = selectedCategoryNames
        
        loadSubCategories(cellOrigins: bubblesOrigins(categoryName: selectedCategory?.name), selectedCategory?.subCategories ?? [])
        
        self.canProceed()
    }
    
    private func initializeCategories() {
        guard let spotCategories = spot.categories, spotCategories.count > 0,
            self.categories != nil else { return }
        
        //initialize spotCategories with selected values
        self.categories!.forEach { (category) in
            if let spotCategory = spotCategories.first(where: { $0.id == category.firebaseId }) {
                category.selected = true
                
                category.subCategories?.forEach({ (subCat) in
                    subCat.selected = spotCategory.subCategories?[subCat.firebaseId ?? "N/A"] != nil
                })
            }
        }
        ///
    }
    
    private func loadCategories() {
        bfprint("-= SOS =- loadCategories")
        
        if DataContext.cache.categories != nil {
            self.categories = DataContext.cache.categories?.duplicate(type: Category.self)
            initializeCategories()
            self.setupCategory()
            return
        }
        
        startActivityIndicator()
        let url = App.transporter.getUrl([Category].self, httpMethod: .get)
        APIManager.callAPIForWebServiceOperation(model: Category(), urlPath: url, methodType: "GET") { (apiStatus, result: [Category]?, responseObject, statusCode) in
            if(apiStatus){
                self.stopActivityIndicator()
                DataContext.cache.categories = result
                self.categories = DataContext.cache.categories?.duplicate(type: Category.self)
                self.initializeCategories()
                self.setupCategory()
            }else{
                self.stopActivityIndicator()
            }
        }
    }
    
    private func loadSubCategories(cellOrigins: [CGPoint], _ subCategories: [SubCategory]) {
        subCategoriesView.subviews.forEach({$0.removeFromSuperview()})
        let size = CGSize(width: 70 * bubbleSizeRatio, height: 70 * bubbleSizeRatio)
        let rs = GKMersenneTwisterRandomSource()
        rs.seed = 0
        var index = 0
//        for subCategory in  subCategories.sorted(by: { $0.name!.lowercased() < $1.name!.lowercased() }) {
            for subCategory in  subCategories {
            // add node
            let button = CircularToggleButton(type: .custom)
            
            guard index < cellOrigins.count else { return }

            button.delegate = self
            button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
            button.setTitle(subCategory.name, for: .normal)
            button.frame.size = size
            //            button.frame.origin = getPoint(forSize: size, insideView: subCategoriesView, rs: rs)
            button.frame.origin = cellOrigins[index]
            button.titleLabel?.set(fontSize: UIFont.sizes.tiny)
            button.isSelected = subCategory.selected ?? false
            subCategoriesView.addSubview(button)
            index = index + 1
        }
    }
    
    private func getPoint(forSize size: CGSize, insideView containerView: UIView, rs: GKMersenneTwisterRandomSource) -> CGPoint {
        
        var point = CGPoint(x: 0, y: 0)
        let container = containerView.subviews.count % 4
        point.x = CGFloat(container) * size.width
        let extraHorizontalMargin = 8 * (containerView.subviews.count % 4) / 2
        let frame = view.frame.width - (size.width * 4)
        let width = frame * 0.4
        point.x += CGFloat(extraHorizontalMargin + rs.nextInt(upperBound: extraHorizontalMargin))
        point.x += width
        
        point.y = CGFloat(containerView.subviews.count / 4) * size.height + CGFloat(containerView.subviews.count % 2) * size.height / 3
        let extraVerticalMargin = 6 * containerView.subviews.count / 4
        point.y += CGFloat(extraVerticalMargin + rs.nextInt(upperBound: extraVerticalMargin))
        return point
    }
    
    @objc func nextClicked(_ sender: UIBarButtonItem) {
        showNextController()
    }
    
    private func setCategory() {
        spot.categories = self.categories?.compactMap { (category) -> SpotCategory? in
            if let subCategories = category.subCategories?.filter({ $0.selected == true }),
                subCategories.count > 0 {
                let spotCategory = SpotCategory()
                spotCategory.id = category.firebaseId
                spotCategory.subCategories = subCategories.reduce(SpotSubCategoriesDictionary(), { (dictionary, subcategory) -> SpotSubCategoriesDictionary in
                    if let id = subcategory.firebaseId {
                        var dictionary = dictionary
                        dictionary[id] = SpotSubCategory()
                        return dictionary
                    }
                    return dictionary
                })
                return spotCategory
            }
            return nil
        }
        
        spot.category =  spot.categories?.first
    }
    
    func showNextController() {
        AmplitudeAnalytics.logEvent(.uploadCat, group: .upload)

        let viewController = NewSpotPreviewViewController()
        viewController.spot = spot
        viewController.phAssets = phAssets
        viewController.cropDataList = cropDataList
        //viewController.phAssetsDictionary = phAssetsDictionary
        //viewController.uploadImagesDictionary = uploadImagesDictionary
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension NewSpotCategorySubcategoryViewController: ToggleButtonStackViewDelegate {
    func selectionChanged(title: String?, isSelected: Bool) {
        // TODO: Come up with better solution than this.
        // NOTE: First is automatic and should be ignored.
        if (firstTimeChangedCategory) {
            firstTimeChangedCategory = false
        } else if (self is EditSpotCategoryViewController) {
            if (selectedCategory != nil) {
            // FirbaseAnalytics.trackEvent(category: .uiAction, action: .pickFilterValue, label: EventLabel(rawValue: selectedCategory!.name!)!)
            }
        }
        
        if isSelected == false {
            if let category = self.categories?.first(where: { $0.name == title }) {
                category.selected = false
                category.subCategories?.forEach({ $0.selected = false })
            }
            
            setupCategory()
            
        } else if let category = self.categories?.first(where: { $0.name == title }) {
            self.loadSubCategories(cellOrigins: bubblesOrigins(categoryName: category.name), category.subCategories ?? [])
        }
        
        self.canProceed()
    }
}

extension NewSpotCategorySubcategoryViewController: ToggleButtonDelegate {
    func toggled(_ sender: UIButton) {
        self.selectedCategory?.subCategories?.first(where: { sender.currentTitle == $0.name })?.selected = sender.isSelected
        canProceed(forceProceed: sender.isSelected)
        
        //update teal color value
        let isSecondarySelection = sender.isSelected || self.selectedCategory?.subCategories?.filter({ $0.selected == true }).count ?? 0 > 0
        
        var secondarySelections = categoryStackView.secondarySelectedOptions ?? []
        let title = self.selectedCategory?.name ?? "N/A"
        
        if isSecondarySelection && !secondarySelections.contains(title) {
            secondarySelections.append(title)
        } else if !isSecondarySelection, let index = secondarySelections.firstIndex(of: title) {
            secondarySelections.remove(at: index)
        }
        categoryStackView.secondarySelectedOptions = secondarySelections
    }
    
    private func canProceed(forceProceed: Bool = false) {
        guard !forceProceed else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            return
        }
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        for category in self.categories ?? [] {
            if category.subCategories?.filter({ $0.selected == true }).count ?? 0 > 0  {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                return
            }
        }
    }
}


extension NewSpotCategorySubcategoryViewController {
    private func bubblesOrigins(categoryName: String?) -> [CGPoint] {
        switch categoryName?.lowercased() {
        case "eat":
            return  [
                     CGPoint(x: 36, y: 14),
                     CGPoint(x: 131, y: 2),
                     CGPoint(x: 236, y: 6),
                     CGPoint(x: 16, y: 112),
                     CGPoint(x: 87, y: 80),
                     CGPoint(x: 180, y: 76),
                     CGPoint(x: 268, y: 88),
                     CGPoint(x: 62, y: 184),
                     CGPoint(x: 141, y: 158),
                     CGPoint(x: 220, y: 155),
                     CGPoint(x: 48, y: 264),
                     CGPoint(x: 137, y: 237),
                     CGPoint(x: 218, y: 258),
                     CGPoint(x: 286, y: 205)
                 ].map({ CGPoint(x: $0.x * bubbleSizeRatio, y: $0.y * bubbleSizeRatio)})
        case "play":
            return [
                CGPoint(x: 70, y: 17),
                CGPoint(x: 156, y: 7),
                CGPoint(x: 251, y: 17),
                CGPoint(x: 26, y: 88),
                CGPoint(x: 108, y: 109),
                CGPoint(x: 183, y: 75),
                CGPoint(x: 276, y: 94),
                CGPoint(x: 53, y: 169),
                CGPoint(x: 190, y: 161),
                CGPoint(x: 272, y: 172),
                CGPoint(x: 50, y: 250),
                CGPoint(x: 127, y: 215),
                CGPoint(x: 217, y: 240),
            ].map({ CGPoint(x: $0.x * bubbleSizeRatio, y: $0.y * bubbleSizeRatio)})
        case "stay":
            return [
                CGPoint(x: 52, y: 11),
                CGPoint(x: 160, y: 5),
                CGPoint(x: 243, y: 9),
                CGPoint(x: 29, y: 96),
                CGPoint(x: 103, y: 74),
                CGPoint(x: 187, y: 86),
                CGPoint(x: 273, y: 96),
                CGPoint(x: 96, y: 151),
                CGPoint(x: 187, y: 167),
                CGPoint(x: 271, y: 179),
                CGPoint(x: 37, y: 205),
                CGPoint(x: 117, y: 239),
                CGPoint(x: 210, y: 245)
                ].map({ CGPoint(x: $0.x * bubbleSizeRatio, y: $0.y * bubbleSizeRatio) })
        default:
            return []
        }
    }
}
