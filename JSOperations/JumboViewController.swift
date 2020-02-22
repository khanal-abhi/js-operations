//
//  JumboViewController.swift
//  JSOperations
//
//  Created by Abhinash Khanal on 2/21/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import UIKit
import WebKit

class JumboViewController: UIViewController {
    
    @IBOutlet var wkWebView: WKWebView!
    @IBOutlet var abProgressView1: ABProgressView!
    @IBOutlet var abProgressView2: ABProgressView!
    @IBOutlet var abProgressView3: ABProgressView!
    @IBOutlet var abProgressView4: ABProgressView!
    @IBOutlet var abProgressView5: ABProgressView!
    
    @IBOutlet var stackView: UIStackView!
    
    private var _progressViews: [String: ABProgressView] = [:]

    var _jumboService: JumboService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navigationItem.title = "JS Operations"
        _jumboService = JumboService(withDelegate: self)
        _jumboService?.parentViewController = self
        _jumboService?.startLoadingJSBundle()
        _jumboService?.configure(wkWebView: wkWebView, withScripMessageHandler: self)
    }
    
    func presentAlertModal(withTitle title: String?, message: String?, andPrefferedStyle style: UIAlertController.Style) {
        let alertModal = UIAlertController(title: title, message: message, preferredStyle: style)
        alertModal.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
            alertModal.dismiss(animated: true)
        }))
        present(alertModal, animated: true)
    }
    
    /// Handle the jumbo message returned by the wkWebView
    /// - Parameter jumboMessage: decoded message
    func handle(jumboMessage: JumboMessage) {
        var progressView: ABProgressView?
        switch jumboMessage.id {
        case "1":
            progressView = abProgressView1
        case "2":
            progressView = abProgressView2
        case "3":
            progressView = abProgressView3
        case "4":
            progressView = abProgressView4
        case "5":
            progressView = abProgressView5
        default:
            break
        }
        progressView?.isHidden = false
        progressView?.bind(toJumboMessage: jumboMessage)
    }
}

