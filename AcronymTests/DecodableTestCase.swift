//
//  Decoable.swift
//  AcronymTests
//
//  Created by Thabiso Setefane on 2/10/22.
//

import Foundation
protocol DecodableTestCase: AnyObject {
    associatedtype T: Decodable
    var dictionary: NSDictionary! { get set }
    var sut: T! { get set }
}

extension DecodableTestCase {
    func givenSUTFromJSON(fileName: String = "\(T.self)",
                          file: StaticString = #file,
                          line: UInt = #line) throws
    {
        let decoder = JSONDecoder()
        let data = try Data.fromJSON(fileName: fileName, file: file, line: line)
        let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSArray
        dictionary = response?[0] as? NSDictionary
        sut = try decoder.decode(T.self, from: data)
    }
}
