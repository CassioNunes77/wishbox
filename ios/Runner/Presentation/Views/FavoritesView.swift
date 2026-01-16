//
//  FavoritesView.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import SwiftUI

struct FavoritesView: View {
    @State private var favorites: [Product] = []
    
    var body: some View {
        NavigationStack {
            Group {
                if favorites.isEmpty {
                    EmptyStateView(message: "Você ainda não tem produtos favoritos.")
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(favorites) { product in
                                NavigationLink(destination: ProductDetailView(product: product)) {
                                    ProductCard(
                                        product: product,
                                        isFavorite: true
                                    ) {
                                        removeFavorite(product)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Favoritos")
            .onAppear {
                loadFavorites()
            }
        }
    }
    
    private func loadFavorites() {
        favorites = FavoritesService.shared.getFavorites()
    }
    
    private func removeFavorite(_ product: Product) {
        FavoritesService.shared.removeFavorite(product.id)
        loadFavorites()
    }
}

#Preview {
    FavoritesView()
}
