//
//  QuotesViewController.swift
//  QuotesAppLegacy
//
//  Created by Amin faruq on 03/11/26.
//

import UIKit

class QuotesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // UI components managed directly inside the ViewController
    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let refreshControl = UIRefreshControl()
    
    // Raw network DTO models stored directly in the ViewController (no ViewModel or Domain Model)
    var quotes: [QuoteResponse] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        self.title = "Daily Quotes"
        self.view.backgroundColor = .systemBackground
        
        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        self.view.addSubview(tableView)
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
    }
    
    @objc private func handleRefresh() {
        fetchData(isRefresh: true)
    }
    
    private func fetchData(isRefresh: Bool = false) {
        if !isRefresh {
            activityIndicator.startAnimating()
        }
        
        // Directly calling the concrete APIManager singleton from the ViewController
        APIManager.shared.fetchQuotes { [weak self] quotes, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.activityIndicator.stopAnimating()
                self.refreshControl.endRefreshing()
                
                if let error = error {
                    print("Failed to load quotes in VC: \(error.localizedDescription)")
                    let alert = UIAlertController(
                        title: "Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                    return
                }
                
                if let quotes = quotes {
                    self.quotes = quotes
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "QuoteCell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        }
        
        let item = quotes[indexPath.row]
        
        // Presentation formatting logic mixed directly inside the ViewController
        cell?.textLabel?.text = "\"\(item.quote)\""
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        cell?.detailTextLabel?.text = "— \(item.author) (#\(item.id))"
        cell?.detailTextLabel?.textColor = .secondaryLabel
        cell?.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 14)
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedQuote = quotes[indexPath.row]
        let alert = UIAlertController(
            title: selectedQuote.author,
            message: selectedQuote.quote,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Close", style: .cancel))
        self.present(alert, animated: true)
    }
}
