//
//  ViewController+JSLoaderDelegate.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import Foundation

extension ViewController: JSLoaderDelegate {
    
    /// The loading of raw data from a url string has been completed
    /// - Parameters:
    ///   - urlRequest: created by the JSLoader
    ///   - data: returned by the response
    ///   - response: to the url request
    ///   - error: encountered trying to make the reuqest
    func didComplete(urlRequest: URLRequest?, withData data: Data?, response: URLResponse?, andError error: Error?) {
        if let _ = error {
            didFailToLoadJS()
            presentAlertModal(withTitle: "Error", message: "Unable to load the JS bundle.", andPrefferedStyle: .alert)
        } else if let data = data {
            didLoadJS()
            if let jsString = String(data: data, encoding: .utf8) {
                handle(jsString: jsString)
            } else {
                presentAlertModal(withTitle: "Error", message: "Unable to parse data using utf-8 encoding",
                                  andPrefferedStyle: .alert)
            }
        } else {
            didLoadJS()
        }
    }
}
