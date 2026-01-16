//
//  Product.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import Foundation

// MARK: - Product
struct Product: Codable, Identifiable, Hashable {
    let id: String
    let externalId: String
    let affiliateSource: String
    let name: String
    let description: String
    let price: Double
    let currency: String
    let category: String
    let imageUrl: String
    let productUrlBase: String
    let affiliateUrl: String?
    let rating: Double?
    let reviewCount: Int?
    let tags: [String]
    
    // Formatted price
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = Locale(identifier: "pt_BR")
        return formatter.string(from: NSNumber(value: price)) ?? "R$ \(String(format: "%.2f", price))"
    }
    
    // Formatted rating
    var formattedRating: String {
        guard let rating = rating else { return "N/A" }
        return String(format: "%.1f", rating)
    }
}

// MARK: - GiftSuggestion
struct GiftSuggestion: Codable, Identifiable {
    let id: String
    let giftSearchSessionId: String
    let product: Product
    let relevanceScore: Double
    let reasonText: String
    let position: Int
}

// MARK: - API Response
struct SearchProductsResponse: Codable {
    let success: Bool
    let query: String
    let affiliateUrl: String?
    let products: [Product]
    let count: Int
    let error: String?
}
