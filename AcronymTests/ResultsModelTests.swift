//
//  ResultsTest.swift
//  AcronymTests
//
//  Created by Thabiso Setefane on 2/10/22.
//

@testable import Acronym
import XCTest

class ResultsModelTest: XCTestCase, DecodableTestCase {
    var dictionary: NSDictionary!
    var sut: [Results]!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        try givenSUTFromJSON(fileName: "Results")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        dictionary = nil
        sut = nil
        try super.tearDownWithError()
    }

    func testDecodableSetsAbbreviation() throws {
        XCTAssertEqual(sut[0].abbreviation, dictionary["sf"] as! String)
    }

    func testDecodableSetsLongFormsRepForm() throws {
        let longForms = dictionary["lf"] as? [[String: Any]]
        XCTAssertEqual(sut[0].longForms[0].repForm, longForms?[0]["lf"] as? String)
    }

    func testDecodableSetsLongForms() throws {
        if let longForms = dictionary["lf"] as? [[String: Any]] {
            for index in 0 ..< longForms.count {
                XCTAssertEqual(sut[0].longForms[index].frequency, longForms[index]["freq"] as? Int)
                XCTAssertEqual(sut[0].longForms[index].repForm, longForms[index]["lf"] as? String)
                XCTAssertEqual(sut[0].longForms[index].year, longForms[index]["since"] as? Int)

                if let vars = longForms[index]["vars"] as? [[String: Any]] {
                    for i in 0 ..< vars.count {
                        XCTAssertEqual(sut[0].longForms[index].variations[i].surfaceForm, vars[i]["lf"] as? String)
                        XCTAssertEqual(sut[0].longForms[index].variations[i].frequency, vars[i]["freq"] as? Int)
                        XCTAssertEqual(sut[0].longForms[index].variations[i].year, vars[i]["since"] as? Int)
                    }
                }
            }
        }
    }
}

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
        var response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSArray
        dictionary = response?[0] as? NSDictionary
        sut = try decoder.decode(T.self, from: data)
    }
}
