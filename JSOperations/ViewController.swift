//
//  ViewController.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    
    let jsBundlePath = "https://jumboassetsv1.blob.core.windows.net/publicfiles/interview_bundle.js"
    let jumboMessageIdentifier = "jumbo"
    let jsonDecoder = JSONDecoder()
    private let jsLoader = JSLoader()
    
    @IBOutlet var wkWebView: WKWebView!
    private var jsLoaded: Bool?
    private var wkConnectionEstablished: Bool?
    private var setupfailureHandled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startLoadingJSBundle()
        configureWKWebViewForIO()
    }
    
    /// Create a IO cgannel with the WKWebView
    private func configureWKWebViewForIO() {
        wkWebView.configuration.userContentController.add(
            self, name: jumboMessageIdentifier)
    }
    
    /// Follow the JSLoaderDelagate protocol and set self as the JSLoaderDelegate
    private func startLoadingJSBundle() {
        jsLoader.delegate = self
        jsLoader.loadBundle(fromURLString: jsBundlePath)
    }
    
    /// Call the "startOperation" function within the wkwebview's js context
    /// - Parameter id: id of the operation to be started
    func callStartOperation(withId id: String) {
        wkWebView.evaluateJavaScript("startOperation(\(id));") { (res, err) in
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
            callStartOperation(withId: "\(i)")
        }
    }
    
    func presentAlertModal(withTitle title: String?, message: String?, andPrefferedStyle style: UIAlertController.Style) {
        let alertModal = UIAlertController(title: title, message: message, preferredStyle: style)
        alertModal.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            alertModal.dismiss(animated: true)
        }))
        present(alertModal, animated: true)
    }
    
    func handle(jumboMessage: JumboMessage) {
        print("I am updating \(jumboMessage.id)")
    }
}

