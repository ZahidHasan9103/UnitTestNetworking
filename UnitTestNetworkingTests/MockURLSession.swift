//
//  MockURLSession.swift
//  UnitTestNetworkingTests
//
//  Created by ZEUS on 1/7/24.
//

import Foundation
import XCTest
@testable import UnitTestNetworking

private class DummyURLSessionDataTask: URLSessionDataTask {
    override func resume() {}
}

class MockURLSession: UrlSessionProtocol{
    var dataTaskCallCount = 0
    var dataTaskArgsRequest: [URLRequest] = []
    var dataTaskArgsCompletionHandler: [(Data?, URLResponse?, Error?) -> Void] = []
    
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(request)
        dataTaskArgsCompletionHandler.append(completionHandler)
        return DummyURLSessionDataTask()
    }
    
    func verifyDataTask(with request: URLRequest,
                        file: StaticString = #file,
                        line: UInt = #line){
        
        guard dataTaskWasCalledOnce(file: file, line: line) else {return}
        XCTAssertEqual(dataTaskArgsRequest.first, request, "request", file: file, line: line)
    }
    
    private func dataTaskWasCalledOnce(
        file: StaticString = #file,
        line: UInt = #line) -> Bool{
            verifyMethodCalledOnce(
                methodName: "dataTask(with:completionHandler",
                callCount: dataTaskCallCount,
                describeArguments: "request: \(dataTaskArgsRequest)")
        }
}


