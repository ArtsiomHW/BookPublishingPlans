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
    private var book: [Book] = []
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
        book.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookPreviewCell", for: indexPath)
        guard let cell = cell as? BookCell else { return UITableViewCell() }
        let book = book[indexPath.row]
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
            networkManager.fetchPlans(of: publisher) { [unowned self] result in
                switch result {
                case .success(let plans):
                    book = plans.books                    
                    tableView.reloadData()
                    activityIndicator.stopAnimating()
                case .failure(let error):
                    print(error)
                }
            }
        }
        
    }
}





