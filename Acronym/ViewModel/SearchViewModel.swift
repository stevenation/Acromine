//
//  SearchViewModel.swift
//  Acronym
//
//  Created by Thabiso Setefane on 2/9/22.
//

import Combine
import Foundation

protocol SearchViewModelProtocol {
    func getCellViewModel(at indexPath: IndexPath) -> SearchCellViewModel
    func fetchData(_ abbrv: String)
    func bindToTableView(_ closure: @escaping () -> Void)
}

final class SearchViewModel: NSObject, SearchViewModelProtocol {
    let networkManager: NetworkManager
    private var reloadTableView: (() -> Void)?
    private var searchList = [SearchCellViewModel]() {
        didSet {
            reloadTableView?()
        }
    }

    var searchListCount: Int {
        return searchList.count
    }

    init(_ manager: NetworkManager = NetworkManager.shared) {
        self.networkManager = manager
    }

    func bindToTableView(_ completion: @escaping () -> Void) {
        completion()
        reloadTableView = completion
    }

    func getCellViewModel(at indexPath: IndexPath) -> SearchCellViewModel {
        return searchList[indexPath.row]
    }

    func fetchData(_ abbrv: String) {
        _ = networkManager.fetchData(abbrv) { [weak self] data, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                guard !data.isEmpty else {
                    self?.searchList = []
                    return
                }
                self?.searchList = data[0].longForms
                    .sorted(by: { $0.repForm < $1.repForm })
                    .map { SearchCellViewModel($0) }
            }
        }
    }
}
