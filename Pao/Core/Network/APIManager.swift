//
//  APIManager.swift
//  Pao
//
//  Created by Pavan Gandhi on 05/03/21.
//  Copyright © 2021 Exelia. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

extension Encodable {
    func toJSONData() -> Data? { try? JSONEncoder().encode(self) }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}

class APIManager: NSObject {
    
    static var jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dataDecodingStrategy = .deferredToData
        jsonDecoder.dateDecodingStrategy = .millisecondsSince1970
        return jsonDecoder
    }()
    
    class func callAPIForWebServiceOperation<T: Decodable>(model : Codable, urlPath : URL, methodType : NSString, successPart : @escaping (Bool, T?, AnyObject?, Int) -> Void) -> DataRequest? {
        
        let headers :  HTTPHeaders = ["Authorization": App.transporter.headers["Authorization"] ?? ""]
        var httpMethodType : HTTPMethod = .get
        let KAPPDELEGATE = UIApplication.shared.delegate as? AppDelegate
        var paramDict = [String:Any]()
        
        if(NetworkReachabilityManager()?.isReachable ?? false){
            
            //Network connectivity dialog
            KAPPDELEGATE?.reachabilityService?.startNotifier()
            
            if (methodType.isEqual(to: "GET"))
            {
                httpMethodType = .get
            }
            else if (methodType.isEqual(to: "POST"))
            {
                httpMethodType = .post
            }
            else if (methodType.isEqual(to: "PUT"))
            {
                httpMethodType = .put
            }
            else if (methodType.isEqual(to: "DELETE"))
            {
                httpMethodType = .delete
            }
            
            paramDict = self.convertToDictionary(text: String(data: model.toJSONData() ?? Data(), encoding: .utf8) ?? "") ?? [:]
            
            return AF.request(urlPath, method: httpMethodType, parameters: paramDict, encoding: URLEncoding.default, headers: headers).validate(statusCode: 200..<206).responseJSON { response in
                switch response.result {
                case .success:
                    do {
                        if let data = response.data, let obj: T = try? true as? T ?? self.jsonDecoder.decode(T.self, from: data) {
                            successPart(true, obj, nil, response.response?.statusCode ?? 0)
                        } else {
                            let jsonData = try JSONSerialization.jsonObject(with: response.data ?? Data(), options: JSONSerialization.ReadingOptions.mutableContainers)
                            successPart(true, nil, jsonData as AnyObject, response.response?.statusCode ?? 0)
                        }
                    } catch let jsonErr {
                        print("APIManager: Failed to decode json:- ", jsonErr)
                        successPart(false, nil, nil, response.response?.statusCode ?? 0)
                    }
                    break
                    
                case .failure:
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: response.data ?? Data(), options: JSONSerialization.ReadingOptions.mutableContainers)
                        successPart(false, nil, jsonData as AnyObject, response.response?.statusCode ?? 0)
                    } catch let jsonErr {
                        print("APIManager: Failed to decode json:- ", jsonErr)
                        successPart(false, nil, nil, response.response?.statusCode ?? 0)
                    }
                    break                    
                }
            }
        }else{
            //Network connectivity dialog
            KAPPDELEGATE?.reachabilityService?.stopNotifier()
            //print("Its seems your internet connection appears to be offline. Please try again.")
        }
        return nil
    }
    
    class func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}


