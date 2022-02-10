//
//  AcronymModel.swift
//  Acronym
//
//  Created by Thabiso Setefane on 2/9/22.
//

import Foundation

struct Results: Codable {
    let abbreviation: String
    let longForms: [LongForm]

    enum CodingKeys: String, CodingKey {
        case abbreviation = "sf"
        case longForms = "lfs"
    }
}

struct LongForm: Codable {
    let repForm: String
    let frequency: Int
    let year: Int
    let variations: [LongForm]?

    enum CodingKeys: String, CodingKey {
        case repForm = "lf"
        case frequency = "freq"
        case year = "since"
        case variations = "vars"
    }
}

extension Results: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.abbreviation == rhs.abbreviation
    }
}
