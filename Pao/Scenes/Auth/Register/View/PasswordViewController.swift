//
//  PasswordViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/8/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase


class PasswordViewController: BaseViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet private var passwordTextField: IsaoTextField!
    @IBOutlet private var confirmPasswordTextField: IsaoTextField!
    @IBOutlet private var privacyTextView: UITextView!
    @IBOutlet private var goButton: UIButton!
    
    // MARK: - Private properties
    
    private var taskGroup: DispatchGroup?
    
    private var email: String!
    private var fullName: String!
    private var username: String!
    
    // MARK: - Lifecycle
    
    init(email: String, fullName: String, username: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.email = email
        self.fullName = fullName
        self.username = username
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenName = "Join Pao"
        title = L10n.Common.joinPao
        
        styleViews()
        setupInputs()
        
        DispatchQueue.main.async {
            self.passwordTextField.beginEditting()
        }
        DispatchQueue.global(qos: .background).async {
            gSpots = OnBoardingViewController.readSpots()
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func signUp(_ sender: Any) {
        self.view.endEditing(true)
        register()
    }
    
    // MARK: - Private methods
    
    private func passwordErrorMessage(password: String?) -> String? {
        let errorMessage = L10n.PasswordViewController.errorPassword
        guard password != nil else {
            return errorMessage
        }
        
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d!$%@#£€*?&]{8,}$"
        let regexExpression = try! NSRegularExpression(pattern: passwordRegex, options: .caseInsensitive)
        guard regexExpression.firstMatch(in: password!, options: [], range: NSRange(location: 0, length: password!.count)) != nil else {
            return errorMessage
        }
        return nil
    }
    
    private func styleViews() {
        privacyTextView.isEditable = false
        privacyTextView.isScrollEnabled = false
        privacyTextView.isUserInteractionEnabled = true
        privacyTextView.isSelectable = true
        
        goButton.setTitle(L10n.PasswordViewController.goButton, for: .normal)
        goButton.tintColor = ColorName.accent.color
        //goButton.titleLabel?.font = UIFont.app
        
        goButton.isEnabled = false
    }
    
    private func setupInputs() {
        setup(textField: passwordTextField, placeholder: L10n.PasswordViewController.password, nextTextField: confirmPasswordTextField)
        setup(textField: confirmPasswordTextField, placeholder: L10n.PasswordViewController.confirmPassword, nextTextField: nil)
        setupPrivacyLink()
    }
    
    private func setup(textField: IsaoTextField, placeholder: String, nextTextField: IsaoTextField?) {
        textField.attributedPlaceholder =
            NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray, .font: UIFont.app])
        textField.autocorrectionType = .no
        textField.nextTextField = nextTextField
        //        textField.endEdittingCallback = { textField in _ = }
        textField.textChangedCallback = textChangedCallbacl(textField:)
        textField.returnKeyPressed = { textField in
            if textField == self.confirmPasswordTextField {
                self.register()
                return false
            }
            return true
        }
    }
    
    private func textChangedCallbacl(textField: IsaoTextField) {
        self.validateInput(textField: textField)
        self.updateGoButtonState()
    }
    
    @discardableResult
    private func validateInput(textField: IsaoTextField, setErrorMessage: Bool = true) -> Bool {
        if setErrorMessage {
            passwordTextField.error  = passwordErrorMessage(password: passwordTextField.text)
        }
        
        if textField == passwordTextField {
            return textField.error == nil
        }
        
        guard textField.text == passwordTextField.text else {
            if setErrorMessage {
                textField.error = L10n.PasswordViewController.errorPasswordNotMatch
            }
            return false
        }
        return true
    }
    
    private func updateGoButtonState() {
        goButton.isEnabled = validateInput(textField: passwordTextField,setErrorMessage: false) && validateInput(textField: confirmPasswordTextField, setErrorMessage: false)
    }
}

//TextView delegate
extension PasswordViewController: UITextViewDelegate {
    private func setupPrivacyLink() {
        let str = L10n.PasswordViewController.agree
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        
        let attributedString = NSMutableAttributedString(
            string: str,
            attributes: [
                .paragraphStyle: paragraph,
                .font: UIFont.app.withSize(9),
                .foregroundColor: UIColor.white.withAlphaComponent(0.7)
            ]
        )
        attributedString.setAsLink(textToFind: L10n.PasswordViewController.privacyPolicy, linkURL:"policy")
        
        privacyTextView.delegate = self
        privacyTextView.attributedText = attributedString
        privacyTextView.linkTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .underlineColor: UIColor.white.withAlphaComponent(0.7),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if textView == privacyTextView {
            if let link = Foundation.URL(string: "https://www.thepaoapp.com/privacy-and-policy/") {
                UIApplication.shared.open(link, options: [:], completionHandler: nil)
                return false
            }
            
            /*let viewController = PrivacyPolicyViewController()
             viewController.modalPresentationStyle = .fullScreen
             present(viewController, animated: true, completion: nil)*/
        }
        return false
    }
}

extension PasswordViewController {
    private func register() {
        if validateInput(textField: passwordTextField) && validateInput(textField: confirmPasswordTextField) {
            navigationItem.leftBarButtonItem?.isEnabled = false
            goButton.isEnabled = false
            
            let account = Account(email: email, password: passwordTextField.text, username: username, name: fullName)
            
            App.transporter.post(account, returnType: AccountResponse.self) { (result) in
                guard let result = result, let token = result.token else {
                    self.showMessagePrompt(message: L10n.PasswordViewController.MessagePrompt.message)
                    self.navigationItem.leftBarButtonItem?.isEnabled = true
                    self.updateGoButtonState()
                    return
                }
                
                Auth.auth().signIn(withCustomToken: token, completion: { (authResult, error) in                    
                    //Topups should be shown again
                    UserDefaults.reset()
                    
                    self.showOnBoardScreen()
                })
            }
        }
    }
    
    private func showOnBoardScreen() {
        AmplitudeAnalytics.logEvent(.successfulLogin, group: .onBoarding)
        gSlide1 = OnBoardingViewController(index: 0)
        _ = gSlide1?.view
        gSlide2 = OnBoardingViewController(index: 1)
        gSlide2?.spots = gSpots ?? []
        _ = gSlide2?.view
        gSlide3 = OnBoardingViewController(index: 2)
        _ = gSlide3?.view
        let viewController = OnboardingPageViewController()
        viewController.modalTransitionStyle = .flipHorizontal
        
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let rootViewController = window.rootViewController else {
            return
        }
        
        viewController.view.frame = rootViewController.view.frame
        viewController.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionFlipFromRight, animations: {
            window.rootViewController = viewController
        }, completion: { completed in })
    }
}
