//
//  ViewControllerTests.swift
//  UnitTestNetworkingTests
//
//  Created by ZEUS on 1/7/24.
//

import XCTest
@testable import UnitTestNetworking

final class ViewControllerTests: XCTestCase {
    
    var sut: ViewController!
    var mockURLSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: String(describing: ViewController.self))
        mockURLSession = MockURLSession()
        sut.session = mockURLSession
    }
    
    override func tearDown() {
        sut = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    func test_tappingButton_shouldMakeDataTaskToSearchForEBookOutFromBoneVille(){
        
        sut.loadViewIfNeeded()
        tap(sut.button)
        
        mockURLSession.verifyDataTask(with: URLRequest(url: URL(string: "https://itunes.apple.com/search?" + "media=ebook&term=out%20from%20boneville")!))
        
    }
    
    func test_searchBookNetworkCall_withSuccessResponse_shouldSaveDataInResults(){
        sut.loadViewIfNeeded()
        tap(sut.button)
        let handleResultsCall = expectation(description: "handleResults called")
        sut.handleResults = {_ in
            handleResultsCall.fulfill()
        }
        
        mockURLSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 200), nil)
        waitForExpectations(timeout: 0.01)
        
        XCTAssertEqual(sut.results, [SearchResult(artistName: "Artist", trackName: "Track", averageUserRating: 2.5, genres: ["Foo", "Bar"])])
        
    }
    
    func test_searchBookNetworkCall_withSuccessBeforeAsync_shouldNotSaveDataInResults(){
        sut.loadViewIfNeeded()
        tap(sut.button)
        
        mockURLSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 200), nil)
        
        XCTAssertEqual(sut.results, [])
    }
    
}

private func response(statusCode: Int) -> HTTPURLResponse?{
    HTTPURLResponse(
        url: URL(string: "http://dummy-url.com")!,
        statusCode: statusCode,
        httpVersion: nil,
        headerFields: nil)
}


private func jsonData() -> Data {
 """
    {
        "results": [
          {
            "artistName": "Artist",
            "trackName": "Track",
            "averageUserRating": 2.5,
            "genres": [
                        "Foo",
                        "Bar"
                      ]
                  }
              ]
        }
""".data(using: .utf8)!
}
