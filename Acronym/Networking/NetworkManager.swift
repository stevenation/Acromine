//
//  NetworkManager.swift
//  Acronym
//
//  Created by Thabiso Setefane on 2/9/22.
//

import Foundation

protocol NetworkProtocol {
    func fetchData(
        _ abbrv: String,
        completion:
        @escaping ([Results]?, Error?) -> Void) -> URLSessionTaskProtocol?
}

final class NetworkManager: NetworkProtocol {
    static let shared = NetworkManager(
        baseURL: "http://www.nactem.ac.uk/software/acromine/dictionary.py",
        session: URLSession.shared,
        responseQueue: .main)
    let baseURL: String
    let session: URLSessionProtocol
    let responseQueue: DispatchQueue?
    init(
        baseURL: String,
        session: URLSessionProtocol,
        responseQueue: DispatchQueue?)
    {
        self.baseURL = baseURL
        self.session = session
        self.responseQueue = responseQueue
    }

    func fetchData(_ abbrv: String, completion: @escaping ([Results]?, Error?) -> Void) -> URLSessionTaskProtocol? {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return nil
        }
        urlComponents.query = "sf=\(abbrv)"
        guard let url = urlComponents.url else {
            return nil
        }
        let task = self.session.makeDataTask(with: url) { [weak self] data, URLResponse, error in
            guard let self = self else { return }
            guard let data = data,
                  let response = URLResponse as? HTTPURLResponse,
                  response.statusCode == 200,
                  error == nil
            else {
                self.dispatchResult(error: error, completion: completion)
                return
            }
            do {
                let result = try JSONDecoder().decode([Results].self, from: data)
                self.dispatchResult(models: result, completion: completion)

            } catch {
                self.dispatchResult(error: error, completion: completion)
            }
        }
        task.resume()
        return task
    }

    private func dispatchResult<Type>(
        models: Type? = nil,
        error: Error? = nil,
        completion: @escaping (Type?, Error?) -> Void)
    {
        guard let responseQueue = responseQueue else {
            completion(models, error)
            return
        }
        responseQueue.async {
            completion(models, error)
        }
    }
}
