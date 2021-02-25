//
//  ViewController.swift
//  NYTTopStories
//
//  Created by Bhaskar Ghosh on 9/14/20.
//  Copyright © 2020 Bhaskar Ghosh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    enum SomeError: Error {
        case badURL
        case badResponse
    }
    
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
        
        makeNetworkRequest { [weak self] topStory, error in
            if let e = error {
                print(e.localizedDescription)
                return
            }
            
            if let story = topStory {
                self?.topStory = story
               DispatchQueue.main.async {
                   self?.activityIndicator.stopAnimating()
                   self?.activityIndicator.isHidden = true
                   self?.tableView.backgroundColor = UIColor.white
                   self?.buildAndApplySnapshot()
               }
            }
        }
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

    private func makeNetworkRequest(completion: @escaping (TopStory?, Error?) -> ()) {
        
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.nytimes.com"
        
        func formRestOfPath(_ strPath: String, _ sectionName: String) -> String  {
            return "\(strPath)\(sectionName).json"
        }
        components.percentEncodedPath = formRestOfPath("/svc/topstories/v2/",
                                                       "science")
        let queryItems = [URLQueryItem(name: "api-key", value: accessToken)]
        components.queryItems = queryItems
        
        if let url = components.url {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: urlRequest) {[weak self] (data, response, error) in
                
                // Check if Error took place
                if let e = error {
                    print("Error took place \(e)")
                    completion(nil, e)
                    return
                }
                
                if let storyData = data, let story = self?.loadData(data: storyData) {
                    if let _ = story.results {
                        completion(story, nil)
                    } else {
                        completion(nil,SomeError.badResponse)
                    }
                }
                
            }
            task.resume()
        } else {
            completion(nil, SomeError.badURL)
        }
        
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

