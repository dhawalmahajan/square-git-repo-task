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
  private let urlCache: URLCache?

  // ✅ Default for production
  //MARK: Initializer
  init(session: URLSession = .shared) {
    self.session = session
    self.urlCache = session.configuration.urlCache ?? URLCache.shared
  }

  func request(url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
    let request = URLRequest(url: url)

    // Check cache first
    if let cachedResponse = urlCache?.cachedResponse(for: request),
      let httpResponse = cachedResponse.response as? HTTPURLResponse,
      httpResponse.statusCode == 200
    {
      completion(.success(cachedResponse.data))
      return
    }

    session.dataTask(with: request) { [weak self] data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }

      guard let self = self, let data = data, let response = response else { return }

      // Cache the response
      let cachedResponse = CachedURLResponse(response: response, data: data)
      self.urlCache?.storeCachedResponse(cachedResponse, for: request)

      completion(.success(data))
    }.resume()
  }
}
