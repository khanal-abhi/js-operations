//
//  JumboService.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/22/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import Foundation
import WebKit

class JumboService: JSLoaderDelegate {
    
    static let jumboMessageIdentifier = "jumbo"
    static let jsonDecoder = JSONDecoder()
    static let jsBundlePath = "https://jumboassetsv1.blob.core.windows.net/publicfiles/interview_bundle.js"
    
    /// Parse the raw message from wkwebview to JumboMessage if valid
    /// - Parameter message: passed in by the wkwebview
    static func parse(message: WKScriptMessage) -> JumboMessage? {
        if message.name == jumboMessageIdentifier,
            let jsonString = message.body as? String,
            let jsonData = jsonString.data(using: .utf8) {
            do {
                let jumboMessage = try jsonDecoder.decode(JumboMessage.self, from: jsonData)
                return jumboMessage
            } catch (let e) {
                print(e)
            }
        }
        return nil
    }
    
    private var jsLoaded: Bool?
    private var wkConnectionEstablished: Bool?
    private var setupfailureHandled = false
    private weak var wkWebView: WKWebView?
    public weak var jumboControllerDelegate: JumboViewControllerProtocol?
    
    init() { }
    
    /// Follow the JSLoaderDelagate protocol and set self as the JSLoaderDelegate
    func startLoadingJSBundle() {
        JSLoader.loadBundle(fromURLString: JumboService.jsBundlePath, delegate: self)
    }
    
    /// Create a IO channel with the WKWebView
    func configure(wkWebView: WKWebView,
                   withScripMessageHandler handler: WKScriptMessageHandler) {
        self.wkWebView = wkWebView
        wkWebView.configuration.userContentController.add(
            handler, name: JumboService.jumboMessageIdentifier)
    }
    
    /// Call the "startOperation" function within the wkwebview's js context
    /// - Parameter id: id of the operation to be started
    func callStartOperation(withId id: String) {
        wkWebView?.evaluateJavaScript("startOperation(\(id));") { (res, err) in
            if let err = err {
                print(err)
            } else if let res = res {
                print(res)
            }
        }
    }
    
    /// Handle success case for js loading
    func didLoadJS() {
        jsLoaded = true
        if isSetupDone() && !didSetupFail() {
            beginCallsToStartOperation()
        }
    }
    
    /// Handle failure case for js loading
    func didFailToLoadJS() {
        jsLoaded = false
    }
    
    /// Handle success case for wkconnection binding
    func didEstablishWKConnection() {
        wkConnectionEstablished = true
        if isSetupDone() && !didSetupFail() {
            beginCallsToStartOperation()
        }
    }
    
    /// Handle failure case for wkconnection binding
    func didFailToEstablishWKConnection() {
        wkConnectionEstablished = false
    }
    
    /// Are both jsLoaded and wkConnectionEstablished values loaded
    func isSetupDone() -> Bool {
        return jsLoaded != nil && wkConnectionEstablished != nil
    }
    
    /// Is the setup done and either jsLoaded or wkConnectionEstablished is false
    func didSetupFail() -> Bool {
        jsLoaded ?? true == false || wkConnectionEstablished ?? true == false
    }
    
    /// Make five startOperations calls with ids = "1" .. "5"
    func beginCallsToStartOperation() {
        for i in 1...6 {
            let id = "\(i)"
            callStartOperation(withId: id)
            jumboControllerDelegate?.handle(jumboMessage: JumboMessage(id: i, message: "progress"))
        }
    }
    
    /// Handle the result of URLRequest and propagates it to the parent view controller
    /// - Parameters:
    ///   - urlRequest: for the network call
    ///   - data: returned by the response
    ///   - response: proper response object
    ///   - error: encountered during the network call
    func didComplete(urlRequest: URLRequest?, withData data: Data?, response: URLResponse?, andError error: Error?) {
        if let _ = error {
            didFailToLoadJS()
            jumboControllerDelegate?.presentAlertModal(withTitle: "Error", message: "Unable to load the JS bundle.", andPrefferedStyle: .alert)
        } else if let data = data {
            didLoadJS()
            if let jsString = String(data: data, encoding: .utf8) {
                handle(jsString: jsString)
            } else {
                jumboControllerDelegate?.presentAlertModal(withTitle: "Error", message: "Unable to parse data using utf-8 encoding",
                                  andPrefferedStyle: .alert)
            }
        } else {
            didLoadJS()
        }
    }
    
    /// Handle the evaluation of js string on the wkwebview
    /// - Parameter jsString: raw javascript string
    func handle(jsString: String) {
        wkWebView?.evaluateJavaScript(jsString) { (message, err) in
            if let err = err {
                self.didFailToEstablishWKConnection()
                self.jumboControllerDelegate?.presentAlertModal(withTitle: "Error", message: err.localizedDescription, andPrefferedStyle: .alert)
            } else if let _ = message {
                // message was non-nil
                self.didEstablishWKConnection()
            } else {
                // message was nil
                self.didEstablishWKConnection()
            }
        }
    }
}
