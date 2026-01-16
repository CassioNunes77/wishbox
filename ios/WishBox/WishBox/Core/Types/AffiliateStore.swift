//
//  AffiliateStore.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import Foundation

// MARK: - AffiliateStore
struct AffiliateStore: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let displayName: String
    let affiliateUrlTemplate: String
    let apiEndpoint: String?
    let isActive: Bool
    let createdAt: String
    let updatedAt: String?
}
