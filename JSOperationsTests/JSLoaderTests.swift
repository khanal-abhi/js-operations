//
//  JSLoaderTests.swift
//  JSOperationsTests
//
//  Created by Abhinash Khanal on 2/22/20.
//  Copyright © 2020 abhinash.com. All rights reserved.
//

import XCTest

class MockJSLoaderDelegate: JSLoaderDelegate {
    
    var delegateCallbackHandler: (URLRequest?, Data?, URLResponse?, Error?) -> Void
    
    init(delegateCallbackHandler: @escaping (URLRequest?, Data?, URLResponse?, Error?) -> Void) {
        self.delegateCallbackHandler = delegateCallbackHandler
    }
    
    func didComplete(urlRequest: URLRequest?, withData data: Data?, response: URLResponse?, andError error: Error?) {
        delegateCallbackHandler(urlRequest, data, response, error)
    }
}

class JSLoaderTests: XCTestCase {
    
    var mockDelegate: MockJSLoaderDelegate?

    override func setUp() {
    }

    override func tearDown() {
        mockDelegate = nil
    }
    
    func testInvalidURLShouldFail() {
        mockDelegate = MockJSLoaderDelegate(delegateCallbackHandler: {
            (request, data, response, err) in
            XCTAssert(err != nil)
        })
        JSLoader.loadBundle(fromURLString: "", delegate: mockDelegate)
    }
    
    func testValidURLShouldResturnData() {
        mockDelegate = MockJSLoaderDelegate(delegateCallbackHandler: {
            (request, data, response, err) in
            XCTAssert(data != nil)
        })
        JSLoader.loadBundle(fromURLString: JumboService.jsBundlePath,
                            delegate: mockDelegate)
    }
    
    func testPerformanceValidURLShouldReturnData() {
        self.measure {
            mockDelegate = MockJSLoaderDelegate(delegateCallbackHandler: {
                (request, data, response, err) in
                XCTAssert(data != nil)
            })
            JSLoader.loadBundle(fromURLString: JumboService.jsBundlePath,
                                delegate: mockDelegate)
        }
    }

}
