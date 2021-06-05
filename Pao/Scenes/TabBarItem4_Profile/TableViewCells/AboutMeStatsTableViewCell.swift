//
//  AboutMeStatsTableViewCell.swift
//  Pao
//
//  Created by Exelia Technologies on 05/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class AboutMeStatsTableViewCell: UITableViewCell {
    @IBOutlet weak var leadingTitleLabel: UILabel!
    @IBOutlet weak var leadingValueLabel: UILabel!
    @IBOutlet weak var middleTitleLabel: UILabel!
    @IBOutlet weak var middleValueLabel: UILabel!
    @IBOutlet weak var trailingTitleLabel: UILabel!
    @IBOutlet weak var trailingValueLabel: UILabel!
    
    @IBOutlet var containerStackViews: [UIStackView]!
    
    var clickCallback: ((_ index: Int) -> Void)?
    var isSelfUser = false
    
    override func layoutSubviews() {
        super.layoutSubviews();
        
        applyStyles();
        setupClickActions();
        let edgeInsets = UIEdgeInsets(top: 0, left: contentView.layoutMargins.left, bottom: 0, right: contentView.layoutMargins.right);
        contentView.frame.inset(by: edgeInsets);
    }
    
    func applyStyles() {
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.05);
        leadingValueLabel.font = UIFont.appHeavy.withSize(UIFont.sizes.small);
        middleValueLabel.font = UIFont.appHeavy.withSize(UIFont.sizes.small);
        trailingValueLabel.font = UIFont.appHeavy.withSize(UIFont.sizes.small);
    }
    
    func set(numOfYourPeople: Int, numOfCities: Int, numOfCountries: Int) {
        setupLabels();
        leadingTitleLabel.text = isSelfUser ? L10n.Common.titleYourPeople : L10n.Common.titleTheirPeople
        leadingValueLabel.text = String(numOfYourPeople);
        middleTitleLabel.text = L10n.AboutMeStatsTableViewCell.middleTitleLabel
        middleValueLabel.text = String(numOfCities);
        trailingTitleLabel.text = L10n.AboutMeStatsTableViewCell.trailingTitleLabel
        trailingValueLabel.text = String(numOfCountries);
    }
    
    private func setupLabels() {
        let titleTextColor = UIColor.lightGray;
        leadingTitleLabel.textColor = titleTextColor;
        middleTitleLabel.textColor = titleTextColor;
        trailingTitleLabel.textColor = titleTextColor;
        
        let valueTextColor = ColorName.accent.color
        leadingValueLabel.textColor = valueTextColor;
        middleValueLabel.textColor = valueTextColor;
        trailingValueLabel.textColor = valueTextColor;
    }
    
    private func setupClickActions() {
        containerStackViews.forEach { (stackView) in
            stackView.isUserInteractionEnabled = true;
            stackView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(tapHandler(tapGesture:))));
        }
    }
    
    @objc func tapHandler(tapGesture: UITapGestureRecognizer) {
        if let index = containerStackViews.firstIndex(of: tapGesture.view! as! UIStackView) {
        clickCallback?(index);
        }
    }
}
