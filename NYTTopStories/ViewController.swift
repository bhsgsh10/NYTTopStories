//
//  ViewController.swift
//  NYTTopStories
//
//  Created by Bhaskar Ghosh on 9/14/20.
//  Copyright © 2020 Bhaskar Ghosh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var tableView: UITableView = UITableView(frame: .zero,
                                             style: .grouped)
    
    lazy var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
    
    var topStory: TopStory?
    var diffableDataSource: UITableViewDiffableDataSource<Int, TopStoryResult>?
    static let reuseId: String = "topStoryCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        //buildAndApplySnapshot()
        
        view.addSubview(activityIndicator)
        view.bringSubviewToFront(activityIndicator)
        
        makeNetworkRequest()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
        
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 100/255, alpha: 0.5)
        tableView.register(TopStoryTableViewCell.self,
                           forCellReuseIdentifier: ViewController.reuseId)

        diffableDataSource = UITableViewDiffableDataSource(tableView: tableView, cellProvider: { tableView, indexPath, topStoryResult in
            let cell: TopStoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: ViewController.reuseId,
                                                                            for: indexPath) as! TopStoryTableViewCell
            
            cell.topStoryResult = topStoryResult
            return cell
          })
    }
    
    private func buildAndApplySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, TopStoryResult>()
        if let resultsCollection = topStory?.results {
            snapshot.appendSections([0])
            snapshot.appendItems(resultsCollection, toSection: 0)
        } else {
            snapshot.appendSections([0])
        }
        
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }

    private func makeNetworkRequest() {
        
        let domain = "https://api.nytimes.com/svc/topstories/v2/"
        let sectionName = "science"
        
        let components: [String: String] = ["domain": domain,
                                           "sectionName": sectionName,
                                           "key": accessToken]
        guard let fullURLStr = formFullURL(urlComponents: components),
            let url = URL(string: fullURLStr) else
            { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            // Check if Error took place
            if let error = error {
                print("Error took place \(error)")
                return
            }
            
            if let dataRecvd = data {
                self.topStory = self.loadData(data: dataRecvd)
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.tableView.backgroundColor = UIColor.white
                    self.buildAndApplySnapshot()
                }
            }
            
        }
        task.resume()
    }
    
    private func formFullURL(urlComponents: [String: String]?) -> String? {
        
        guard let components: [String: String] = urlComponents,
            let domain: String = components["domain"],
            let section: String = components["sectionName"],
            let key = components["key"] else {return ""}
        
        let fullURL: String = domain + section + ".json?api-key=" + key
        
        return fullURL
    }
    
    private func decode(data: Data) throws -> TopStory? {
        do {
            let decoder = JSONDecoder()
            let topStories = try decoder.decode(TopStory.self, from: data)
            return topStories
        } catch let error {
            print(error)
            return nil
        }
    }
    
    private func loadData(data: Data) -> TopStory? {
        
        do {
            let topStories = try decode(data: data)
            return topStories
        } catch let error {
            print(error)
            return nil
        }
        
    }
}

extension ViewController: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
}
