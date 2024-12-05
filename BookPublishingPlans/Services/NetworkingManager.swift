//
//  NetworkingManager.swift
//  BookPublishingPlans
//
//  Created by Artem H on 11/26/24.
//

import Foundation
import Alamofire

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
    case noBookID
    case URLConversionError
}

final class NetworkingManager {
    
    static let shared = NetworkingManager()
    
    private init() {}
    
    func getApiURL(for publisher: String) -> URL {
        let url: URL
        
        switch publisher {
        case Publisher.azbuka.name:
            url = Publisher.azbuka.url
        case Publisher.act.name:
            url = Publisher.act.url
        case Publisher.fanzon.name:
            url = Publisher.fanzon.url
        default:
            url = Publisher.eksmo.url
        }
        
        return url
    }
   
   
    func fetch<T: Decodable>(
        _ type: T.Type,
        from url: URL,
        completion: @escaping(Result<T, AFError>) -> Void
    ) {
        AF.request(url)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                    print("Хз какая ошибка ______ ")
                }
            }
    }
    
    
    func fetchData(from url: URL, completion: @escaping(Result<Data, AFError>) -> Void) {
        AF.request(url)
            .validate()
            .responseData { dataResponse in
                switch dataResponse.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(AFError.createURLRequestFailed(error: error)))
                }
            }
        
    }
    
    func constructCoverURL(with previewCover: String) -> URL? {
        let fullCoverURL = "https://fantlab.ru/\(previewCover)"
        return URL(string: fullCoverURL)
    }
    
}
