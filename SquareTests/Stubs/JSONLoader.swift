//
//  JSONLoader.swift
//  Square
//
//  Created by Dhawal Mahajan on 24/03/26.
//
import Foundation
final class JSONLoader {

    static func load(filename: String) -> Data {
        let bundle = Bundle(for: Self.self)
               guard let url = bundle.url(forResource: filename, withExtension: "json"),
                     let data = try? Data(contentsOf: url) else {
                   fatalError("❌ Could not load \(filename).json from test bundle")
               }
               return data
    }
}
