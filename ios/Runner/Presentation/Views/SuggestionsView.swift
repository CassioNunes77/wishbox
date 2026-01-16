//
//  SuggestionsView.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import SwiftUI

struct SuggestionsView: View {
    let query: String
    let minPrice: Int
    let maxPrice: Int
    let isSelfGift: Bool
    
    @State private var products: [Product] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var favoriteIds = Set<String>()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Buscando produtos...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                ErrorView(message: error) {
                    loadProducts()
                }
            } else if products.isEmpty {
                EmptyStateView(message: "Nenhum produto encontrado. Tente outra busca.")
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(products) { product in
                            NavigationLink(destination: ProductDetailView(product: product)) {
                                ProductCard(product: product, isFavorite: favoriteIds.contains(product.id)) {
                                    toggleFavorite(product)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Resultados")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadProducts()
            loadFavorites()
        }
    }
    
    private func loadProducts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // Buscar loja ativa
                let activeStores = StoreService.shared.getActiveStores()
                let affiliateUrl = activeStores.first?.affiliateUrlTemplate
                
                let fetchedProducts = try await ApiService.shared.searchProducts(
                    query: query,
                    limit: 30,
                    affiliateUrl: affiliateUrl
                )
                
                // Filtrar por preço
                let filteredProducts = fetchedProducts.filter { product in
                    product.price >= Double(minPrice) && product.price <= Double(maxPrice)
                }
                
                await MainActor.run {
                    self.products = filteredProducts
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    let errorMsg: String
                    if let apiError = error as? ApiError {
                        errorMsg = apiError.errorDescription ?? "Erro desconhecido"
                    } else {
                        errorMsg = error.localizedDescription
                    }
                    self.errorMessage = "Erro ao carregar produtos: \(errorMsg)"
                    self.isLoading = false
                }
                print("=== SuggestionsView: Erro ao carregar produtos: \(error)")
            }
        }
    }
    
    private func loadFavorites() {
        let favorites = FavoritesService.shared.getFavorites()
        favoriteIds = Set(favorites.map { $0.id })
    }
    
    private func toggleFavorite(_ product: Product) {
        FavoritesService.shared.toggleFavorite(product)
        loadFavorites()
    }
}

#Preview {
    NavigationStack {
        SuggestionsView(query: "café", minPrice: 50, maxPrice: 500, isSelfGift: false)
    }
}
