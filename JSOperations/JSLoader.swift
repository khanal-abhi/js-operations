//
//  JSLoader.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import Foundation

class JSLoader {
    
    /// This is a static helper so disabling the constructor
    private init() {}
    
    /// Use URLSession to load raw data from the url
    /// - Parameter fromURLString: url string to load the raw data from
    /// - Parameter delegate: for the loading completion
    static func loadBundle(fromURLString: String, delegate: JSLoaderDelegate?) {
        guard let url = URL(string: fromURLString) else {
            return
        }
        let urlRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringCacheData)
                
        let sessionTask = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, err) in
            DispatchQueue.main.async {
                delegate?.didComplete(urlRequest: urlRequest, withData: data, response: urlResponse, andError: err)
            }
        }
        
        sessionTask.resume()
    }
}

/// A protocol that allows JSLoader to delagate handling of the URLSessionDataTask callback
protocol JSLoaderDelegate {
    func didComplete(urlRequest: URLRequest?, withData data: Data?, response: URLResponse?, andError error: Error?)
}
