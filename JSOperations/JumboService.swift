//
//  JumboService.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/22/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import Foundation
import WebKit

class JumboService {
    
    let jsBundlePath = "https://jumboassetsv1.blob.core.windows.net/publicfiles/interview_bundle.js"
    let jumboMessageIdentifier = "jumbo"
    let jsonDecoder = JSONDecoder()
    private let jsLoader = JSLoader()
    
    private var jsLoaded: Bool?
    private var wkConnectionEstablished: Bool?
    private var setupfailureHandled = false
    public var delegate: JSLoaderDelegate?
    private weak var wkWebView: WKWebView?
    public weak var parentViewController: JumboViewController?
    
    /// Initialize JumboService with a delegate
    /// - Parameter delegate: for handling loading of js resources
    init(withDelegate delegate: JSLoaderDelegate) {
        self.delegate = delegate
    }
    
    /// Follow the JSLoaderDelagate protocol and set self as the JSLoaderDelegate
    func startLoadingJSBundle() {
        jsLoader.delegate = delegate
        jsLoader.loadBundle(fromURLString: jsBundlePath)
    }
    
    /// Create a IO channel with the WKWebView
    func configure(wkWebView: WKWebView,
                   withScripMessageHandler handler: WKScriptMessageHandler) {
        self.wkWebView = wkWebView
        wkWebView.configuration.userContentController.add(
            handler, name: jumboMessageIdentifier)
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
    
    func didLoadJS() {
        jsLoaded = true
        if isSetupDone() && !didSetupFail() {
            beginCallsToStartOperation()
        }
    }
    
    func didFailToLoadJS() {
        jsLoaded = false
    }
    
    func didEstablishWKConnection() {
        wkConnectionEstablished = true
        if isSetupDone() && !didSetupFail() {
            beginCallsToStartOperation()
        }
    }
    
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
    
    func beginCallsToStartOperation() {
        for i in 1...6 {
            let id = "\(i)"
            callStartOperation(withId: id)
            parentViewController?.handle(jumboMessage: JumboMessage(id: id, message: "progress"))
        }
    }
    
    func parse(message: WKScriptMessage) -> JumboMessage? {
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
}
