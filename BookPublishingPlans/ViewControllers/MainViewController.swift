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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let settingsVC = segue.destination as? BookDetailsViewController
            settingsVC?.bookDetails = books[indexPath.row]
        }
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
        
        let publisherURL = networkManager.getApiURL(for: publisher)
        
        networkManager.fetch(PublisherPlans.self, from: publisherURL) { [weak self] result in
            guard let self else { return }
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
                let fullCoverURL = URL(string: "https://api.fantlab.ru/work/\(bookID)")!
                
                networkManager.fetch(BookDetails.self, from: fullCoverURL) { [weak self] result in
                    defer { dispatchGroup.leave() }
                    guard let self else { return }
                    
                    switch result {
                    case .success(let bookDetails):
                        let partOfURL = bookDetails.previewCover
                        let bookRating = bookDetails.ratingInfo?.rating
                                            
                        detailedBooks[index].bookRating = bookRating
                        
                        guard let url = partOfURL else { return }
                        let constructURL = networkManager.constructCoverURL(with: url)

                        guard let fullCoverURL = constructURL else {
                            print(NetworkError.invalidURL)
                            return
                        }
                                                
                        dispatchGroup.enter()
                        self.networkManager.fetchData(from: fullCoverURL) { result in
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
    
    
    
