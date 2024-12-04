//
//  ViewController.swift
//  BookPublishingPlans
//
//  Created by Artem H on 11/26/24.
//

import UIKit

final class MainViewController: UITableViewController {
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    private let publisher = Publisher.allCases
    private let networkManager = NetworkingManager.shared
    private var books: [Book] = []
    private var covers: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
        
        setUpSegmentControl()
        segmentChanged()
        
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookPreviewCell", for: indexPath)
        guard let cell = cell as? BookCell else { return UITableViewCell() }
        let book = books[indexPath.row]
        cell.configureCell(with: book)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - SegmentedControl and Networking
extension MainViewController {
    
    
    private func setUpSegmentControl() {
        segmentedControl.removeAllSegments()
        
        for (index, publisher) in Publisher.allCases.enumerated() {
            segmentedControl.insertSegment(withTitle: publisher.name, at: index, animated: false)
        }
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }
    
    @objc private func segmentChanged() {
        let selectedIndex = segmentedControl.selectedSegmentIndex
        if let publisher = segmentedControl.titleForSegment(at: selectedIndex) {
            fetchAllData(for: publisher) { [weak self] detailedBooks in
                guard let self else { return }
                
                books = detailedBooks
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
            
        }
                
    }
    
    private func fetchAllData(for publisher: String, completion: @escaping([Book]) -> Void) {
        
        networkManager.fetchPlans(of: publisher) { result in
            let dispatchGroup = DispatchGroup()
            var detailedBooks: [Book] = []
            
            switch result {
            case .success(let plans):
                detailedBooks = plans.books
            case .failure(let error):
                print(error)
            }
            
            for (index, book) in detailedBooks.enumerated() {
                
                
                guard let bookID = book.metaInfo?.bookId else {
                    print(NetworkError.noBookID)
                    continue
                }
                
                dispatchGroup.enter()
                self.networkManager.fetchBookDetails(bookId: bookID) { [weak self] result in
                    defer { dispatchGroup.leave() }
                    guard let self else { return }
                    
                    switch result {
                    case .success(let bookDetails):
                        let partOfURL = bookDetails.previewCover
                        detailedBooks[index].coverURL = networkManager.constructCoverURL(with: partOfURL)
                        print(detailedBooks[index].coverURL ?? "")
                        
                        guard let url = detailedBooks[index].coverURL, let coverURL = URL(string: url) else {
                            print(NetworkError.invalidURL)
                            return
                        }
                                                
                        dispatchGroup.enter()
                        self.networkManager.fetchData(from: coverURL) { result in
                            defer { dispatchGroup.leave() }
                            
                            switch result {
                            case .success(let coverData):
                                detailedBooks[index].coverData = coverData
                            case .failure(let error):
                                print(error)
                            }
                        }
                        
                    case .failure(let error):
                        print(error)
                    }
                }
                
                              
            }
            
            dispatchGroup.notify(queue: .main) {
                completion(detailedBooks)
            }
            
        }
        
    }
    
}
    
    
    
