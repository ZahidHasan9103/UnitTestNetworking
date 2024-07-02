//
//  TestError.swift
//  UnitTestNetworkingTests
//
//  Created by ZEUS on 2/7/24.
//

import Foundation

struct TestError: LocalizedError{
    let message: String
    var errorDescription: String? { message }
}
