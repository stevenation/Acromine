//
//  AcronymViewModel.swift
//  Acronym
//
//  Created by Thabiso Setefane on 2/9/22.
//

import Foundation
import UIKit

struct SearchCellViewModel {
    private let longForm: LongForm
    init(_ lonForm: LongForm) {
        self.longForm = lonForm
    }
    var name: String {
        return longForm.repForm.capitalized
    }
    var year: String {
        return " Since: \(longForm.year)"
    }
}
