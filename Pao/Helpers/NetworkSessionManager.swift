//
//  NetworkSessionManager.swift
//  Pao
//
//  Created by Ericos Georgiades on 02/12/2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import Foundation

// NetworkSessionManager Example
// from https://developer.apple.com/forums/thread/127191
// (now deprecated as it seems to have caused issues, maybe took too long in background)
// (now, isUpdateNeeded is flagged and viewWillAppear and willEnterForeground trigger the refresh when flagged)

protocol NetworkDisplay: class {
    func updateUI(response: URLResponse?, error: Error?, location:URL?)
}

class NetworkSessionManager: NSObject {
    
    private var urlSession: URLSession?
    private var downloadRequest: URLSessionDownloadTask?
    private weak var delegate: NetworkDisplay?
    
    init(withBackgroundSession: String, delegate: NetworkDisplay) {
        super.init()
        let config = URLSessionConfiguration.background(withIdentifier: withBackgroundSession)
        config.isDiscretionary = true
        config.sessionSendsLaunchEvents = true
        config.allowsCellularAccess = true
        self.delegate = delegate
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }
    
    init(delegate: NetworkDisplay) {
        super.init()
        let config = URLSessionConfiguration.default
        config.allowsCellularAccess = true
        self.delegate = delegate
        urlSession = URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }
    
    func downloadWithFile(with request: URLRequest?) -> URLSessionDownloadTask? {
        guard let request = request,
            let unwrappedURLSession = urlSession else { return nil }
        downloadRequest = unwrappedURLSession.downloadTask(with: request)
        downloadRequest?.resume()
        return downloadRequest;
    }
}


extension NetworkSessionManager: URLSessionDownloadDelegate, URLSessionDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        delegate?.updateUI(response: downloadTask.response, error: nil, location: location)
        
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print ("*** server error")
            return
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        let progress = (totalBytesWritten / totalBytesExpectedToWrite)
        print("*** progress: \(progress)")
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let error = error {
            delegate?.updateUI(response: nil, error: error, location: nil)
        }
    }
}
