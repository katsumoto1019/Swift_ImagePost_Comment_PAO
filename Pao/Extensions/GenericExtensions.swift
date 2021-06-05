//
//  GenericExtensions.swift
//  Pao
//
//  Created by Exelia Technologies on 25/07/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

func lock<T>(_ obj: T,_ execute: () -> ()) {
    objc_sync_enter(obj);
    execute();
    objc_sync_exit(obj);
}

extension UIDevice {
    static var hasNotch: Bool {
        if #available(iOS 11.0, *) {
           return UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        }
        return false
   }
}

extension DispatchQueue {

    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}
