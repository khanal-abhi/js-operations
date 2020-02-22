//
//  JumboServiceTests.swift
//  JSOperationsTests
//
//  Created by Abhinash Khanal on 2/22/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import XCTest
import WebKit

/// FakeWKScriptMessage that allows creating of fake messages for testing
class FakeWKScriptMessage: WKScriptMessage {
    
    let _name: String
    let _body: Any
    
    override var name: String {
        get {
            return _name
        }
    }
    
    override var body: Any {
        get {
            return _body
        }
    }
    
    init(name: String, body: Any) {
        _name = name
        _body = body
    }
}
/// MockJumboViewControllerDelegate that just passes through the delegate calls over to the respective callbacks
class MockJumboViewControllerDelegate: JumboViewControllerProtocol {
    
    var delegateCallBackForHandle: (JumboMessage) -> Void
    var delegateCallbackForPresentAlertModal: (String?, String?, UIAlertController.Style) -> Void
    
    init(delegateCallBackForHandle: @escaping (JumboMessage) -> Void,
         delegateCallbackForPresentAlertModal: @escaping (String?, String?,
        UIAlertController.Style) -> Void
    ) {
        self.delegateCallBackForHandle = delegateCallBackForHandle
        self.delegateCallbackForPresentAlertModal =
        delegateCallbackForPresentAlertModal
    }
    
    func presentAlertModal(withTitle title: String?, message: String?, andPrefferedStyle style: UIAlertController.Style) {
        delegateCallbackForPresentAlertModal(title, message, style)
    }
    
    func handle(jumboMessage: JumboMessage) {
        delegateCallBackForHandle(jumboMessage)
    }
}

/// MockWKWebView that overrides the js evaluation to always error out
class MockWKWebView: WKWebView {
    override func evaluateJavaScript(
        _ javaScriptString: String,
        completionHandler: ((Any?, Error?) -> Void)? = nil) {
        completionHandler?(nil, NSError(domain: "Mock Error", code: 400))
    }
}

/// MockWKScriptMessageHandler that just passes through the delegate call over to the callback
class MockWKScriptMessageHandler: NSObject, WKScriptMessageHandler {
    
    var handlerCallback: (WKScriptMessage) -> Void
    
    init(handlerCallback: @escaping (WKScriptMessage) -> Void) {
        self.handlerCallback = handlerCallback
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        handlerCallback(message)
    }
    
    
}

class JumboServiceTests: XCTestCase {
    
    var jumboService: JumboService?
    var mockJumboViewControllerDelegate: MockJumboViewControllerDelegate?
    var mockWKWebView: WKWebView?
    let jsonEncoder = JSONEncoder()
    
    let emptyJSON = "{}"
    let validMessageMinimal = JumboMessage(id: 1, message: "complete")
    let validMessageWithProgress = JumboMessage(id: 2, message: "complete", progress: 42)
    let validMessageWithProgressAndState = JumboMessage(id: 3, message: "complete", progress: 42, state: "successful")
    let invalidJSON = "{"
    let emptyString = ""

    override func setUp() {
        jumboService = JumboService()
    }

    override func tearDown() {
        mockJumboViewControllerDelegate = nil
        mockWKWebView = nil
        jumboService = nil
    }
    
    private func encode(message: JumboMessage) -> String? {
        guard let validJSONBody = try? jsonEncoder.encode(message),
            let validJSONString = String(data: validJSONBody, encoding: .utf8) else {
                return nil
        }
        return validJSONString
    }
    
    func testJumboServiceParsingShouldFailWhenInvalid() {
        let validNameEmptyJSON = FakeWKScriptMessage(
            name: JumboService.jumboMessageIdentifier,
            body: emptyJSON)
        if let _ = JumboService.parse(message: validNameEmptyJSON) {
            XCTFail()
        }
        
        let emptyNameEmptyJSON = FakeWKScriptMessage(
            name: emptyString,
            body: emptyJSON)
        if let _ = JumboService.parse(message: emptyNameEmptyJSON) {
            XCTFail()
        }
        
        guard let validJSONString = encode(message: validMessageMinimal) else {
            XCTFail()
            return
        }
        
        let emptyNameValidJSON = FakeWKScriptMessage(
            name: emptyString,
            body: validJSONString)
        if let _ = JumboService.parse(message: emptyNameValidJSON) {
            XCTFail()
        }
    }
    
