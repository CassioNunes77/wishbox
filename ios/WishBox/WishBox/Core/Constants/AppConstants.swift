//
//  AppConstants.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import Foundation

struct AppConstants {
    // Backend API - usa Netlify Function em produção
    // Para desenvolvimento local, configurar via Info.plist ou build settings
    static var backendBaseUrl: String {
        #if DEBUG
        return Bundle.main.object(forInfoDictionaryKey: "BACKEND_URL") as? String ?? ""
        #else
        return "" // Usa função Netlify (relativa)
        #endif
    }
    
    // API Endpoint
    static var apiSearchUrl: String {
        if backendBaseUrl.isEmpty {
            // Produção: usar função Netlify
            // Será substituído pela URL completa do Netlify
            return "https://wish2box.netlify.app/api/search"
        } else {
            // Desenvolvimento: usar backend separado
            let baseUrl = backendBaseUrl.hasSuffix("/") ? String(backendBaseUrl.dropLast()) : backendBaseUrl
            return "\(baseUrl)/api/search"
        }
    }
    
    // Relation Types
    static let relationTypes = [
        "Namorado(a)",
        "Marido/Esposa",
        "Amigo(a)",
        "Filho(a)",
        "Mãe/Pai",
        "Chefe",
        "Colega de Trabalho",
        "Outro"
    ]
    
    // Age Ranges
    static let ageRanges = [
        "0-5 anos",
        "6-12 anos",
        "13-17 anos",
        "18-25 anos",
        "26-40 anos",
        "40+ anos"
    ]
    
    // Genders
    static let genders = [
        "Masculino",
        "Feminino",
        "Outro",
        "Prefiro não informar"
    ]
    
    // Occasions
    static let occasions = [
        "Aniversário",
        "Formatura",
        "Casamento",
        "Dia das Mães",
        "Dia dos Pais",
        "Natal",
        "Amigo Secreto",
        "Dia dos Namorados",
        "Outro"
    ]
    
    // Gift Types
    static let giftTypes = [
        "Útil no dia a dia",
        "Romântico",
        "Divertido",
        "Tecnológico",
        "Experiência"
    ]
    
    // Currency
    static let defaultCurrency = "BRL"
    static let currencySymbol = "R$"
}
