//
//  PaoTransporter.swift
//  Pao
//
//  Created by Parveen Khatkar on 07/02/19.
//  Copyright © 2019 Exelia. All rights reserved.
//

import Foundation


class PaoTransporter: Transporter {
    
    override init() {
        super.init();
    }
    
    override func handleResponse<T>(forRequest request: URLRequest, data: Data?, response: URLResponse?, error: Error?, completionHandler: @escaping (T?) -> Void) where T: Decodable {
        
        if error != nil {
            #if DEBUG
            print("\n\n\n");
            print("url:", request.url!.absoluteString, "\nerror:", error?.localizedDescription ?? "");
               #endif
            DispatchQueue.main.sync {
                completionHandler(false as? T);
            }
            return;
        }
        
        super.handleResponse(forRequest: request, data: data, response: response, error: error, completionHandler: completionHandler);
    }
    
    var token: String? {
        return headers["Authorization"]
    }
    
    var isTokenThere: Bool {
        guard let token = token else { return false }
        return !token.isEmpty
    }
}
