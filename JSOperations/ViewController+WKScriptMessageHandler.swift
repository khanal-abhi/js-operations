//
//  ViewController+Delegate.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import WebKit

extension ViewController: WKScriptMessageHandler {
    
    func handle(jsString: String) {
        wkWebView.evaluateJavaScript(jsString) { (message, err) in
            if let err = err {
                self.didFailToEstablishWKConnection()
                self.presentAlertModal(withTitle: "Error", message: err.localizedDescription, andPrefferedStyle: .alert)
            } else if let _ = message {
                // message was non-nil
                self.didEstablishWKConnection()
            } else {
                // message was nil
                self.didEstablishWKConnection()
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(message.name)
        print(message.body)
    }
}
