//
//  QuoteResponse.swift
//  QuotesAppLegacy
//
//  Created by Amin faruq on 03/11/26.
//

import Foundation

// Top-level JSON wrapper returned by https://dummyjson.com/quotes
struct QuotesListResponse: Codable {
    let quotes: [QuoteResponse]
    let total: Int
    let skip: Int
    let limit: Int
}

// Raw network DTO used directly across the app (including the UI layer)
struct QuoteResponse: Codable {
    let id: Int
    let quote: String
    let author: String
}
