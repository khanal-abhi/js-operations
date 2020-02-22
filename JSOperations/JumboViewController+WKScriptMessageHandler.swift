//
//  JumboViewController+WKScriptMessageHandler.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import WebKit

extension JumboViewController: WKScriptMessageHandler {
    
    /// Entry point for the messages sent by the wkwebview
    /// - Parameters:
    ///   - userContentController: that belongs to the configured wkwebview
    ///   - message: sent by the wkwebview js context
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let jumboMessage = JumboService.parse(message: message) {
            handle(jumboMessage: jumboMessage)
        }
    }
}
