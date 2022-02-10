//
//  extensions.swift
//  AcronymTests
//
//  Created by Thabiso Setefane on 2/10/22.
//

import Foundation
import XCTest
public extension Data {
    static func fromJSON(fileName: String,
                         file: StaticString = #file,
                         line: UInt = #line) throws -> Data
    {
        let bundle = Bundle(for: TestBundleClass.self)
        let url = try XCTUnwrap(bundle.url(forResource: fileName, withExtension: "json"),
                                "Unable to find \(fileName).json. Did you add it to the tests?",
                                file: file, line: line)
        return try Data(contentsOf: url)
    }
}

private class TestBundleClass {}
