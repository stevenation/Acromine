//
//  ViewController.swift
//  Acronym
//
//  Created by Thabiso Setefane on 2/9/22.
//

import Combine
import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate {
    @IBOutlet var seachBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    var indicator: UIActivityIndicatorView?
    lazy var viewModel: SearchViewModel = {
        let viewModel = SearchViewModel()
        return viewModel
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        seachBar.delegate = self
        setupIndicator()
    }

    func setupIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator?.style = UIActivityIndicatorView.Style.medium
        indicator?.center = view.center
        if let indicator = indicator {
            view.addSubview(indicator)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchText.isEmpty else { return }
        indicator?.startAnimating()
        viewModel.fetchData(searchText)
        viewModel.bindToTableView {
            DispatchQueue.main.async { [weak self] in
                self?.indicator?.stopAnimating()
                self?.indicator?.hidesWhenStopped = true
                self?.tableView.reloadData()
            }
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.searchListCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseableIdentifier, for: indexPath) as? SearchTableViewCell
        cell?.cellViewModel = viewModel.getCellViewModel(at: indexPath)
        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
