//
//  ViewControllerTests.swift
//  UnitTestNetworkingTests
//
//  Created by ZEUS on 1/7/24.
//

import XCTest
import ViewControllerPresentationSpy
@testable import UnitTestNetworking

final class ViewControllerTests: XCTestCase {
    private var sut: ViewController!
    private var mockURLSession: MockURLSession!
    private var alertVerifier: AlertVerifier!
    
    @MainActor override func setUp() {
        super.setUp()
        alertVerifier = AlertVerifier()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        sut = storyboard.instantiateViewController(identifier: String(describing: ViewController.self))
        mockURLSession = MockURLSession()
        sut.session = mockURLSession
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        alertVerifier = nil
        sut = nil
        mockURLSession = nil
        super.tearDown()
    }
    
    func test_tappingButton_shouldMakeDataTaskToSearchForEBookOutFromBoneVille(){
        tap(sut.button)
        mockURLSession.verifyDataTask(with: URLRequest(url: URL(string: "https://itunes.apple.com/search?" + "media=ebook&term=out%20from%20boneville")!))
        
    }
    
    func test_searchBookNetworkCall_withSuccessResponse_shouldSaveDataInResults(){
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
        tap(sut.button)
        
        mockURLSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 200), nil)
        
        XCTAssertEqual(sut.results, [])
    }
    
    @MainActor func test_searchBookNetworkCall_withError_shouldShowAlert(){
        tap(sut.button)
        let alertShown = expectation(description: "alert shown")
        alertVerifier.testCompletion = {
            alertShown.fulfill()
        }
        
        mockURLSession.dataTaskArgsCompletionHandler.first?(nil,nil, TestError(message: "oh no"))
        waitForExpectations(timeout: 0.01)
        verifyErrorAlert(message: "oh no")
    }
    
    @MainActor func test_searchBookNetworkCall_withErrorPreAsync_shouldNotShowAlert(){
        tap(sut.button)
        
        mockURLSession.dataTaskArgsCompletionHandler.first?(nil,nil, TestError(message: "oh no"))
        XCTAssertEqual(alertVerifier.presentedCount, 0)
    }
    
    @MainActor func test_searchNetworkCall_withMalformedResponse_shouldShowAlert(){
        tap(sut.button)
        let alertShown = expectation(description: "alert shown")
        alertVerifier.testCompletion = {
            alertShown.fulfill()
        }
        
        mockURLSession.dataTaskArgsCompletionHandler.first?(malformedJsonData(), response(statusCode: 200), nil)
        waitForExpectations(timeout: 0.01)
        verifyErrorAlert(message: "The data couldn’t be read because it is missing.")
    }
    
    @MainActor func test_searchNetworkCall_withMalformedResponseBeforeAsync_shouldNotShowAlert(){
        tap(sut.button)
        
        mockURLSession.dataTaskArgsCompletionHandler.first?(malformedJsonData(), response(statusCode: 200), nil)
        
        XCTAssertEqual(alertVerifier.presentedCount, 0)
    }
    
    @MainActor func test_searchNetworkCall_withResponse500_shouldShowAlert(){
        tap(sut.button)
        let alertShown = expectation(description: "alert shown")
        alertVerifier.testCompletion = {
            alertShown.fulfill()
        }
        
        mockURLSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 500), nil)
        waitForExpectations(timeout: 0.01)
        verifyErrorAlert(message: "Response: internal server error")
    }
    
    @MainActor func test_searchNetworkCall_withResponse500BeforeAsync_shouldNotShowAlert(){
        tap(sut.button)
        
        mockURLSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 500), nil)
        XCTAssertEqual(alertVerifier.presentedCount, 0)

    }
    
    //MARK: - Button
    func test_buttonShouldBeEnabledInitially(){
        XCTAssertTrue(sut.button.isEnabled)
    }
    
    func test_buttonShouldBeDisabled(){
        tap(sut.button)
        XCTAssertFalse(sut.button.isEnabled)
    }
    
    func test_searchNetworkCall_withResponse_shouldReEnableButton(){
        tap(sut.button)
        let handleResultCalled = expectation(description: "handle result called")
        sut.handleResults = {_ in
            handleResultCalled.fulfill()
        }
        
        mockURLSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 200), nil)
        waitForExpectations(timeout: 0.01)
        XCTAssertTrue(sut.button.isEnabled)
    }
    
    func test_searchNetworkCall_withResponseBeforeAsync_shouldNotReEnableButton(){
        tap(sut.button)
        mockURLSession.dataTaskArgsCompletionHandler.first?(jsonData(), response(statusCode: 200), nil)
        XCTAssertFalse(sut.button.isEnabled)
    }
    
    @MainActor func verifyErrorAlert(
        message: String,
        file: StaticString = #file,
        line: UInt = #line){
            alertVerifier.verify(
                title: "Network Problem",
                message: message,
                animated: true,
                actions: [
                    .default("OK")
                ],
            presentingViewController: sut,
                file: file,
                line: line
            )
            XCTAssertEqual(alertVerifier.preferredAction?.title, "OK", "preferred action", file: file, line: line)
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

private func malformedJsonData() -> Data {
 """
    {
        "results": [
          {
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
