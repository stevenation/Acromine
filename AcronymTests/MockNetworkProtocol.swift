//
//  MockNetworkProtocol.swift
//  AcronymTests
//
//  Created by Thabiso Setefane on 2/10/22.
//
@testable import Acronym
import Foundation
class MockNetworkProtocol: NetworkProtocol {
    var baseURL: String = "http://www.nactem.ac.uk/software/acromine/dictionary.py"
    var fetchDataCompletion: (([Results]?, Error?) -> Void)!
    lazy var fetchDataDataTask = MockURLSessionTask(
      completionHandler: { _, _, _ in },
      url: URL(string: baseURL)!,
      queue: nil)
    func fetchData(_ abbrv: String, completion: @escaping ([Results]?, Error?) -> Void) -> URLSessionTaskProtocol? {
        fetchDataCompletion = completion
        return fetchDataDataTask
    }
}
