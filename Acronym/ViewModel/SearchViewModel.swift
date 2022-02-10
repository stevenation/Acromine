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
    private var searchList = [SearchCellViewModel]() {
        didSet {
            reloadTableView?()
        }
    }
    var searchListCount: Int {
        return searchList.count
    }
    private var reloadTableView: (() -> Void)?
    init(_ manager: NetworkManager = NetworkManager()) {
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
        networkManager.fetchData(abbrv) { [weak self] data, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            DispatchQueue.main.async {
                self?.searchList = data
                    .sorted(by: { $0.repForm < $1.repForm })
                    .map { SearchCellViewModel($0) }
            }
        }
    }
}
