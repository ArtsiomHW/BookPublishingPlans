//
//  BookDetailsViewController.swift
//  BookPublishingPlans
//
//  Created by Artem H on 12/4/24.
//

import UIKit

final class BookDetailsViewController: UIViewController {
    
    @IBOutlet var originalName: UILabel!
    @IBOutlet var author: UILabel!
    @IBOutlet var publishDate: UILabel!
    @IBOutlet var cycle: UILabel!
    @IBOutlet var rating: UILabel!
    @IBOutlet var bookDescription: UILabel!
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var ratingStackView: UIStackView!
    
    private let networkManager = NetworkingManager.shared
    var bookDetails: Book!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()

    }
    
    private func setUpView() {
        let book = bookDetails
        let bookTitle = book?.name ?? "Название не найдено"
        let authorName = Book.getClearName(of: book?.author ?? "Автор не известен")
        let date = book?.date ?? "не уточнена"
        
        title = bookTitle
        author.text = authorName
        publishDate.text = "Выйдет \(date)"
        cycle.text = ""

        
        ratingStackView.isHidden = book?.bookRating.flatMap { $0 == "0" } ?? true
        rating.text = book?.bookRating.flatMap { $0 != "0" ? $0 : nil } ?? ""
        
        guard let bookID = book?.metaInfo?.bookId else {
            originalName.text = ""
            cycle.text = ""
            bookDescription.text = ""
            coverImage.image = UIImage(named: "noCoverExtended")
            ratingStackView.isHidden = true
            return
        }
        
        let url = URL(string: "https://api.fantlab.ru/work/\(bookID)")!
        
        
        networkManager.fetch(BookDetailsExtended.self, from: url) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let extendedBookData):
                bookDescription.text = extendedBookData.bookDescription
                originalName.text = extendedBookData.originalName
                
                guard let coverURL = extendedBookData.coverURL else {
                    coverImage.image = UIImage(named: "noCoverExtended")
                    return
                }
                
                let fullCoverStringURL = networkManager.constructCoverURL(with: coverURL)
                
                guard let url = fullCoverStringURL else {
                    coverImage.image = UIImage(named: "noCoverExtended")
                    return
                }
                
                networkManager.fetchData(from: url) { [weak self] result in
                    guard let self else { return }
                    
                    switch result {
                    case .success(let data):
                        coverImage.image = UIImage(data: data)
                    case .failure(let error):
                        coverImage.image = UIImage(named: "noCoverExtended")
                        print(error)
                    }
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
