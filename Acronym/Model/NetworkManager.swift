//
//  NetworkManager.swift
//  Acronym
//
//  Created by Thabiso Setefane on 2/9/22.
//

import Foundation

final class NetworkManager: NSObject {
    private let baseURL: String = "http://www.nactem.ac.uk/software/acromine/dictionary.py"

    func fetchData(_ abbrv: String, completion: @escaping ([LongForm]?, Error?) -> Void) {
        guard var urlComponents = URLComponents(string: baseURL) else {
            return
        }
        urlComponents.query = "sf=\(abbrv)"
        guard let url = urlComponents.url else { return }

        URLSession.shared.dataTask(with: url) { data, URLResponse, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            guard let data = data,
                  let response = URLResponse as? HTTPURLResponse,
                  response.statusCode == 200
            else {
                return
            }
            do {
                let result = try JSONDecoder().decode([Result].self, from: data)
                if result.isEmpty {
                    completion([], nil)
                } else {
                    completion(result[0].longForms, nil)
                }
            } catch {
                completion(nil, error)
            }

        }.resume()
    }
}
