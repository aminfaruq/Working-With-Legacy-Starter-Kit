//
//  APIManager.swift
//  QuotesAppLegacy
//
//  Created by Amin faruq on 03/11/26.
//

import Foundation

// Office-style legacy networking singleton:
// Provides reusable generic GET & POST helpers with a hardcoded baseURL,
// but remains a concrete singleton tightly coupled to URLSession.shared without protocols or DI.
class APIManager {
    
    static let shared = APIManager()
    
    private let baseURL = "https://dummyjson.com"
    
    private init() {}
    
    // MARK: - Reusable Generic GET
    
    func get<T: Decodable>(
        endpoint: String,
        queryParams: [String: String]? = nil,
        completion: @escaping (T?, Error?) -> Void
    ) {
        var urlString = baseURL + endpoint
        
        if let queryParams = queryParams, !queryParams.isEmpty {
            var components = URLComponents(string: urlString)!
            components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            urlString = components.url!.absoluteString
        }
        
        guard let url = URL(string: urlString) else {
            let err = NSError(domain: "APIManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
            completion(nil, err)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        print("🌐 [GET] \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [GET ERROR] \(url.absoluteString): \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 [GET STATUS] \(httpResponse.statusCode) - \(url.absoluteString)")
            }
            
            guard let data = data else {
                let noDataErr = NSError(domain: "APIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned from server"])
                completion(nil, noDataErr)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(decoded, nil)
            } catch {
                print("❌ [DECODE ERROR] \(url.absoluteString): \(error)")
                completion(nil, error)
            }
        }.resume()
    }
    
    // MARK: - Reusable Generic POST
    
    func post<T: Decodable>(
        endpoint: String,
        body: [String: Any],
        completion: @escaping (T?, Error?) -> Void
    ) {
        let urlString = baseURL + endpoint
        guard let url = URL(string: urlString) else {
            let err = NSError(domain: "APIManager", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL: \(urlString)"])
            completion(nil, err)
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
            completion(nil, error)
            return
        }
        
        print("🌐 [POST] \(url.absoluteString) | Body: \(body)")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [POST ERROR] \(url.absoluteString): \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 [POST STATUS] \(httpResponse.statusCode) - \(url.absoluteString)")
            }
            
            guard let data = data else {
                let noDataErr = NSError(domain: "APIManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned from server"])
                completion(nil, noDataErr)
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(decoded, nil)
            } catch {
                print("❌ [DECODE ERROR] \(url.absoluteString): \(error)")
                completion(nil, error)
            }
        }.resume()
    }
    
    // MARK: - Feature Specific Endpoints (Accumulated inside the monolithic APIManager)
    
    func fetchQuotes(completion: @escaping ([QuoteResponse]?, Error?) -> Void) {
        get(endpoint: "/quotes") { (response: QuotesListResponse?, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(response?.quotes, nil)
        }
    }
}
