//
//  AccountTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 16/04/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Firebase

class AccountTableViewController: StyledTableViewController {

    private let titles = [L10n.SettingsTableViewController.optionAccount.lowercased()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
         screenName = "Account Settings"
        
        tableView.register(AccountsTableViewCell.self)
        tableView.separatorColor = .clear
        tableView.contentInset.top = 24
    }

    override func viewDidAppear(_ animated: Bool) {
        self.title = L10n.SettingsTableViewController.optionAccount
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.title = ""
    }
   
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row < 5 ? AccountsTableViewCell.reuseIdentifier : LogoutTableViewCell.reuseIdentifier, for: indexPath)
        
        if let labelCell = cell as? AccountsTableViewCell {
            labelCell.set(type: titles[indexPath.row])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            FirbaseAnalytics.logEvent(.deleteAccount)
            
            let alertController = UIAlertController(title: nil, message: L10n.AccountTableViewController.labelEnterPassword, preferredStyle: .alert)
           
            alertController.addTextField { (textField) in
                textField.placeholder = L10n.AccountTableViewController.placeholder
                textField.textColor = UIColor.darkText
                textField.isSecureTextEntry = true
            }
            
            alertController.addAction(UIAlertAction(title: L10n.Common.delete, style: .default, handler: { (action) in
                let password = alertController.textFields![0].text ?? ""
                let credential = EmailAuthProvider.credential(withEmail: DataContext.cache.user.email ?? "", password: password)
                Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error) in
                    guard error == nil else {
                        self.showMessagePrompt(message: L10n.AccountTableViewController.MessagePrompt.message)
                        return
                    }
                    
                    self.deleteConfirmation()
                })
            }))
            
            alertController.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: { (action) in
            }))
            
            present(alertController, animated: true)
            
            break
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func deleteConfirmation() {
        let alertController = UIAlertController(title: nil, message: L10n.AccountTableViewController.deleteConfirmation, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: L10n.Common.yes, style: .destructive, handler: { (action) in
            self.deleteAccount()
        }))
        
        present(alertController, animated: true)
    }
    
    func deleteAccount() {
        App.transporter.delete(User.self) { (success) in
            if success == true {
                do {
                    AmplitudeAnalytics.logEvent(.deleteAccount, group: .settings)
                    Messaging.messaging().unsubscribe(fromTopic: Auth.auth().currentUser?.uid ?? "")
                    //Messaging.messaging().unsubscribe(fromTopic: PNTopics.playlistUpdate.rawValue) // no need to unsub (not user specific) [EG]
                    //Messaging.messaging().unsubscribe(fromTopic: PNTopics.forceUpdate.rawValue) // no need to unsub (not user specific) [EG]
                    try Auth.auth().signOut()
                    AmplitudeAnalytics.logOut()
                    AppDelegate.startAccountFlow()
                }
                catch {
                    print("Error signing out")
                }
            }
            else {
                self.showMessagePrompt(message: L10n.AccountTableViewController.deleteAccountError)
            }
        }
    }
}
