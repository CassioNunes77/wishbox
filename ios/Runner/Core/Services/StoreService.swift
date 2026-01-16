//
//  StoreService.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import Foundation

class StoreService {
    static let shared = StoreService()
    private let storesKey = "affiliate_stores"
    
    private init() {}
    
    /// Carrega lojas afiliadas do UserDefaults
    func getAffiliateStores() -> [AffiliateStore] {
        guard let data = UserDefaults.standard.data(forKey: storesKey),
              let stores = try? JSONDecoder().decode([AffiliateStore].self, from: data) else {
            return getDefaultStores()
        }
        return stores
    }
    
    /// Retorna apenas lojas ativas
    func getActiveStores() -> [AffiliateStore] {
        return getAffiliateStores().filter { $0.isActive }
    }
    
    /// Salva lojas afiliadas no UserDefaults
    func saveStores(_ stores: [AffiliateStore]) {
        if let data = try? JSONEncoder().encode(stores) {
            UserDefaults.standard.set(data, forKey: storesKey)
        }
    }
    
    /// Adiciona uma nova loja
    func addStore(_ store: AffiliateStore) {
        var stores = getAffiliateStores()
        stores.append(store)
        saveStores(stores)
    }
    
    /// Atualiza uma loja existente
    func updateStore(_ store: AffiliateStore) {
        var stores = getAffiliateStores()
        if let index = stores.firstIndex(where: { $0.id == store.id }) {
            stores[index] = store
            saveStores(stores)
        }
    }
    
    /// Remove uma loja
    func removeStore(_ id: String) {
        var stores = getAffiliateStores()
        stores.removeAll { $0.id == id }
        saveStores(stores)
    }
    
    /// Alterna status de uma loja
    func toggleStoreStatus(_ id: String) {
        var stores = getAffiliateStores()
        if let index = stores.firstIndex(where: { $0.id == id }) {
            let store = stores[index]
            let updatedStore = AffiliateStore(
                id: store.id,
                name: store.name,
                displayName: store.displayName,
                affiliateUrlTemplate: store.affiliateUrlTemplate,
                apiEndpoint: store.apiEndpoint,
                isActive: !store.isActive,
                createdAt: store.createdAt,
                updatedAt: ISO8601DateFormatter().string(from: Date())
            )
            stores[index] = updatedStore
            saveStores(stores)
        }
    }
    
    /// Lojas padrão (para inicialização)
    // TODO: REMOVER TESTE - Link de afiliado temporário para teste
    // Para remover: delete esta constante TEST_AFFILIATE_URL e use string vazia
    private let TEST_AFFILIATE_URL = "https://www.magazinevoce.com.br/elislecio/"
    
    private func getDefaultStores() -> [AffiliateStore] {
        let now = ISO8601DateFormatter().string(from: Date())
        return [
            AffiliateStore(
                id: "magazine_luiza",
                name: "magazine_luiza",
                displayName: "Magazine Luiza",
                affiliateUrlTemplate: TEST_AFFILIATE_URL, // TODO: REMOVER TESTE - Usar string vazia quando não precisar mais
                apiEndpoint: nil,
                isActive: true,
                createdAt: now,
                updatedAt: nil
            )
        ]
    }
}
