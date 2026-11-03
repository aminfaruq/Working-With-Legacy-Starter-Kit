//
//  APIManager+Quotes.swift
//  QuotesAppLegacy
//
//  Created by Amin faruq on 03/11/26.
//

import Foundation

/// Typical corporate legacy pattern:
/// Splitting features into `APIManager+Feature.swift` extensions so that the base `APIManager.swift`
/// file doesn't grow into thousands of lines, while still keeping the global singleton anti-pattern.
extension APIManager {
    
    func fetchQuotes(completion: @escaping ([QuoteResponse]?, Error?) -> Void) {
        get(endpoint: "/quotes") { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let response = response, response.statusCode == 200 else {
                let statusErr = NSError(
                    domain: "APIManagerError",
                    code: response?.statusCode ?? -1,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP Status Error: \(response?.statusCode ?? -1)"]
                )
                completion(nil, statusErr)
                return
            }
            
            guard let data = data else {
                let noDataErr = NSError(domain: "APIManagerError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Empty payload"])
                completion(nil, noDataErr)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(QuotesListResponse.self, from: data)
                completion(decoded.quotes, nil)
            } catch {
                print("❌ [ENTERPRISE DECODER] /quotes error: \(error)")
                completion(nil, error)
            }
        }
    }
}
