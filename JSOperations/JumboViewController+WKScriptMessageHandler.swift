//
//  JumboViewController+WKScriptMessageHandler.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import WebKit

extension JumboViewController: WKScriptMessageHandler {
    
    /// Handle the evaluation of js string on the wkwebview
    /// - Parameter jsString: raw javascript string
    func handle(jsString: String) {
        wkWebView.evaluateJavaScript(jsString) { (message, err) in
            if let err = err {
                self._jumboService?.didFailToEstablishWKConnection()
                self.presentAlertModal(withTitle: "Error", message: err.localizedDescription, andPrefferedStyle: .alert)
            } else if let _ = message {
                // message was non-nil
                self._jumboService?.didEstablishWKConnection()
            } else {
                // message was nil
                self._jumboService?.didEstablishWKConnection()
            }
        }
    }
    
    /// Entry point for the messages sent by the wkwebview
    /// - Parameters:
    ///   - userContentController: that belongs to the configured wkwebview
    ///   - message: sent by the wkwebview js context
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let jumboMessage = _jumboService?.parse(message: message) {
            handle(jumboMessage: jumboMessage)
        }
    }
}
