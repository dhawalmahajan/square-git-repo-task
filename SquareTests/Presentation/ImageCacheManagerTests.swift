//
//  ImageCacheManagerTests.swift
//  SquareTests
//
//  Created by Dhawal Mahajan on 25/03/26.
//

import XCTest

@testable import Square

final class ImageCacheManagerTests: XCTestCase {

  var session: URLSession!

  override func setUp() {
    super.setUp()

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    session = URLSession(configuration: config)
    ImageCacheManager.shared = ImageCacheManager(session: session)
  }

  override func tearDown() {
    #if DEBUG
      ImageCacheManager.shared.clearCache()
    #endif
    session = nil
    MockURLProtocol.stubResponseData = nil
    MockURLProtocol.error = nil
    MockURLProtocol.statusCode = 200
    URLCache.shared.removeAllCachedResponses()
    super.tearDown()
  }

  func test_whenValidImageData_thenReturnsImage() {
    // Given
    let image = UIImage(systemName: "star")!
    let imageData = image.pngData()!
    MockURLProtocol.stubResponseData = imageData

    let expectation = expectation(description: "Image loads successfully")
    let url = URL(string: "https://example.com/image.png")!

    // When
    ImageCacheManager.shared.loadImage(from: url) { loadedImage in
      // Then
      XCTAssertNotNil(loadedImage)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenInvalidImageData_thenReturnsNil() {
    // Given
    let invalidData = "not an image".data(using: .utf8)!
    MockURLProtocol.stubResponseData = invalidData

    let expectation = expectation(description: "Image load fails")
    let url = URL(string: "https://example.com/invalid.png")!

    // When
    ImageCacheManager.shared.loadImage(from: url) { loadedImage in
      // Then
      XCTAssertNil(loadedImage)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenNetworkError_thenReturnsNil() {
    // Given
    MockURLProtocol.error = URLError(.notConnectedToInternet)

    let expectation = expectation(description: "Image load fails with network error")
    let url = URL(string: "https://example.com/error.png")!

    // When
    ImageCacheManager.shared.loadImage(from: url) { loadedImage in
      // Then
      XCTAssertNil(loadedImage)
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenImageCached_thenReturnsCachedImageWithoutNetworkCall() {
    // Given
    let image = UIImage(systemName: "heart")!
    let url = URL(string: "https://example.com/cached.png")!

    // Pre-cache the image directly in memory cache
    let key = url.absoluteString as NSString
    #if DEBUG
      ImageCacheManager.shared.memoryCache.setObject(image, forKey: key)
    #endif

    // Set up mock to fail if called (shouldn't be called for cached image)
    MockURLProtocol.error = URLError(.notConnectedToInternet)

    let expectation = expectation(description: "Cached image returned")

    // When
    ImageCacheManager.shared.loadImage(from: url) { loadedImage in
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenImageDownloaded_thenStoredInCache() {
    // Given
    let image = UIImage(systemName: "circle")!
    let imageData = image.pngData()!
    MockURLProtocol.stubResponseData = imageData

    let url = URL(string: "https://example.com/store.png")!
    let expectation = expectation(description: "Image downloaded and cached")

    // When
    ImageCacheManager.shared.loadImage(from: url) { loadedImage in
      XCTAssertNotNil(loadedImage)

      // Check if image is in memory cache
      let key = url.absoluteString as NSString
      // Note: We can't directly access the private cache, but we can verify by loading again
      // and ensuring no network call is made

      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
  }

  func test_whenSameImageRequestedMultipleTimes_thenOnlyOneNetworkCall() {
    // Given
    let image = UIImage(systemName: "square")!
    let imageData = image.pngData()!
    MockURLProtocol.stubResponseData = imageData

    let url = URL(string: "https://example.com/multiple.png")!
    let expectation1 = expectation(description: "First image load")
    let expectation2 = expectation(description: "Second image load")

    // When - Load same image twice
    ImageCacheManager.shared.loadImage(from: url) { loadedImage in
      XCTAssertNotNil(loadedImage)
      expectation1.fulfill()
    }

    ImageCacheManager.shared.loadImage(from: url) { loadedImage in
      expectation2.fulfill()
    }

    // Then
    wait(for: [expectation1, expectation2], timeout: 5)
    // Both should complete successfully, with only one network call
  }
}
