//
//  UIViewControllerExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/6/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

extension UIViewController {
    func showMessagePrompt(message: String, title: String = L10n.UIViewController.Alert.title, action: String = L10n.Common.gotIt, customized: Bool = false, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        
        let paoAlert = PaoAlertController(title: title, subTitle: message);
        paoAlert.addButton(title: action) {
            handler?(UIAlertAction())
        }
        paoAlert.show(parent: self);
    }
    
    func handleError(responseObject: NSDictionary, code : Int){
        if let message = responseObject["message"] as? String {
            self.showMessagePrompt(message: message, title: "Error!", customized: true)
        }else{
            if let statuscode = responseObject["code"] as? Int {
                let msgStr = self.getServerCode(statusCode: statuscode)
                self.showMessagePrompt(message: msgStr, title: "Error!", customized: true)
            }else{
                let msgStr = self.getServerCode(statusCode: code)
                self.showMessagePrompt(message: msgStr, title: "Error!", customized: true)
            }
        }
    }
    
    func getServerCode(statusCode : Int) -> String{
        var message : String = ""
        /*if(statusCode == 200){
            //OK
            message = "The request has succeeded."
        }else if(statusCode == 201){
            //Created
            message = "The request has been fulfilled and has resulted in one or more new resources being created."
        }*/
        if(statusCode == 400){
            //Bad Request
            message = "The server cannot or will not process the request due to something that is perceived to be a client error."
        }else if(statusCode == 401){
            //Unauthorized
            message = "The request has not been applied because it lacks valid authentication credentials for the target resource."
        }else if(statusCode == 403){
            //Forbidden
            message = "The server understood the request but refuses to authorize it."
        }else if(statusCode == 404){
            //Not Found
            message = "The origin server did not find a current representation for the target resource or is not willing to disclose that one exists."
        }else if(statusCode == 422){
            //Save or Update operation can not be performed
            message = "The request was well-formed but was unable to be followed due to semantic errors."
        }else if(statusCode == 500){
            //Internal Server Error
            message = "The server encountered an unexpected condition that prevented it from fulfilling the request."
        }else{
            //If not found any code
            message = "Something went wrong, Please try again later."
        }
        return message
    }
    
    /// - Mark :Keyboard PUSH
    
    class Keyboard {
        static var pushValue : CGFloat = 0
        static var originalHeightOfClient : CGFloat = 0
        
        static func reset(){
            Keyboard.pushValue  = 0
            Keyboard.originalHeightOfClient = 0
        }
    }
    
    func applyKeyboardPush(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowHandler(notification:)), name:  UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideHandler(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        Keyboard.reset()
    }
    
    @objc func keyboardWillShowHandler(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            if Keyboard.originalHeightOfClient <= 0 {
                Keyboard.originalHeightOfClient = self.view.frame.size.height;
                Keyboard.pushValue = keyboardSize.height
                
                //  Getting keyboard animation duration
                var _animationDuration = 0.25;
                if let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
                    
                    //Saving animation duration
                    if duration != 0.0 {
                        _animationDuration = duration
                    }
                }
                
                UIView.animate(withDuration: _animationDuration) {
                    //self.view.frame.size.height -= Keyboard.pushValue;
                    self.view.frame.size.height  = UIScreen.main.bounds.height -  self.view.frame.origin.y - Keyboard.pushValue ;
                }
            }
        }
    }
    
    @objc func keyboardWillHideHandler(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if Keyboard.originalHeightOfClient > 0 {
                //self.view.frame.size.height = Keyboard.originalHeightOfClient
                Keyboard.originalHeightOfClient = 0;
                self.view.frame.size.height  = UIScreen.main.bounds.height -  self.view.frame.origin.y ;
                
            }
        }
    }
    ///Keyboard push END
}
