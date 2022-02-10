//
//  SearchTableViewCell.swift
//  Acronym
//
//  Created by Thabiso Setefane on 2/9/22.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    static var reuseableIdentifier: String = "SearchTableViewCell"
    @IBOutlet var repFormLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    var cellViewModel: SearchCellViewModel? {
        didSet {
            repFormLabel.text = cellViewModel?.name
            yearLabel.text = cellViewModel?.year
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
