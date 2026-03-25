//
//  ImageCacheManager.swift
//  Square
//
//  Created by Dhawal Mahajan on 25/03/26.
//

import UIKit

final class ImageCacheManager {
  static let shared = ImageCacheManager()

  private let cache = NSCache<NSString, UIImage>()
  private let session: URLSession

  private init() {
    let config = URLSessionConfiguration.default
    config.urlCache = URLCache.shared
    self.session = URLSession(configuration: config)
  }
  #if DEBUG
    var memoryCache: NSCache<NSString, UIImage> {
      return cache
    }

    func clearCache() {
      cache.removeAllObjects()
    }
  #endif

  func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
    let key = url.absoluteString as NSString

    // Check memory cache first
    if let cachedImage = cache.object(forKey: key) {
      completion(cachedImage)
      return
    }

    // Check disk cache
    let request = URLRequest(url: url)
    if let cachedResponse = URLCache.shared.cachedResponse(for: request),
      let image = UIImage(data: cachedResponse.data)
    {
      cache.setObject(image, forKey: key)
      completion(image)
      return
    }

    // Download image
    session.dataTask(with: request) { [weak self] data, response, error in
      guard let self = self,
        let data = data,
        let image = UIImage(data: data),
        let response = response
      else {
        DispatchQueue.main.async {
          completion(nil)
        }
        return
      }

      // Cache in memory
      self.cache.setObject(image, forKey: key)

      // Cache in disk
      let cachedResponse = CachedURLResponse(response: response, data: data)
      URLCache.shared.storeCachedResponse(cachedResponse, for: request)

      DispatchQueue.main.async {
        completion(image)
      }
    }.resume()
  }
}
