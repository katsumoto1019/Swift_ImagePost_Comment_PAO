//
//  EmailContactService.swift
//  Pao
//
//  Created by Parveen Khatkar on 17/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import MessageUI

class EmailContactService: NSObject, MFMailComposeViewControllerDelegate {
    
    // MARK: - Internal properties
    
    weak var viewController: UIViewController?
    
    // MARK: - Lifecycle
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    // MARK: - Internal methods
    
    func showOptions() {
        let message = L10n.EmailContactService.message
        let categoryAlert = UIAlertController(title: L10n.EmailContactService.categoryAlertTitle, message: message, preferredStyle: .actionSheet)
        
        categoryAlert.addAction(createUIAlertAction(category: .question))
        categoryAlert.addAction(createUIAlertAction(category: .problem))
        categoryAlert.addAction(createUIAlertAction(category: .suggestion))
        categoryAlert.addAction(createUIAlertAction(category: .other))
        categoryAlert.addAction(
            UIAlertAction(title: L10n.Common.cancel, style: .cancel, handler: { action in
                categoryAlert.dismiss(animated: true)
            })
        )
        
        viewController?.present(categoryAlert, animated: true)
    }
    
    func composeEmail(subject: String) {
        let canSendMail = MFMailComposeViewController.canSendMail()
        let canSendText = MFMessageComposeViewController.canSendText()
        let canSendSubject = MFMessageComposeViewController.canSendSubject()
        
        if canSendMail && canSendText && canSendSubject {
            let mail = MFMailComposeViewController()
            
            mail.mailComposeDelegate = self
            // TODO: Set this to the correct poa support desk email address
            mail.setToRecipients(["anna@thepaoapp.com"])
            // FIXME: This doesn't set the subject when run
            mail.setSubject(subject)
            // TODO: Get template text to set
            mail.setMessageBody("This is an example message body", isHTML: false)
            
            FirbaseAnalytics.trackScreen(name: .contact)
            
            viewController?.present(mail, animated: true)
        } else {
            var message = "\(L10n.EmailContactService.ComposeEmail.message):\n"
            
            if !canSendMail {
                message += "\n-\(L10n.EmailContactService.ComposeEmail.canSendMail)"
            }
            if !canSendText {
                message += "\n-\(L10n.EmailContactService.ComposeEmail.canSendText)"
            }
            if !canSendSubject {
                message += "\n-\(L10n.EmailContactService.ComposeEmail.canSendSubject)"
            }
            
            let deviceSetupAlert = UIAlertController(title: L10n.EmailContactService.ComposeEmail.deviceSetup, message: message, preferredStyle: .alert)
            
            deviceSetupAlert.addAction(UIAlertAction(title: L10n.Common.gotIt, style: .default, handler: { action in
                deviceSetupAlert.dismiss(animated: true)
            }))
            
            viewController?.present(deviceSetupAlert, animated: true)
        }
    }
    
    // MARK: - MFMailComposeViewControllerDelegate implementation
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true)
    }
    
    // MARK: - Private methods
    
    private func createUIAlertAction(category: ContactCategory) -> UIAlertAction {
        let title = category.rawValue
        
        return UIAlertAction(title: title, style: .default, handler: { action in
            guard let title = action.title else { return }
            FirbaseAnalytics.logEvent(.contactEmail, parameters: ["title": title])
            AmplitudeAnalytics.logEvent(.contactEmail, group: .settings)
            self.composeEmail(subject: title)
        })
    }
}
