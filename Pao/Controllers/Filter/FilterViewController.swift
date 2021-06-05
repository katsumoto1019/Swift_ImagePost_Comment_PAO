//
//  FilterViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 5/3/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class FilterViewController: BaseViewController {
    
    @IBOutlet weak var stackView: MultiSelectButtonStackView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var doneButton: GradientButton!
    
    weak var delegate: FilterDelegate?
    public var selectedFiltersKeys:String?
    public var selectedFilters = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Filter"
        
        let sortedCategories = DataContext.cache.categories?.map({$0.name ?? "N/A"}).sorted()

        stackView.options = sortedCategories
        stackView.selectCategories(categories: selectedFilters)
        stackView.multiSelectDelegate = self
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filterLabel.text = L10n.FilterViewController.filterLabel
        doneButton.setTitle(L10n.Common.done, for: .normal)
        setupNavigationBar()
    }
    
    override func applyStyle() {
        super.applyStyle()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        filterLabel.font = UIFont.app.withSize(UIFont.sizes.normal)
    }
    
    @IBAction func dismissViewController(_ sender: Any) {
        dismiss(animated: false) {
            self.delegate?.filterBy(categories: self.selectedFiltersKeys, selectedFilters: self.selectedFilters)
        }
    }
    
    func setupNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.view.backgroundColor = ColorName.background.color
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.filter.image,
            style: .plain,
            target: self,
            action: #selector(dismissViewController))
    }
}

protocol FilterDelegate: class {
    func filterBy(categories: String?, selectedFilters: [String])
}

extension FilterViewController: MultiSelectStackViewDelegate {
    
    func addFilters(selectedFilters: [String]) {
        selectedFiltersKeys = nil
        self.selectedFilters.removeAll()
        let categories = DataContext.cache.categories
        
        categories!.forEach { (category) in
            if (selectedFilters.contains(category.name!)) {
                self.selectedFiltersKeys = (self.selectedFiltersKeys ?? "") + "\"\(category.firebaseId!)\","
                self.selectedFilters.append(category.name!)
            }
        }
        
        if !(selectedFiltersKeys?.isEmpty ?? true) {
        selectedFiltersKeys  = String(selectedFiltersKeys!.prefix(selectedFiltersKeys!.count - 1))
        selectedFiltersKeys = "[" + selectedFiltersKeys! + "]"
        } 
    }
    
    func selectionChanged(title: String?, isSelected: Bool) {
        guard isSelected == true, let title = title?.lowercased() else { return }
        
        FirbaseAnalytics.logEvent( title == "eat" ? .eatFilter : title == "play" ? .playFilter : .stayFilter)
    }
}
