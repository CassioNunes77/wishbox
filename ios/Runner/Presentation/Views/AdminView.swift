//
//  AdminView.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import SwiftUI

struct AdminView: View {
    @State private var password = ""
    @State private var isAuthenticated = false
    @State private var stores: [AffiliateStore] = []
    @State private var showingAddStore = false
    
    var body: some View {
        Group {
            if !isAuthenticated {
                authenticationView
            } else {
                storesListView
            }
        }
    }
    
    private var authenticationView: some View {
        VStack(spacing: 20) {
            Text("Área Administrativa")
                .font(.title)
                .fontWeight(.bold)
            
            SecureField("Senha", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: authenticate) {
                Text("Entrar")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var storesListView: some View {
        NavigationStack {
            List {
                ForEach(stores) { store in
                    StoreRow(store: store) {
                        loadStores()
                    }
                }
                .onDelete(perform: deleteStore)
            }
            .navigationTitle("Lojas Afiliadas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddStore = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddStore) {
                AddStoreView {
                    loadStores()
                }
            }
            .onAppear {
                loadStores()
            }
        }
    }
    
    private func authenticate() {
        if password == "admin123" {
            isAuthenticated = true
            password = ""
        }
    }
    
    private func loadStores() {
        stores = StoreService.shared.getAffiliateStores()
    }
    
    private func deleteStore(at offsets: IndexSet) {
        for index in offsets {
            StoreService.shared.removeStore(stores[index].id)
        }
        loadStores()
    }
}

struct StoreRow: View {
    let store: AffiliateStore
    let onUpdate: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(store.displayName)
                    .font(.headline)
                Spacer()
                Text(store.isActive ? "Ativa" : "Inativa")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(store.isActive ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(store.isActive ? .green : .red)
                    .cornerRadius(8)
            }
            
            Text(store.name)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(store.affiliateUrlTemplate)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Button(action: {
                StoreService.shared.toggleStoreStatus(store.id)
                onUpdate()
            }) {
                Text(store.isActive ? "Desativar" : "Ativar")
                    .font(.caption)
                    .foregroundColor(store.isActive ? .red : .green)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddStoreView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var displayName = ""
    @State private var affiliateUrlTemplate = ""
    @State private var apiEndpoint = ""
    
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Nome (ID)", text: $name)
                TextField("Nome de Exibição", text: $displayName)
                TextField("URL Base do Afiliado", text: $affiliateUrlTemplate)
                TextField("API Endpoint (opcional)", text: $apiEndpoint)
            }
            .navigationTitle("Adicionar Loja")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        saveStore()
                    }
                    .disabled(name.isEmpty || displayName.isEmpty || affiliateUrlTemplate.isEmpty)
                }
            }
        }
    }
    
    private func saveStore() {
        let store = AffiliateStore(
            id: UUID().uuidString,
            name: name,
            displayName: displayName,
            affiliateUrlTemplate: affiliateUrlTemplate,
            apiEndpoint: apiEndpoint.isEmpty ? nil : apiEndpoint,
            isActive: true,
            createdAt: ISO8601DateFormatter().string(from: Date()),
            updatedAt: nil
        )
        StoreService.shared.addStore(store)
        onSave()
        dismiss()
    }
}

#Preview {
    AdminView()
}
