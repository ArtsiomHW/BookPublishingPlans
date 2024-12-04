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
        
        guard let coverData = book.coverData else {
            cover.image = UIImage(named: "noCover")
            return
        }
        cover.image = UIImage(data: coverData)
    }
}
