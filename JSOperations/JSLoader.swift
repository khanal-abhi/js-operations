//
//  JSLoader.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import Foundation

class JSLoader {
    
    var delegate: JSLoaderDelegate?
    
    /// Use URLSession to load raw data from the url
    /// - Parameter fromURLString: url string to load the raw data from
    func loadBundle(fromURLString: String) {
        guard let url = URL(string: fromURLString) else {
            return
        }
        let urlRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringCacheData)
                
        let sessionTask = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, err) in
            DispatchQueue.main.async {
                self.delegate?.didComplete(urlRequest: urlRequest, withData: data, response: urlResponse, andError: err)
            }
        }
        
        sessionTask.resume()
    }
}

/// A protocol that allows JSLoader to delagate handling of the URLSessionDataTask callback
protocol JSLoaderDelegate {
    func didComplete(urlRequest: URLRequest?, withData data: Data?, response: URLResponse?, andError error: Error?)
}
