//
//  ApiService.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import Foundation

enum ApiError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int, String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida. Verifique a configuração da API."
        case .noData:
            return "Nenhum dado recebido do servidor."
        case .decodingError:
            return "Erro ao processar resposta do servidor."
        case .serverError(let code, let message):
            return "Erro do servidor (\(code)): \(message)"
        case .networkError(let error):
            return "Erro de conexão: \(error.localizedDescription)"
        }
    }
}

class ApiService {
    static let shared = ApiService()
    
    private init() {}
    
    /// Busca produtos da Magazine Luiza via backend/Netlify Function
    func searchProducts(
        query: String,
        limit: Int = 20,
        affiliateUrl: String? = nil
    ) async throws -> [Product] {
        guard var urlComponents = URLComponents(string: AppConstants.apiSearchUrl) else {
            throw ApiError.invalidURL
        }
        
        var queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if let affiliateUrl = affiliateUrl {
            queryItems.append(URLQueryItem(name: "affiliateUrl", value: affiliateUrl))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw ApiError.invalidURL
        }
        
        print("=== ApiService: Searching for: \(query)")
        print("=== ApiService: URL: \(url.absoluteString)")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ApiError.noData
            }
            
            print("=== ApiService: Response status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode != 200 {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ApiError.serverError(httpResponse.statusCode, errorMessage)
            }
            
            let decoder = JSONDecoder()
            let apiResponse = try decoder.decode(SearchProductsResponse.self, from: data)
            
            if apiResponse.success {
                print("=== ApiService: Found \(apiResponse.products.count) products")
                return apiResponse.products
            } else {
                throw ApiError.serverError(500, apiResponse.error ?? "Unknown error")
            }
        } catch let error as DecodingError {
            print("=== ApiService: Decoding error: \(error)")
            if case .keyNotFound(let key, let context) = error {
                print("=== ApiService: Missing key '\(key.stringValue)' in \(context.debugDescription)")
            }
            if case .typeMismatch(let type, let context) = error {
                print("=== ApiService: Type mismatch for type \(type) in \(context.debugDescription)")
            }
            if case .valueNotFound(let type, let context) = error {
                print("=== ApiService: Value not found for type \(type) in \(context.debugDescription)")
            }
            if case .dataCorrupted(let context) = error {
                print("=== ApiService: Data corrupted: \(context.debugDescription)")
                if let dataString = String(data: data, encoding: .utf8) {
                    print("=== ApiService: Response data: \(dataString.prefix(500))")
                }
            }
            throw ApiError.decodingError
        } catch let error as ApiError {
            throw error
        } catch {
            print("=== ApiService: Network error: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                print("=== ApiService: URLError code: \(urlError.code.rawValue)")
                print("=== ApiService: URLError description: \(urlError.localizedDescription)")
            }
            throw ApiError.networkError(error)
        }
    }
}
