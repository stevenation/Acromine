//
//  Networking.swift
//  AcronymTests
//
//  Created by Thabiso Setefane on 2/10/22.
//

@testable import Acronym
import XCTest
class URLSessionProtocolTests: XCTestCase {
    var session: URLSession!
    var url: URL!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        session = URLSession(configuration: .default)
        url = URL(string: "http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=nasa")!
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        session = nil
        url = nil
        try super.tearDownWithError()
    }

    func testURLSessionTaskConformsToURLSessionTaskProtocol() {
        let task = session.dataTask(with: url)
        XCTAssertTrue((task as AnyObject) is URLSessionTaskProtocol)
    }

    func testURLSessionConformsToURLSessionProtocol() {
        XCTAssertTrue((session as AnyObject) is URLSessionProtocol)
    }

    func testURLSessionMakeDataTaskCreatesTaskWithPassedInURL() {
        let task = session.makeDataTask(
            with: url,
            completionHandler: { _, _, _ in })
            as! URLSessionTask
        XCTAssertEqual(task.originalRequest?.url, url)
    }

    func testURLSessionMakeDataTaskCreatesTaskWithPassedInCompletion() {
        let expectation =
            expectation(description: "Completion should be called")
        let task = session.makeDataTask(
            with: url,
            completionHandler: { _, _, _ in expectation.fulfill() })
            as! URLSessionTask
        task.cancel()
        waitForExpectations(timeout: 0.2, handler: nil)
    }
}
