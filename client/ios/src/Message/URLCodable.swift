//
//  URLCodable.swift
//  WalletSegue
//
//  Created by Jungho Bang on 6/13/22.
//

import Foundation

protocol URLCodable: Codable {
    func asURL(to base: URL) throws -> URL
    static func decode(_ url: URL) throws -> Self
}

extension URLCodable {
    func asURL(to base: URL) throws -> URL {
        let data = try JSONEncoder().encode(self)
        let encodedString = data.base64EncodedString()
        
        var urlComponents = URLComponents(url: base, resolvingAgainstBaseURL: true)
        urlComponents?.path = "wsegue"
        urlComponents?.queryItems = [URLQueryItem(name: "p", value: encodedString)]
        
        guard let url = urlComponents?.url else {
            throw WalletSegueError.urlEncodingFailed
        }
        
        return url
    }
    
    static func decode(_ url: URL) throws -> Self {
        guard
            let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
            urlComponents.path == "wsegue",
            let queryItem = urlComponents.queryItems?.first(where: { $0.value == "p" }),
            let encodedString = queryItem.value
        else {
            throw WalletSegueError.urlEncodingFailed
        }
        
        guard let data = Data(base64Encoded: encodedString) else {
            throw WalletSegueError.notBase64Encoded
        }
        
        return try JSONDecoder().decode(Self.self, from: data)
    }
}
