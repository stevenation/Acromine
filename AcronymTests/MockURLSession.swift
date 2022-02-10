//
//  MockURLSession.swift
//  AcronymTests
//
//  Created by Thabiso Setefane on 2/10/22.
//

@testable import Acronym
import Foundation
class MockURLSession: URLSessionProtocol {
    var queue: DispatchQueue?
    func givenDispatchQueue() {
        queue = DispatchQueue(label: "acronym.MockSession")
    }
  
    func makeDataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionTaskProtocol
    {
        return MockURLSessionTask(
            completionHandler: completionHandler,
            url: url,
            queue: queue)
    }
}

class MockURLSessionTask: URLSessionTaskProtocol {
    var completionHandler: (Data?, URLResponse?, Error?) -> Void
    var url: URL
    
    init(
        completionHandler:
        @escaping (Data?, URLResponse?, Error?) -> Void,
        url: URL,
        queue: DispatchQueue?)
    {
        if let queue = queue {
            self.completionHandler = { data, response, error in
                queue.async {
                    completionHandler(data, response, error)
                }
            }
        } else {
            self.completionHandler = completionHandler
        }
        self.url = url
    }
  
    var calledResume = false
    func resume() {
        calledResume = true
    }
}
