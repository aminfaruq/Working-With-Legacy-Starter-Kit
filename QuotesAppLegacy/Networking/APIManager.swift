//
//  APIManager.swift
//  QuotesAppLegacy
//
//  Created by Amin faruq on 03/11/26.
//

import Foundation

/// Enterprise Legacy API Manager
/// Monolithic God-Class Singleton responsible for all HTTP traffic, headers, authentication tokens,
/// logging, and request execution across the entire application.
///
/// NOTE: Due to compliance and security policies, all features must route network requests
/// through this manager. Direct instantiation of URLSession is prohibited by company guidelines.
class APIManager {
    
    // MARK: - Global Monolithic Singleton (Zero Protocol / Zero DI)
    static let shared = APIManager()
    
    // MARK: - Enterprise Environment & Configurations
    let baseURL = "https://dummyjson.com"
    private let defaultTimeout: TimeInterval = 30.0
    
    // Mutable shared state inside singleton (Classic Enterprise Legacy Code Smell)
    var authToken: String? = "legacy_enterprise_bearer_token_xyz"
    var clientVersion: String = "2.4.0-build.104"
    var deviceId: String = UUID().uuidString
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = defaultTimeout
        configuration.timeoutIntervalForResource = defaultTimeout
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Core Enterprise Request Builder (Common Corporate Headers)
    
    private func buildRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("iOS", forHTTPHeaderField: "X-Platform")
        request.setValue(clientVersion, forHTTPHeaderField: "X-App-Version")
        request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")
        
        // Inject auth token if available (Simulating Corporate OAuth/Bearer Token)
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    // MARK: - Core Transport GET (Exposes Raw Data & HTTPURLResponse)
    
    func get(
        endpoint: String,
        headers: [String: String]? = nil,
        queryParams: [String: String]? = nil,
        completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) {
        var urlString = baseURL + endpoint
        
        if let queryParams = queryParams, !queryParams.isEmpty {
            guard var components = URLComponents(string: urlString) else {
                let err = NSError(domain: "APIManagerError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Malformed URL: \(urlString)"])
                completion(nil, nil, err)
                return
            }
            components.queryItems = queryParams.map { URLQueryItem(name: $0.key, value: $0.value) }
            if let validUrl = components.url {
                urlString = validUrl.absoluteString
            }
        }
        
        guard let url = URL(string: urlString) else {
            let err = NSError(domain: "APIManagerError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string: \(urlString)"])
            completion(nil, nil, err)
            return
        }
        
        var request = buildRequest(url: url, method: "GET")
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        logRequest(request)
        
        session.dataTask(with: request) { [weak self] data, response, error in
            let httpResponse = response as? HTTPURLResponse
            self?.logResponse(httpResponse, data: data, error: error, url: url)
            completion(data, httpResponse, error)
        }.resume()
    }
    
    // MARK: - Core Transport POST (Exposes Raw Data & HTTPURLResponse)
    
    func post(
        endpoint: String,
        body: [String: Any],
        headers: [String: String]? = nil,
        completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void
    ) {
        let urlString = baseURL + endpoint
        guard let url = URL(string: urlString) else {
            let err = NSError(domain: "APIManagerError", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string: \(urlString)"])
            completion(nil, nil, err)
            return
        }
        
        var request = buildRequest(url: url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("❌ [ENTERPRISE API] Failed to serialize JSON body: \(error)")
            completion(nil, nil, error)
            return
        }
        
        logRequest(request, body: body)
        
        session.dataTask(with: request) { [weak self] data, response, error in
            let httpResponse = response as? HTTPURLResponse
            self?.logResponse(httpResponse, data: data, error: error, url: url)
            completion(data, httpResponse, error)
        }.resume()
    }
    
    // MARK: - Corporate Logging Utilities
    
    private func logRequest(_ request: URLRequest, body: [String: Any]? = nil) {
        print("🌐 [ENTERPRISE HTTP \(request.httpMethod ?? "REQ")] \(request.url?.absoluteString ?? "")")
        if let headers = request.allHTTPHeaderFields {
            print("   Headers: \(headers)")
        }
        if let body = body {
            print("   Body: \(body)")
        }
    }
    
    private func logResponse(_ response: HTTPURLResponse?, data: Data?, error: Error?, url: URL) {
        if let statusCode = response?.statusCode {
            print("📥 [ENTERPRISE HTTP \(statusCode)] \(url.absoluteString) | Bytes: \(data?.count ?? 0)")
        }
        if let error = error {
            print("❌ [ENTERPRISE HTTP ERROR] \(url.absoluteString): \(error.localizedDescription)")
        }
    }
}
