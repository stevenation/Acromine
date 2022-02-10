//
//  URLSessionProtocol.swift
//  Acronym
//
//  Created by Thabiso Setefane on 2/10/22.
//

import Foundation
protocol URLSessionProtocol: AnyObject {
    func makeDataTask(
        with url: URL,
        completionHandler:
        @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionTaskProtocol
}

protocol URLSessionTaskProtocol: AnyObject {
    func resume()
}

extension URLSessionTask: URLSessionTaskProtocol {}

extension URLSession: URLSessionProtocol {
    func makeDataTask(
        with url: URL,
        completionHandler:
        @escaping (Data?, URLResponse?, Error?) -> Void)
        -> URLSessionTaskProtocol
    {
        return dataTask(with: url,
                        completionHandler: completionHandler)
    }
}
