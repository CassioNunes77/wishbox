//
//  ProductDetailView.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import SwiftUI

struct ProductDetailView: View {
    let product: Product
    @State private var isFavorite = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image
                AsyncImage(url: URL(string: product.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 300)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                            .frame(height: 300)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                
                VStack(alignment: .leading, spacing: 16) {
                    // Title and Favorite
                    HStack {
                        Text(product.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            toggleFavorite()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(isFavorite ? .red : .gray)
                                .font(.title2)
                        }
                    }
                    
                    // Price
                    Text(product.formattedPrice)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    // Rating
                    if let rating = product.rating, let reviews = product.reviewCount {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", rating))
                            Text("(\(reviews) avaliações)")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Description
                    Text(product.description)
                        .foregroundColor(.secondary)
                    
                    // Tags
                    if !product.tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(product.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.purple.opacity(0.2))
                                        .foregroundColor(.purple)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    
                    // View in Store Button
                    if let affiliateUrl = product.affiliateUrl, let url = URL(string: affiliateUrl) {
                        Link(destination: url) {
                            Text("Ver na Loja")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFavorite = FavoritesService.shared.isFavorite(product.id)
        }
    }
    
    private func toggleFavorite() {
        FavoritesService.shared.toggleFavorite(product)
        isFavorite = FavoritesService.shared.isFavorite(product.id)
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(product: Product(
            id: "1",
            externalId: "1",
            affiliateSource: "magazine_luiza",
            name: "Produto Exemplo",
            description: "Descrição do produto",
            price: 99.90,
            currency: "BRL",
            category: "Geral",
            imageUrl: "https://via.placeholder.com/400",
            productUrlBase: "https://example.com",
            affiliateUrl: "https://example.com",
            rating: 4.5,
            reviewCount: 100,
            tags: ["Útil", "Qualidade"]
        ))
    }
}
