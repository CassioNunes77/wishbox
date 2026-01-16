//
//  SplashView.swift
//  WishBox
//
//  Created on 16/01/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        Group {
            if isActive {
                HomeView()
            } else {
                ZStack {
                    Color.purple
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.white)
                        
                        Text("WishBox")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Presentes Ideais")
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
