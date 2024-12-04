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
    
    enum CodingKeys: String, CodingKey {
        case author = "autors"
        case date = "date"
        case editionId = "edition_id"
        case name = "name"
        case series = "series"
        case metaInfo = "the_only_work"
    }
}

struct MetaInfo: Decodable {
    let bookId: Int?
    
    enum CodingKeys: String, CodingKey {
        case bookId = "work_id"
    }
}


struct BookDetails: Decodable {
    let mainCover: String?
    let previewCover: String?
    let title: String?
    let numberOfVoters: Int?
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case mainCover = "image"
        case previewCover = "image_preview"
        case title = "title"
        case numberOfVoters = "val_voters"
        case description = "work_description"
    }
    
}
