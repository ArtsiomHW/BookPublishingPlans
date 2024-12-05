//
//  BookPreview.swift
//  BookPublishingPlans
//
//  Created by Artem H on 11/26/24.
//

import Foundation

struct PublisherPlans: Decodable {
    let books: [Book]
    let publisher: String
    
    enum CodingKeys: String, CodingKey {
        case books = "objects"
        case publisher = "pub_name"
    }
    
    init(books: [Book], publisher: String) {
        self.books = books
        self.publisher = publisher
    }
    
    init(publisherPlans: [String: Any]) {
        books = (publisherPlans["objects"] as? [[String: Any]])?.compactMap { Book(books: $0) } ?? []
        publisher = publisherPlans["pub_name"] as? String ?? ""
    }
    static func getPlans(from data: Any) -> PublisherPlans {
        guard let publisherPlans = data as? [String: Any] else {
            return PublisherPlans(books: [], publisher: "")
        }
        return PublisherPlans(publisherPlans: publisherPlans)
    }
}

struct Book: Decodable {
    let author: String
    let date: String
    let editionId: Int
    let name: String
    let series: String
    let metaInfo: MetaInfo?
    var coverURL: String?
    var coverData: Data?
    var bookRating: String?
    
    static func getClearName(of author: String) -> String {
        var cleanName = author
        
        if let regex = try? NSRegularExpression(pattern: "\\[.*?\\]", options: []) {
            let range = NSRange(location: 0, length: cleanName.utf16.count)
            cleanName = regex.stringByReplacingMatches(
                in: author,
                range: range,
                withTemplate: ""
            )
        }
        
        return cleanName
    }
    
    enum CodingKeys: String, CodingKey {
        case author = "autors"
        case date = "date"
        case editionId = "edition_id"
        case name = "name"
        case series = "series"
        case metaInfo = "the_only_work"
    }
    
    init(
        author: String,
        date: String,
        editionId: Int,
        name: String,
        series: String,
        metaInfo: MetaInfo?,
        coverURL: String?,
        coverData: Data?,
        bookRating: String?
    ) {
        self.author = author
        self.date = date
        self.editionId = editionId
        self.name = name
        self.series = series
        self.metaInfo = metaInfo
        self.coverURL = coverURL
        self.coverData = coverData
        self.bookRating = bookRating
    }
    
    init(books: [String: Any]) {
        author = books["autors"] as? String ?? ""
        date = books["date"] as? String ?? ""
        editionId = books["edition_id"] as? Int ?? 0
        name = books["name"] as? String ?? ""
        series = books["series"] as? String ?? ""

        if let bookMetaInfo = books["the_only_work"] as? [String: Any] {
            metaInfo = MetaInfo(metaInfo: bookMetaInfo)
        } else {
            metaInfo = nil
        }
    }
}

struct MetaInfo: Decodable {
    let bookId: Int?
    
    enum CodingKeys: String, CodingKey {
        case bookId = "work_id"
    }
    
    init(bookId: Int?) {
        self.bookId = bookId
    }
    
    init(metaInfo: [String: Any]) {
        bookId = metaInfo["work_id"] as? Int ?? 0
    }
}


struct BookDetails: Decodable {
    let mainCover: String?
    let previewCover: String?
    let ratingInfo: Rating?
    let title: String?
    let numberOfVoters: Int?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case mainCover = "image"
        case previewCover = "image_preview"
        case ratingInfo = "rating"
        case title = "title"
        case numberOfVoters = "val_voters"
        case description = "work_description"
    }
    
    init(
        mainCover: String?,
        previewCover: String?,
        ratingInfo: Rating?,
        title: String?,
        numberOfVoters: Int?,
        description: String?
    ) {
        self.mainCover = mainCover
        self.previewCover = previewCover
        self.ratingInfo = ratingInfo
        self.title = title
        self.numberOfVoters = numberOfVoters
        self.description = description
    }
    
    init(bookDetails: [String: Any]) {
        mainCover = bookDetails["image"] as? String ?? ""
        previewCover = bookDetails["image_preview"] as? String ?? ""
        
        if let bookRatingInfo = bookDetails["rating"] as? [String: Any] {
            ratingInfo = Rating(bookRating: bookRatingInfo)
        } else {
            ratingInfo = nil
        }
            
        title = bookDetails["title"] as? String ?? ""
        numberOfVoters = bookDetails["val_voters"] as? Int ?? 0
        description = bookDetails["work_description"] as? String ?? ""
    }
    
    static func getBookDetails(from data: Any) -> BookDetails {
        guard let bookDetails = data as? [String: Any] else {
            return BookDetails(
                mainCover: "",
                previewCover: "",
                ratingInfo: nil,
                title: "",
                numberOfVoters: 0,
                description: ""
            )
        }

        return BookDetails(bookDetails: bookDetails)
    }
}

struct Rating: Decodable {
    let rating: String?
    
    enum CodingKeys: String, CodingKey {
        case rating = "rating"
    }
    
    init(rating: String?) {
        self.rating = rating
    }
    
    init(bookRating: [String: Any]) {
        rating = bookRating["rating"] as? String ?? ""
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let intRating = try? container.decodeIfPresent(Int.self, forKey: .rating) {
            rating = String(intRating)
        } else {
            rating = try container.decodeIfPresent(String.self, forKey: .rating)
        }
    }
}

struct BookDetailsExtended: Decodable {
    let coverURL: String?
    let bookDescription: String?
    let originalName: String?
    
    enum CodingKeys: String, CodingKey {
        case coverURL = "image"
        case bookDescription = "work_description"
        case originalName = "work_name_orig"
    }
    
    init(coverURL: String?, bookDescription: String?, originalName: String?) {
        self.coverURL = coverURL
        self.bookDescription = bookDescription
        self.originalName = originalName
    }
    
    init(bookDetailsExtended: [String: Any]) {
        coverURL = bookDetailsExtended["image"] as? String ?? ""
        bookDescription = bookDetailsExtended["work_description"] as? String ?? ""
        originalName = bookDetailsExtended["work_name_orig"] as? String ?? ""
    }
}
