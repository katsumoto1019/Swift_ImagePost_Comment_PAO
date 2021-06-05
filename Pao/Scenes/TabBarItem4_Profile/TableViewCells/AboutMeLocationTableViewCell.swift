//
//  AboutMeLocationTableViewCell.swift
//  Pao
//
//  Created by Exelia Technologies on 05/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class AboutMeLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var hometownTitleLabel: UILabel!
    @IBOutlet weak var currentlyTitleLabel: UILabel!
    @IBOutlet weak var nextStopTitleLabel: UILabel!
    
    @IBOutlet weak var hometownLabel: UILabel!
    @IBOutlet weak var currentlyLabel: UILabel!
    @IBOutlet weak var nextStopLabel: UILabel!
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var containerViews: [UIView]!
    @IBOutlet var separatorViews: [UIView]!
    
    @IBOutlet weak var deleteHomeTown: UIButton!
    @IBOutlet weak var deleteCurrentlyButton: UIButton!
    @IBOutlet weak var deleteNextStopButton: UIButton!
    
    
    @IBOutlet weak var deleteButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var deleteCurrentButtonWidthConstriant: NSLayoutConstraint!
    @IBOutlet weak var deleteNextStopButtonWidthConstriant: NSLayoutConstraint!
    
    
    var delegate: AboutMeLocationTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hometownTitleLabel.text = L10n.AboutMeLocationTableViewCell.hometownTitleLabel
        currentlyTitleLabel.text = L10n.AboutMeLocationTableViewCell.currentlyTitleLabel
        nextStopTitleLabel.text = L10n.AboutMeLocationTableViewCell.nextStopTitleLabel
        
        //applyStyle()
        setupLocation(label: hometownLabel)
        setupLocation(label: currentlyLabel)
        setupLocation(label: nextStopLabel)
        
        setupTitleLables(label: hometownTitleLabel)
        setupTitleLables(label: currentlyTitleLabel)
        setupTitleLables(label: nextStopTitleLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let edgeInsets = UIEdgeInsets(top: 0, left: contentView.layoutMargins.left, bottom: 0, right: contentView.layoutMargins.right)
        contentView.frame.inset(by: edgeInsets)
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
    }
    
    func setupTitleLables(label: UILabel)
    {
        label.textColor = UIColor.lightGray
    }
    
    func applyStyle() {
        hometownLabel.set(fontSize: UIFont.sizes.small)
        currentlyLabel.set(fontSize: UIFont.sizes.small)
        nextStopLabel.set(fontSize: UIFont.sizes.small)
    }
    
    private func setupLocation(label: UILabel) {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(showGooglePlacesController(gesture:)))
        label.addGestureRecognizer(tapGestureRecognizer)
        label.isUserInteractionEnabled = true
        
        label.textColor = UIColor.white
    }
    
    func set(hometown: String?, currently: String?, nextStop: String?,isCurrentuser : Bool = true) {
        setLocationText(label: hometownLabel, location: hometown)
        setLocationText(label: currentlyLabel, location: currently)
        setLocationText(label: nextStopLabel, location: nextStop)
        
        if !isCurrentuser{
            deleteHomeTown.isHidden = true
            deleteCurrentlyButton.isHidden = true
            deleteNextStopButton.isHidden = true
            
            deleteButtonWidthConstraint.constant = 0
            deleteCurrentButtonWidthConstriant.constant = 0
            deleteNextStopButtonWidthConstriant.constant = 0
        }
        
        if !isCurrentuser, containerViews.count == 3 {
            if (!isValidText(nextStop) || !isValidText(currently)) && separatorViews.count > 1 {
                separatorViews[1].isHidden = true
            }
            
            if (!isValidText(hometown) || (!isValidText(nextStop) && !isValidText(currently))) {
                separatorViews[0].isHidden = true
            }
            
            if !isValidText(nextStop) {
                let view = containerViews[2]
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            if !isValidText(currently) {
                let view = containerViews[1]
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            if !isValidText(hometown) {
                let view = containerViews[0]
                stackView.removeArrangedSubview(view)
                view.removeFromSuperview()
            }
            
            if let tableView = superview as? UITableView {
                UIView.setAnimationsEnabled(false)
                tableView.beginUpdates()
                tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            }
        }
    }
    
    private func setLocationText(label: UILabel, location: String?) {
        //        let text = "\(location?.city ?? "") \(location?.country ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
        if let text = location, text.count > 0 {
            label.attributedText = createAttributedText(title: "", value: text)
        }else{
            label.attributedText = createAttributedText(title: L10n.AboutMeLocationTableViewCell.LocationText.title, value: L10n.AboutMeLocationTableViewCell.LocationText.value)
        }
    }
    
    private func createAttributedText(title: String, value: String) -> NSMutableAttributedString {
        let text = String(format: "%@ %@", title, value)
        let titleRange = (text as NSString).range(of: title)
        
        let attributedText = NSMutableAttributedString(string: text)
        attributedText.setAttributes([.foregroundColor: UIColor.white], range: titleRange)
        return attributedText
    }
    
    @objc func showGooglePlacesController(gesture: UIGestureRecognizer) {
        switch(gesture.view){
        case hometownLabel:
            delegate?.aboutMeLocationCell(self, showGooglePlaceforLocation: .hometown)
        case currentlyLabel:
            delegate?.aboutMeLocationCell(self, showGooglePlaceforLocation: .currently)
        case nextStopLabel:
            delegate?.aboutMeLocationCell(self, showGooglePlaceforLocation: .next)
        default:
            break
        }
    }
    
    @IBAction func RemoveLocation(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            delegate?.deleteLocation(self, deleteLocationfor: .hometown)
            setLocationText(label: hometownLabel, location: nil)
        case 2:
            delegate?.deleteLocation(self, deleteLocationfor: .currently)
            setLocationText(label: currentlyLabel, location: nil)
        case 3:
            delegate?.deleteLocation(self, deleteLocationfor: .next)
            setLocationText(label: nextStopLabel, location: nil)
        default:
            break
        }
    }
}

extension AboutMeLocationTableViewCell {
    func isValidText(_ text: String?) -> Bool {  return (text != nil && !text!.isEmpty) }
}

protocol AboutMeLocationTableViewCellDelegate {
    func aboutMeLocationCell(_ cell: AboutMeLocationTableViewCell, showGooglePlaceforLocation locationType: AboutMeLocationType)
    func deleteLocation(_ cell: AboutMeLocationTableViewCell, deleteLocationfor locationType: AboutMeLocationType)
}
