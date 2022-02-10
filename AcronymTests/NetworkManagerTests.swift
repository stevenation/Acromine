//
//  NetworkManagerTests.swift
//  AcronymTests
//
//  Created by Thabiso Setefane on 2/10/22.
//
@testable import Acronym
import XCTest

class NetworkManagerTests: XCTestCase {
    var baseURL: String!
    var mockSession: MockURLSession!
    var sut: NetworkManager!
    var getDataURL: URL {
        return URL(string: "http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=nasa")!
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        baseURL = "http://www.nactem.ac.uk/software/acromine/dictionary.py"
        mockSession = MockURLSession()
        sut = NetworkManager(baseURL: baseURL,
                             session: mockSession,
                             responseQueue: nil)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        baseURL = nil
        mockSession = nil
        sut = nil
        try super.tearDownWithError()
    }

    func whenGetdata(
        data: Data? = nil,
        statusCode: Int = 200,
        error: Error? = nil) ->
        (calledCompletion: Bool, data: [Results]?, error: Error?)
    {
        let response = HTTPURLResponse(url: getDataURL,
                                       statusCode: statusCode,
                                       httpVersion: nil,
                                       headerFields: nil)
          
        var calledCompletion = false
        var receiveddata: [Results]?
        var receivedError: Error?
          
        let mockTask = sut.fetchData("nasa") { data, error in
            calledCompletion = true
            receiveddata = data
            receivedError = error as NSError?
        } as! MockURLSessionTask
          
        mockTask.completionHandler(data, response, error)
        return (calledCompletion, receiveddata, receivedError)
    }
      
    func verifyGetdataDispatchedToMain(data: Data? = nil,
                                       statusCode: Int = 200,
                                       error: Error? = nil,
                                       line: UInt = #line)
    {
        mockSession.givenDispatchQueue()
        sut = NetworkManager(baseURL: baseURL,
                             session: mockSession,
                             responseQueue: .main)
        
        let expectation = self.expectation(
            description: "Completion wasn't called")
        
        var thread: Thread!
        let mockTask = sut.fetchData("nasa") { _, _ in
            thread = Thread.current
            expectation.fulfill()
        } as! MockURLSessionTask
        
        let response = HTTPURLResponse(url: getDataURL,
                                       statusCode: statusCode,
                                       httpVersion: nil,
                                       headerFields: nil)
        mockTask.completionHandler(data, response, error)
        waitForExpectations(timeout: 0.2) { _ in
            XCTAssertTrue(thread.isMainThread, line: line)
        }
    }
      
    func testConformsToResultsPatchService() {
        XCTAssertTrue((sut as AnyObject) is NetworkManager)
    }
      
    func testResultsPatchServiceDeclaresGetdata() {
        let service = sut as NetworkManager
        _ = service.fetchData("NASA") { _, _ in }
    }
      
    func testSharedSetsBaseURL() {
        let baseURL = URL(
            string: "http://www.nactem.ac.uk/software/acromine/dictionary.py")!
        let networkBaseURL = URL(string: NetworkManager.shared.baseURL)!
        XCTAssertEqual(networkBaseURL, baseURL)
    }
      
    func testSharedSetsSession() {
        XCTAssertTrue(
            NetworkManager.shared.session === URLSession.shared)
    }
      
    func testSharedSetsResponseQueue() {
        XCTAssertEqual(NetworkManager.shared.responseQueue, .main)
    }
      
    func testInitSetsBaseURL() {
        XCTAssertEqual(sut.baseURL, baseURL)
    }
      
    func testInitSetsSession() {
        XCTAssertTrue(sut.session === mockSession)
    }
      
    func testInitSetsResponseQueue() {
        let responseQueue = DispatchQueue.main
        sut = NetworkManager(baseURL: baseURL,
                             session: mockSession,
                             responseQueue: responseQueue)
        XCTAssertEqual(sut.responseQueue, responseQueue)
    }
      
    func testFechtDataCallsExpectedURL() {
        let mockTask = sut.fetchData("nasa") { _, _ in }
            as! MockURLSessionTask
        XCTAssertEqual(mockTask.url, getDataURL)
    }
      
    func testFetchDataCallsResumeOnTask() {
        let mockTask = sut.fetchData("nasa") { _, _ in }
            as! MockURLSessionTask
        XCTAssertTrue(mockTask.calledResume)
    }
      
    func testFetchDataGivenResponseStatusCode500CallsCompletion() {
        let result = whenGetdata(statusCode: 500)
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)
        XCTAssertNil(result.error)
    }
      
    func testFetchDatagivenErrorCallsCompletionWithError() throws {
        let expectedError = NSError(domain: "nactem.ac.uk",
                                    code: 42)
        let result = whenGetdata(error: expectedError)
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)

        let actualError = try XCTUnwrap(result.error as NSError?)
        XCTAssertEqual(actualError, expectedError)
    }
      
    func testFetchDataGivenValidJSONCallsCompletionWithdata() throws {
        let data =
            try Data.fromJSON(fileName: "GETResultsResponse")
          
        let decoder = JSONDecoder()
        let response = try decoder.decode([Results].self, from: data)

        let result = whenGetdata(data: data)
        XCTAssertTrue(result.calledCompletion)
        XCTAssertEqual(result.data, response)
        XCTAssertNil(result.error)
    }
      
    func testFetchDatagivenInvalidJSONCallsCompletionWithError()
        throws
    {
        let data = try Data.fromJSON(
            fileName: "GETResultsMissingValuesResponse")
        
        var expectedError: NSError!
        let decoder = JSONDecoder()
        do {
            _ = try decoder.decode([Results].self, from: data)
        } catch {
            expectedError = error as NSError
        }
        
        let result = whenGetdata(data: data)
        XCTAssertTrue(result.calledCompletion)
        XCTAssertNil(result.data)
        
        let actualError = try XCTUnwrap(result.error as NSError?)
        XCTAssertEqual(actualError.domain, expectedError.domain)
        XCTAssertEqual(actualError.code, expectedError.code)
    }
      
    func testFetchDataGivenHTTPStatusErrorDispatchesToResponseQueue() {
        verifyGetdataDispatchedToMain(statusCode: 500)
    }
      
    func testFetchDataGivenErrorDispatchesToResponseQueue() {
        let error = NSError(domain: "nactem.ac.uk", code: 42)
        verifyGetdataDispatchedToMain(error: error)
    }
      
    func testFetchDataGivenGoodResponseDispatchesToResponseQueue()
        throws
    {
        let data = try Data.fromJSON(
            fileName: "GETResultsResponse")
        verifyGetdataDispatchedToMain(data: data)
    }
      
    func testFetchDataGivenInvalidResponseDispatchesToResponseQueue()
        throws
    {
        let data = try Data.fromJSON(
            fileName: "GETResultsMissingValuesResponse")
        verifyGetdataDispatchedToMain(data: data)
    }
}
