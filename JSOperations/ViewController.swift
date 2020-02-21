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
    private let jsLoader = JSLoader()
    
    @IBOutlet var wkWebView: WKWebView!
    var urlRequest: URLRequest!
    var jsLoaded: Bool?
    var wkConnectionEstablished: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        startLoadingJSBundle()
        configureWKWebViewForIO()
    }
    
    private func configureWKWebViewForIO() {
        wkWebView.configuration.userContentController.add(
            self, name: jumboMessageIdentifier)
    }
    
    private func startLoadingJSBundle() {
        jsLoader.delegate = self
        jsLoader.loadBundle(fromURLString: jsBundlePath)
    }
    
    func callJSOperation(withId id: String) {
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
        testForSetupFailure()
    }
    
    func didFailToLoadJS() {
        jsLoaded = false
        testForSetupFailure()
    }
    
    func didEstablishWKConnection() {
        wkConnectionEstablished = true
        testForSetupFailure()
    }
    
    func didFailToEstablishWKConnection() {
        wkConnectionEstablished = false
        testForSetupFailure()
    }
    
    func isSetupDone() -> Bool {
        return jsLoaded != nil && wkConnectionEstablished != nil
    }
    
    func didSetupFail() -> Bool {
        jsLoaded ?? true == false || wkConnectionEstablished ?? true == false
    }
    
    func testForSetupFailure() {
        if isSetupDone() {
            if didSetupFail() {
                presentAlertModal(withTitle: "Error", message: "Setup Failed",
                                  andPrefferedStyle: .alert)
            } else {
//                presentAlertModal(withTitle: "Success", message: "Setup Successful",
//                                  andPrefferedStyle: .alert)
                callJSOperation(withId: "1")
            }
        }
    }
    
    func presentAlertModal(withTitle title: String?, message: String?, andPrefferedStyle style: UIAlertController.Style) {
        let alertModal = UIAlertController(title: title, message: message, preferredStyle: style)
        alertModal.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            alertModal.dismiss(animated: true)
        }))
        present(alertModal, animated: true)
    }
}

