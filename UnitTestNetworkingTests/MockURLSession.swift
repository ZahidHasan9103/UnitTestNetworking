//
//  MockURLSession.swift
//  UnitTestNetworkingTests
//
//  Created by ZEUS on 1/7/24.
//

import Foundation
@testable import UnitTestNetworking

class MockURLSession: UrlSessionProtocol{
    var dataTaskCallCount = 0
    var dataTaskArgsRequest: [URLRequest] = []
    
    func dataTask(with request: URLRequest, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(request)
        return URLSessionDataTask()
    }
    
    
}
