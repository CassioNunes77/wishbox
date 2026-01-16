//
//  FavoritesService.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import Foundation

class FavoritesService {
    static let shared = FavoritesService()
    private let favoritesKey = "favorite_products"
    
    private init() {}
    
    /// Carrega produtos favoritos do UserDefaults
    func getFavorites() -> [Product] {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey),
              let products = try? JSONDecoder().decode([Product].self, from: data) else {
            return []
        }
        return products
    }
    
    /// Verifica se um produto está nos favoritos
    func isFavorite(_ productId: String) -> Bool {
        return getFavorites().contains { $0.id == productId }
    }
    
    /// Adiciona produto aos favoritos
    func addFavorite(_ product: Product) {
        var favorites = getFavorites()
        if !favorites.contains(where: { $0.id == product.id }) {
            favorites.append(product)
            saveFavorites(favorites)
        }
    }
    
    /// Remove produto dos favoritos
    func removeFavorite(_ productId: String) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == productId }
        saveFavorites(favorites)
    }
    
    /// Alterna status de favorito
    func toggleFavorite(_ product: Product) {
        if isFavorite(product.id) {
            removeFavorite(product.id)
        } else {
            addFavorite(product)
        }
    }
    
    /// Salva favoritos no UserDefaults
    private func saveFavorites(_ products: [Product]) {
        if let data = try? JSONEncoder().encode(products) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
}
