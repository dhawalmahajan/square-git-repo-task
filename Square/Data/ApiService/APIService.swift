//
//  APIService.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//
import Foundation
final class APIService {
    //MARK: properties
    private let session: URLSession

       // ✅ Default for production
    //MARK: Initializer
       init(session: URLSession = .shared) {
           self.session = session
       }
    func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {

        session.dataTask(with: url) { data, _, error in

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else { return }
            completion(.success(data))

        }.resume()
    }
}
