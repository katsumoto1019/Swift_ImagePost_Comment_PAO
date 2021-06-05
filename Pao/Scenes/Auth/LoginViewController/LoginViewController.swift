//
//  LoginViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/6/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: BaseViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet private var emailTextField: IsaoTextField!
    @IBOutlet private var passwordTextField: IsaoTextField!
    @IBOutlet private var loginButton: GradientButton!
    @IBOutlet private var forgotPasswordButton: RoundCornerButton!
    
    // MARK: - Internal properties
    
    var listener: AuthStateDidChangeListenerHandle!
    
    // MARK: - Private properties
    
    private var noUserError = L10n.LoginViewController.noUserError
    private let messagePrompt = L10n.LoginViewController.messagePrompt
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenName = "Login"
        title = L10n.LoginViewController.title
        
        styleViews()
        setupInputs()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        emailTextField.beginEditting()
    }
    
    // MARK: - UITextFieldDelegate implementation
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
            return true
        } else {
            view.endEditing(true)
            return false
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func login() {
        
        bfprint("-= SOS =- login")
        
        if validateInput(textField: emailTextField), validateInput(textField: passwordTextField) {
            
            navigationItem.leftBarButtonItem?.isEnabled = false
            loginButton.isEnabled = false
            view.endEditing(true)
            
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { [weak self] (user, error) in
                guard let self = self else { return }
                
                self.navigationItem.leftBarButtonItem?.isEnabled = true
                self.loginButton.isEnabled = true
                
                if let errorMessage = error?.localizedDescription {
                    if errorMessage == self.noUserError {
                        self.showMessagePrompt(message: self.messagePrompt, title: L10n.LoginViewController.MessagePrompt.title, customized: true)
                    } else {
                        self.showMessagePrompt(message: errorMessage, customized: true)
                    }
                    return
                }
                
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                
                self.setupUserDefaults()
                UserDefaults.save(value: true, forKey: UserDefaultsKey.isSignedIn.rawValue)
                UserDefaults.save(value: false, forKey: UserDefaultsKey.isNewUser.rawValue)
                let viewController = NetworkViewController()
                appDelegate.window?.rootViewController = viewController
            }
        }
    }
    
    @IBAction private func showForgotPasswordViewController(_ sender: Any) {
        let viewController = ForgotPasswordViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Private methods
    
    private func styleViews() {
        //loginButton.backgroundColor = .accent
        loginButton.setGradient(
            topGradientColor: ColorName.gradientTop.color,
            bottomGradientColor: ColorName.gradientBottom.color
        )
        loginButton.setTitle(L10n.LoginViewController.loginButton, for: .normal)
        loginButton.setTitleColor(ColorName.background.color, for: .normal)
        loginButton.titleLabel?.font = UIFont.app.withSize(UIFont.sizes.small)
        loginButton.layer.opacity = 0.82
        
        forgotPasswordButton.setTitle(L10n.LoginViewController.forgotPasswordButton, for: .normal)
        forgotPasswordButton.tintColor = .white
        forgotPasswordButton.titleLabel?.font = UIFont.app.withSize(UIFont.sizes.verySmall)
    }
    
    private func setupInputs() {
        setup(textField: emailTextField, placeholder: L10n.LoginViewController.emailPlaceholder, nextTextField: passwordTextField)
        setup(textField: passwordTextField, placeholder: L10n.LoginViewController.passwordPlaceholder, nextTextField: nil)
    }
    
    private func setup(textField: IsaoTextField, placeholder: String, nextTextField: IsaoTextField?) {
        textField.attributedPlaceholder =
            NSAttributedString(
                string: placeholder,
                attributes: [.foregroundColor: UIColor.lightGray,
                             .font: UIFont.app]
        )
        textField.autocorrectionType = .no
        textField.nextTextField = nextTextField
        textField.endEdittingCallback = { textField in _ = self.validateInput(textField: textField)}
        textField.returnKeyPressed = { textField in
            if textField == self.passwordTextField {
                self.login()
                return false
            }
            return true
        }
    }
    
    private func validateInput(textField: IsaoTextField, setErrorMessage: Bool = true) -> Bool {
        
        var errorMessage: String?
        
        if let text = textField.text, !text.trim.isEmpty {
            if textField == emailTextField {
                errorMessage = text.isValidEmail ? nil : L10n.LoginViewController.errorEmail
            }
        } else {
            errorMessage = L10n.LoginViewController.errorCantBeEmpty
        }
        
        if setErrorMessage {
            textField.error = errorMessage
        }
        return errorMessage == nil
    }
    
    private func setupUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(Date().timeIntervalSince1970, forKey: UserDefaultsKey.lastPeopleNotificationDate.rawValue)
        defaults.set(Date().timeIntervalSince1970, forKey: UserDefaultsKey.lastLocationNotificationDate.rawValue)
        let keys = UserDefaultsKey.doneTutorialSpotKeys
        keys.forEach { defaults.set(true, forKey: $0.rawValue) }
        
        UserDefaults.save(value: true, forKey: UserDefaultsKey.shouldShowPermission.rawValue)
    }
}
