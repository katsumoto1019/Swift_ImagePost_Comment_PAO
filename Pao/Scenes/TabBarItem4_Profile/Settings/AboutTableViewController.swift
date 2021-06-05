//
//  AboutTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 07/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class AboutTableViewController: StyledTableViewController {
    
    // MARK: - Private properties
    
    private let titles = ["\(L10n.AboutTableViewController.labelVersion) " + Bundle.main.version, L10n.AboutTableViewController.labelTermsAndConditions, L10n.AboutTableViewController.labelPrivacyPolicy]
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Settings About"
        
        tableView.register(LabelTableViewCell.self)
        tableView.separatorColor = .clear
        tableView.contentInset.top = 24
        tableView.rowHeight = 56
    }
    
    override func viewDidAppear(_ animated: Bool) {
        title = L10n.AboutTableViewController.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        title = ""
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.isTranslucent = true
        }
        super.willMove(toParent: parent)
    }
    
    // MARK: - UITableViewDataSource implementation
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row < 5 ? LabelTableViewCell.reuseIdentifier : LogoutTableViewCell.reuseIdentifier, for: indexPath)
        
        if let labelCell = cell as? LabelTableViewCell {
            labelCell.set(title: titles[indexPath.row])
            
            if indexPath.row > 0 {
                labelCell.underline()
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate implementation
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var url: URL!
        switch indexPath.row {
        case 1:
            guard let terms = URL(string: "https://www.thepaoapp.com/terms-and-conditions/") else { return }
            url = terms
        case 2:
            guard let privacy = URL(string: "https://www.thepaoapp.com/privacy-and-policy/") else { return }
            url = privacy
        default:
            return assertionFailure("Invalid item selected")
        }
        UIApplication.shared.open(url)
    }
}
