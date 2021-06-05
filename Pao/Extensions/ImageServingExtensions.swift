//
//  ImageServingExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 31/05/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

extension URL {
    func imageServingUrl(withOption option: ImageServingOption, value: Any) -> URL {
        guard absoluteString.hasPrefix("http") && absoluteString.contains("googleusercontent.com") else {
            return self;
        }
        return URL(string: String(format: "%@=%@%@", self.absoluteString, option.rawValue, String(describing: value)))!
    }
    
    func imageServingUrl(withOptions options: [ImageServingOption: Any?]) -> URL {
         guard absoluteString.hasPrefix("http") && absoluteString.contains("googleusercontent.com") else {
            return self;
        }
        let optionString = options.sorted(by: {$0.key.rawValue < $1.key.rawValue}).map({
            String(format: "%@%@", $0.key.rawValue, $0.value != nil ? String(describing: $0.value!) : "")
        }).joined(separator: "-");
        return URL(string: String(format: "%@=%@", self.absoluteString, optionString))!
    }
    
    func imageServingUrl(cropSize: Int, quality: Int = 30) -> URL {
        return self.imageServingUrl(withOptions:
            [
                .s: cropSize,
                .c: nil,
                .l: quality
            ]);
    }
    
    func imageServingUrl(cropSize size: CGSize, quality: Int = 70) -> URL {
        return self.imageServingUrl(withOptions:
            [
                .h: Int(size.height),
                .w: Int(size.width),
                .c: nil,
                .l: quality
            ]);
    }
}

enum ImageServingOption: String {
    case s = "s"
    case h = "h"
    case w = "w"
    case c = "c"
    case l = "l"
}
