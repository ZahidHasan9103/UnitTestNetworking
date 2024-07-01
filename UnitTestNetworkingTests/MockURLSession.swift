//
//  MockURLSession.swift
//  UnitTestNetworkingTests
//
//  Created by ZEUS on 1/7/24.
//

import Foundation
import XCTest
@testable import UnitTestNetworking

class MockURLSession: UrlSessionProtocol{
    var dataTaskCallCount = 0
    var dataTaskArgsRequest: [URLRequest] = []
    
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(request)
        return DummyURLSessionDataTask()
    }
    
    func verifyDataTask(with request: URLRequest,
                        file: StaticString = #file,
                        line: UInt = #line){
        XCTAssertEqual(dataTaskCallCount, 1, "call out", file: file, line: line)
        XCTAssertEqual(dataTaskArgsRequest.first, request, "request", file: file, line: line)
    }
}

private class DummyURLSessionDataTask: URLSessionDataTask {
    override func resume() {}
}
