//
//  ViewControllerTests.swift
//  UnitTestNetworkingTests
//
//  Created by ZEUS on 1/7/24.
//

import XCTest
@testable import UnitTestNetworking

final class ViewControllerTests: XCTestCase {

    func test_tappingButton_shouldMakeDataTaskToSearchForEBookOutFromBoneVille(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let sut: ViewController = storyboard.instantiateViewController(identifier: String(describing: ViewController.self))
        let mockURLSession = MockURLSession()
        sut.session = mockURLSession
        sut.loadViewIfNeeded()
        
        tap(sut.button)
        
        XCTAssertEqual(mockURLSession.dataTaskCallCount, 1, "call count")
        
        XCTAssertEqual(
            mockURLSession.dataTaskArgsRequest.first,
            URLRequest(url: URL(string: "https://itunes.apple.com/search?" +
                           "media=ebook&term=out%20from%20boneville")!), "request")
        
    }
    
}
