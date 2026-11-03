//
//  APIManager.swift
//  QuotesAppLegacy
//
//  Created by Amin faruq on 03/11/26.
//

import Foundation

// Legacy networking singleton with foundational HTTP transport methods (returning raw Data & HTTPURLResponse)
// while keeping feature convenience methods intact for backward compatibility.
class APIManager {
    
    static let shared = APIManager()
    
    private let baseURL = "https://dummyjson.com"
    
    private init() {}
    
    // MARK: - Reusable Transport GET (Exposes raw Data & HTTPURLResponse)
    
    func get(
        endpoint: String,
        queryParams: [String: String]? = nil,
        completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) {
        var urlString = baseURL + endpoint
        
        if let queryParams = queryParams, !queryParams.isEmpty {
            var components = URLComponents(string: urlString)!
            components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlString = components.url!.absoluteString
        }
        
        guard let url = URL(string: urlString) else {
            let err = NSError(domain: "APIManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
            completion(nil, nil, err)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        print("🌐 [GET] \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            if let statusCode = httpResponse?.statusCode {
                print("📥 [GET STATUS] \(statusCode) - \(url.absoluteString)")
            }
            if let error = error {
                print("❌ [GET ERROR] \(url.absoluteString): \(error.localizedDescription)")
            }
            completion(data, httpResponse, error)
        }.resume()
    }
    
    // MARK: - Reusable Transport POST (Exposes raw Data & HTTPURLResponse)
    
    func post(
        endpoint: String,
        body: [String: Any],
        completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) {
        let urlString = baseURL + endpoint
        guard let url = URL(string: urlString) else {
            let err = NSError(domain: "APIManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
            completion(nil, nil, err)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ [POST BODY ERROR] Failed to serialize JSON body: \(error)")
            completion(nil, nil, error)
            return
        }
        
        print("🌐 [POST] \(url.absoluteString) | Body: \(body)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            let httpResponse = response as? HTTPURLResponse
            if let statusCode = httpResponse?.statusCode {
                print("📥 [POST STATUS] \(statusCode) - \(url.absoluteString)")
            }
            if let error = error {
                print("❌ [POST ERROR] \(url.absoluteString): \(error.localizedDescription)")
            }
            completion(data, httpResponse, error)
        }.resume()
    }
    
    // MARK: - Legacy Feature Endpoints (Quotes)
    // Decodes using the raw get transport without breaking existing callers
    
    func fetchQuotes(completion: @escaping ([QuoteResponse]?, Error?) -> Void) {
        get(endpoint: "/quotes") { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let response = response, response.statusCode == 200 else {
                let statusErr = NSError(
                    domain: "APIManager",
                    code: response?.statusCode ?? -1,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid server response: \(response?.statusCode ?? -1)"]
                )
                completion(nil, statusErr)
                return
            }
            
            guard let data = data else {
                let noDataErr = NSError(domain: "APIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned from server"])
                completion(nil, noDataErr)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(QuotesListResponse.self, from: data)
                completion(decoded.quotes, nil)
            } catch {
                print("❌ [DECODE ERROR] /quotes: \(error)")
                completion(nil, error)
            }
        }
    }
}
