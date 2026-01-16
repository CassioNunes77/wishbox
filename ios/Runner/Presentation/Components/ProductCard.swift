//
//  ProductCard.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: product.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(12)
                
                // Favorite Button
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .white)
                        .font(.title3)
                        .padding(8)
                        .background(Color.black.opacity(0.3))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(product.formattedPrice)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                
                if let rating = product.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    ProductCard(
        product: Product(
            id: "1",
            externalId: "1",
            affiliateSource: "mercado_livre",
            name: "Produto Exemplo",
            description: "Descrição",
            price: 99.90,
            currency: "BRL",
            category: "Geral",
            imageUrl: "https://via.placeholder.com/400",
            productUrlBase: "https://example.com",
            affiliateUrl: nil,
            rating: 4.5,
            reviewCount: 100,
            tags: []
        ),
        isFavorite: false,
        onFavoriteToggle: {}
    )
    .padding()
}