    func testJumboServiceParsingShouldPassWhenValid() {
        guard let validJSONString1 = encode(message: validMessageMinimal) else {
            XCTFail()
            return
        }
        let validNameMinimalMessage = FakeWKScriptMessage(
            name: JumboService.jumboMessageIdentifier,
            body: validJSONString1)
        
        guard let _ = JumboService.parse(message: validNameMinimalMessage) else {
            XCTFail()
            return
        }
        
        guard let validJSONString2 = encode(message: validMessageWithProgress) else {
            XCTFail()
            return
        }
        
        let validNameMessageWithProgress = FakeWKScriptMessage(
            name: JumboService.jumboMessageIdentifier,
            body: validJSONString2)
        
        guard let _ = JumboService.parse(message: validNameMessageWithProgress) else {
            XCTFail()
            return
        }
        
        guard let validJSONString3 = encode(message: validMessageWithProgressAndState) else {
            XCTFail()
            return
        }
        
        let validNameMessageWithProgressAndState = FakeWKScriptMessage(
            name: JumboService.jumboMessageIdentifier,
            body: validJSONString3)
        
        guard let _ = JumboService.parse(message: validNameMessageWithProgressAndState) else {
            XCTFail()
            return
        }
    }
    
    func testConfigureWKWebView() {
        guard let validJSONString = encode(message: validMessageMinimal) else {
            XCTFail()
            return
        }
        
        mockJumboViewControllerDelegate =
            MockJumboViewControllerDelegate(
                delegateCallBackForHandle: { (_) in
                
            },
                delegateCallbackForPresentAlertModal: { (_, _, _) in
            })
        let mockWKWebView = MockWKWebView()
        self.mockWKWebView = mockWKWebView
        jumboService?.jumboControllerDelegate = mockJumboViewControllerDelegate
        let handler = MockWKScriptMessageHandler { (msg) in
            guard let str = msg.body as? String else {
                    XCTFail()
                    return
            }
            XCTAssert(str == validJSONString)
        }
        jumboService?.configure(wkWebView: mockWKWebView, withScripMessageHandler: handler)
        jumboService?.handle(jsString: validJSONString)
    }
    
    func testDelegateShouldFireHandleFunction() {
        guard let validJSONData = try? jsonEncoder.encode(validMessageMinimal) else {
            XCTFail()
            return
        }
        
        mockJumboViewControllerDelegate =
            MockJumboViewControllerDelegate(
                delegateCallBackForHandle: { (msg) in
                XCTAssert(true)
            },
                delegateCallbackForPresentAlertModal: { (_, _, _) in
            })
        jumboService?.jumboControllerDelegate = mockJumboViewControllerDelegate
        jumboService?.didComplete(
            urlRequest: nil,
            withData: validJSONData,
            response: nil,
            andError: nil)
    }
    
    func testDelegateShouldFirePresentAlertModalFunction() {
        mockJumboViewControllerDelegate =
            MockJumboViewControllerDelegate(
                delegateCallBackForHandle: { (_) in
                
            },
                delegateCallbackForPresentAlertModal: { (title, message, style) in
                    XCTAssert(title != nil)
                    XCTAssert(message != nil)
                    XCTAssert(style == .alert)
            })
        let mockWKWebView = MockWKWebView()
        self.mockWKWebView = mockWKWebView
        jumboService?.jumboControllerDelegate = mockJumboViewControllerDelegate
        let handler = MockWKScriptMessageHandler { (msg) in
            XCTFail()
        }
        jumboService?.configure(wkWebView: mockWKWebView, withScripMessageHandler: handler)
        jumboService?.handle(jsString: "")
    }

}
