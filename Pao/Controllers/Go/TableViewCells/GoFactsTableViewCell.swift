//
//  GoFactsTableViewCell.swift
//  Pao
//
//  Created by Waseem Ahmed on 03/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class GoFactsTableViewCell: GoBaseTableViewCell {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var titleAddressLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var titleTimeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weekDaysArrowButton: UIButton!

    
    private var placeDetails: PlaceDetailsResult?
    
    private var weekTitleLabel: UILabel?
    private var weekHoursLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        styleLabels();
        self.contentView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap(tapGesture:))));
        
        weekDaysArrowButton.isUserInteractionEnabled = false;
         weekDaysArrowButton.isHidden = true;
    }
    
    func styleLabels() {
        titleAddressLabel.font =  UIFont.appNormal.withSize(UIFont.sizes.small - 1);
        titleAddressLabel.textColor = ColorName.accent.color
        
        addressLabel.font = UIFont.app.withSize(UIFont.sizes.small - 1);
        addressLabel.textColor = UIColor.white;
        
        titleTimeLabel.font =  UIFont.appNormal.withSize(UIFont.sizes.small - 1);
        titleTimeLabel.textColor = ColorName.accent.color;
    
        timeLabel.font = UIFont.appNormal.withSize(UIFont.sizes.small - 1);

    }
    
    override func set(spot: Spot, placeDetails: PlaceDetailsResult?) {
        self.placeDetails = placeDetails;
        
        titleAddressLabel.text = L10n.GoFactsTableViewCell.address;
        titleTimeLabel.text = L10n.GoFactsTableViewCell.hours

        switch placeDetails?.businessStatus {
        case .closedPermanently:
            timeLabel.text = L10n.GoFactsTableViewCell.permanentlyClosed
            timeLabel.textColor = ColorName.redText.color
        case .closeTemporarily:
            timeLabel.text = L10n.GoFactsTableViewCell.temporarilyClosed
            timeLabel.textColor = ColorName.redText.color
        default:
            var openNowStatus = L10n.GoFactsTableViewCell.unknown;
            if let openNow = placeDetails?.openingHours?.openNow {
                openNowStatus = (openNow) ? L10n.GoFactsTableViewCell.open : L10n.GoFactsTableViewCell.closed
                if let openHours =  placeDetails?.openingHours?.todayOpenHours() {
                    openNowStatus = "\(L10n.GoFactsTableViewCell.hoursToday) \(openHours)"
                }
                showWeekHours(show: weekDaysArrowButton.isSelected)
                self.contentView.isUserInteractionEnabled = true
                weekDaysArrowButton.isHidden = false
            }

            timeLabel.text = openNowStatus
        }

        addressLabel.text =  "N/A";
        if let address = placeDetails?.formattedAddress?.removeExtraCommas() {
            var mutableAddress = address;
            if let lastIndex = address.lastIndex(of: ",") {
                mutableAddress = address[..<lastIndex] + "\n" + address[address.index(after: lastIndex)...].trimmingCharacters(in: .whitespacesAndNewlines);
            }
            
            if let value = spot.location?.postalCode {
                mutableAddress += "\n" + value;
            }
            addressLabel.text =  mutableAddress;
        }
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        weekDaysArrowButton.isSelected = !weekDaysArrowButton.isSelected;
        showWeekHours(show:  weekDaysArrowButton.isSelected);
        resizeCellToFitContent();
    }
    
    private func showWeekHours(show: Bool) {
        if let titleLabel = weekTitleLabel, let hoursLabel = weekHoursLabel {
            stackView.removeArrangedSubview(titleLabel);
            stackView.removeArrangedSubview(hoursLabel);
            titleLabel.removeFromSuperview();
            hoursLabel.removeFromSuperview();
        }
        
        if show, let weekDays = placeDetails?.openingHours?.weekdayText {
            var weekDayText = String();
            weekDays.forEach({
                weekDayText +=  "\($0) \n";
            })
            weekTitleLabel = getTitleLabel(text: L10n.GoFactsTableViewCell.week);
            weekHoursLabel = getDetailsLabel(text: weekDayText);
            
            stackView.addArrangedSubview(weekTitleLabel!);
            stackView.addArrangedSubview(weekHoursLabel!);
        }
    }
}


extension GoFactsTableViewCell {
    private func getTitleLabel(text: String) -> UILabel {
        let label = UILabel();
        label.font =  UIFont.appNormal.withSize(UIFont.sizes.small - 1);
        label.textColor = ColorName.accent.color
        label.text = text;
        return label;
    }
    
    private func getDetailsLabel(text: String) -> UILabel {
        let label = UILabel();
        label.font = UIFont.app.withSize(UIFont.sizes.small - 1);
        label.textColor = UIColor.white;
        label.numberOfLines = 0;
        label.text = text;
        return label;
    }
    
    func resizeCellToFitContent(){
            if let tableView = superview as? UITableView {
                UIView.setAnimationsEnabled(false) // Disable animations
                tableView.beginUpdates()
                tableView.endUpdates()
                UIView.setAnimationsEnabled(true)  // Re-enable animations.
            }
    }
}
