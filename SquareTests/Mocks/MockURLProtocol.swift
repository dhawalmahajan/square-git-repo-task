//
//  MockURLProtocol.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//

import Foundation

final class MockURLProtocol: URLProtocol {

    static var stubResponseData: Data?
    static var error: Error?
    static var statusCode: Int = 200 
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {

        // ✅ Network error — fail immediately, no response needed
               if let error = MockURLProtocol.error {
                   client?.urlProtocol(self, didFailWithError: error)
                   return
               }

               // ✅ Always send a proper HTTP response first
               if let url = request.url {
                   let response = HTTPURLResponse(
                       url: url,
                       statusCode: MockURLProtocol.statusCode,
                       httpVersion: nil,
                       headerFields: ["Content-Type": "application/json"]
                   )!
                   client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
               }

               // ✅ Then send data (empty Data() will cause decoding failure → testParsingFailure works)
               let data = MockURLProtocol.stubResponseData ?? Data()
               client?.urlProtocol(self, didLoad: data)
               client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
