//
//  JSLoader.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import Foundation

class JSLoader {
    
    private var _delegate: JSLoaderDelegate?
//    private var _urlRequest: URLRequest?
    
    public var delegate: JSLoaderDelegate? {
        set (newDelagate) {
            _delegate = newDelagate
        }
        get {
            return _delegate
        }
    }
    
    func loadBundle(fromURLString: String) {
        guard let url = URL(string: fromURLString) else {
            return
        }
        let urlRequest = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringCacheData)
        
//        _urlRequest = urlRequest
        
        let sessionTask = URLSession.shared.dataTask(with: urlRequest) { (data, urlResponse, err) in
            DispatchQueue.main.async {
                self.delegate?.didComplete(urlRequest: urlRequest, withData: data, response: urlResponse, andError: err)
            }
        }
        
        sessionTask.resume()
    }
}

protocol JSLoaderDelegate {
    func didComplete(urlRequest: URLRequest?, withData data: Data?, response: URLResponse?, andError error: Error?)
}
