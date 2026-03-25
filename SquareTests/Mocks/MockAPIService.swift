//
//  MockAPIService.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//

import Foundation
final class MockAPIService {
    //MARK: properties
    var shouldFail = false
    var mockData: Data?

    func request(completion: @escaping (Result<Data, Error>) -> Void) {
        if shouldFail {
            completion(.failure(URLError(.badServerResponse)))
        } else {
            completion(.success(mockData ?? Data()))
        }
    }
}
