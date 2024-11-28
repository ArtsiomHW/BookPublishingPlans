//
//  NetworkingManager.swift
//  BookPublishingPlans
//
//  Created by Artem H on 11/26/24.
//

import Foundation

enum Publisher: CaseIterable {
    case azbuka
    case act
    case fanzon
    case eksmo
    
    var url: URL {
        switch self {
        case .azbuka:
            URL(string: "https://api.fantlab.ru/pubplans?pub_id=1431")!
        case .act:
            URL(string: "https://api.fantlab.ru/pubplans?pub_id=33")!
        case .fanzon:
            URL(string: "https://api.fantlab.ru/pubplans?pub_id=7193")!
        case .eksmo:
            URL(string: "https://api.fantlab.ru/pubplans?pub_id=324")!
        }
    }
    
    var name: String {
        switch self {
        case .azbuka:
            "Азбука"
        case .act:
            "АСТ"
        case .fanzon:
            "Фанзон"
        case .eksmo:
            "Эксмо"
        }
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

final class NetworkingManager {
    
    static let shared = NetworkingManager()
    
    private init() {}

    
    func fetchPlans(of publisher: String,completion: @escaping(Result<BookPreview, NetworkError>) -> Void) {
        let url: URL
        
        switch publisher {
        case Publisher.azbuka.name:
            url = Publisher.azbuka.url
        case Publisher.act.name:
            url = Publisher.act.url
        case Publisher.fanzon.name:
            url = Publisher.fanzon.url
        case Publisher.eksmo.name:
            url = Publisher.eksmo.url
        default:
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data else {
                print(error ?? "No description for error")
                completion(.failure(.noData))
                return
            }
            
            do {
                let dataModel = try JSONDecoder().decode(BookPreview.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(dataModel))
                }
                
            } catch {
                print(error)
            }
            
        }.resume()
    }
    
    func fetchBookDetails(bookId: Int, completion: @escaping (Result<BookDetails, NetworkError>) -> Void) {
        let url = URL(string: "https://api.fantlab.ru/work/\(bookId)")!
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error ?? "No description for error")
                completion(.failure(.noData))
                return
            }
            
            do {
                let bookDetails = try JSONDecoder().decode(BookDetails.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(bookDetails))
                }
            } catch {
                print(error)
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
    func fetchImage(from url: URL, completion: @escaping(Result<Data, NetworkError>) -> Void) {
        DispatchQueue.global().async {
            guard let cover = try? Data(contentsOf: url) else {
                completion(.failure(.noData))
                return
            }
            DispatchQueue.main.async {
                completion(.success(cover))
            }
        }
    }
    
}
