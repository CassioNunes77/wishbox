//
//  HomeView.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import SwiftUI

struct HomeView: View {
    @State private var searchQuery = ""
    @State private var minPrice: Double = 50
    @State private var maxPrice: Double = 500
    @State private var isSelfGift = false
    @State private var navigateToSuggestions = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("WishBox")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.purple)
                    
                    Text("Encontre o presente ideal")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                .padding(.bottom, 30)
                
                // Search Section
                VStack(spacing: 20) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("O que você está procurando?", text: $searchQuery)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Price Range
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Faixa de Preço")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Text("R$ \(Int(minPrice))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("R$ \(Int(maxPrice))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Slider(value: $minPrice, in: 0...1000, step: 10)
                                Slider(value: $maxPrice, in: 0...1000, step: 10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Self Gift Toggle
                    Toggle("Presente para mim mesmo", isOn: $isSelfGift)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    
                    // Search Button
                    Button(action: {
                        if !searchQuery.isEmpty {
                            navigateToSuggestions = true
                        }
                    }) {
                        Text("Buscar Presentes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(searchQuery.isEmpty ? Color.gray : Color.purple)
                            .cornerRadius(12)
                    }
                    .disabled(searchQuery.isEmpty)
                    .padding(.top, 10)
                }
                .padding()
                
                Spacer()
            }
            .navigationDestination(isPresented: $navigateToSuggestions) {
                SuggestionsView(
                    query: searchQuery,
                    minPrice: Int(minPrice),
                    maxPrice: Int(maxPrice),
                    isSelfGift: isSelfGift
                )
            }
        }
    }
}

#Preview {
    HomeView()
}
