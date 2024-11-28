//
//  BookCell.swift
//  BookPublishingPlans
//
//  Created by Artem H on 11/26/24.
//

import UIKit

final class BookCell: UITableViewCell {
    
    @IBOutlet var cover: UIImageView!
    @IBOutlet var bookTitleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var releaseDateLabel: UILabel!
    
    private let networkManager = NetworkingManager.shared
    
    func configureCell(with book: Book) {
        
        let baseURL = "https://fantlab.ru"
        var author = book.author
        
        if let regex = try? NSRegularExpression(pattern: "\\[.*?\\]", options: []) {
            let range = NSRange(location: 0, length: author.utf16.count)
            author = regex.stringByReplacingMatches(
                in: author,
                range: range,
                withTemplate: ""
            )
        }
        bookTitleLabel.text = book.name
        authorLabel.text = author
        releaseDateLabel.text = "Выйдет \(book.date)г."
        
        guard let coverId = book.metaInfo?.bookId else {
            DispatchQueue.main.async { [weak self] in
                guard let self else {return}
                cover.image = UIImage(named: "noCover")
            }
            return
        }
        
        networkManager.fetchBookDetails(bookId: coverId) { [weak self] result in
            guard let self else {return}
            
            switch result {
            case .success(let details):
                let bookCoverPath = details.previewCover
                
                guard let bookCoverPath = bookCoverPath else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        cover.image = UIImage(named: "noCover")
                    }
                    return
                }
                
                guard let fullURL = URL(string: baseURL + bookCoverPath) else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {return}
                        cover.image = UIImage(named: "noCover")
                    }
                    return
                }
                
                networkManager.fetchImage(from: fullURL) { [weak self] result in
                    guard let self else {return}
                    
                    switch result {
                    case .success(let coverData):
                        cover.image = UIImage(data: coverData)
                    case .failure(let error):
                        cover.image = UIImage(named: "noCover")
                        print(error)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
