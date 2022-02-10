//
//  AcronymModel.swift
//  Acronym
//
//  Created by Thabiso Setefane on 2/9/22.
//

import Foundation

struct Result: Codable {
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
    let variations: [Variation]

    enum CodingKeys: String, CodingKey {
        case repForm = "lf"
        case frequency = "freq"
        case year = "since"
        case variations = "vars"
    }
}

struct Variation: Codable {
    let surfaceForm: String
    let frequency: Int
    let year: Int

    enum CodingKeys: String, CodingKey {
        case surfaceForm = "lf"
        case frequency = "freq"
        case year = "since"
    }
}
