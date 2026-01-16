# 📱 Projeto Xcode - Setup Completo

## 🎯 Guia Rápido

### 1️⃣ Criar Projeto no Xcode (5 minutos)

1. Abra Xcode
2. **File → New → Project**
3. iOS → **App** → Next
4. Preencha:
   - **Product Name:** `WishBox`
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** None
5. Salve em: `/Users/Cassio/Documents/Xcode Projects/WishBox/ios/WishBox/`
6. Clique **Create**

### 2️⃣ Adicionar Arquivos (2 minutos)

1. **Delete:** `ContentView.swift` (gerado pelo Xcode)
2. **Clique direito** no projeto → **Add Files to "WishBox"...**
3. **Navegue** até: `ios/WishBox/WishBox/`
4. **Selecione** a pasta `WishBox` inteira
5. **IMPORTANTE:**
   - ✅ Marque **"Create groups"**
   - ✅ Marque **"Copy items if needed"**
   - ✅ Marque Target **"WishBox"**
6. Clique **Add**

### 3️⃣ Configurar Entry Point (1 minuto)

1. Abra `WishBoxApp.swift`
2. Substitua todo o conteúdo por:

```swift
import SwiftUI

@main
struct WishBoxApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
    }
}
```

### 4️⃣ Configurar Info.plist (2 minutos)

1. Selecione `Info.plist` no projeto
2. Clique com botão direito → **Open As → Source Code**
3. Adicione ANTES do `</dict>` final:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

4. Para desenvolvimento local (opcional):

```xml
<key>BACKEND_URL</key>
<string>http://localhost:3000</string>
```

### 5️⃣ Build Settings (1 minuto)

1. Selecione o **projeto** (topo do Navigator)
2. **Target:** WishBox
3. **General → Deployment Info:**
   - **iOS:** 16.0 ou superior
4. **Build Settings → Swift Language Version:**
   - **Swift Language Version:** Swift 5

### 6️⃣ Compilar (Cmd+B)

Se der erro, verifique:
- ✅ Todos os arquivos Swift estão no Target "WishBox"
- ✅ Não há erros de importação
- ✅ `SplashView` existe e está no projeto

### 7️⃣ Executar (Cmd+R)

1. Selecione um simulador (iPhone 15 Pro)
2. Pressione **Cmd+R**
3. O app deve abrir!

---

## 📁 Estrutura Esperada no Xcode

```
WishBox (Project Root)
├── WishBox (Folder/Group)
│   ├── WishBoxApp.swift (Entry point)
│   ├── App/
│   │   └── WishBoxApp.swift (DELETE se duplicado)
│   ├── Core/
│   │   ├── Constants/
│   │   │   └── AppConstants.swift
│   │   ├── Services/
│   │   │   ├── ApiService.swift
│   │   │   ├── StoreService.swift
│   │   │   └── FavoritesService.swift
│   │   └── Types/
│   │       ├── Product.swift
│   │       └── AffiliateStore.swift
│   └── Presentation/
│       ├── Views/
│       │   ├── SplashView.swift
│       │   ├── HomeView.swift
│       │   ├── SuggestionsView.swift
│       │   ├── ProductDetailView.swift
│       │   ├── FavoritesView.swift
│       │   └── AdminView.swift
│       └── Components/
│           ├── ProductCard.swift
│           ├── ErrorView.swift
│           └── EmptyStateView.swift
├── Info.plist
└── WishBox.entitlements (se houver)
```

---

## 🐛 Troubleshooting

### Erro: "Cannot find type 'SplashView'"
- Verifique que `SplashView.swift` está no Target "WishBox"
- Verifique que não há erros de compilação em `SplashView.swift`

### Erro: "Network request failed"
- Verifique `NSAppTransportSecurity` no `Info.plist`
- Verifique URL do backend em `AppConstants.swift`

### Erro: "Multiple commands produce..."
- Delete arquivos duplicados
- Limpe o build: **Product → Clean Build Folder** (Shift+Cmd+K)

---

## ✅ Checklist Final

- [ ] Projeto Xcode criado
- [ ] Arquivos Swift adicionados (Create groups)
- [ ] `WishBoxApp.swift` configurado com `SplashView()`
- [ ] `Info.plist` tem `NSAppTransportSecurity`
- [ ] iOS Deployment Target: 16.0+
- [ ] Compila sem erros (Cmd+B)
- [ ] Executa no simulador (Cmd+R)

---

## 🎉 Pronto!

Após seguir estes passos, você terá:
- ✅ App iOS nativo funcionando
- ✅ Compartilhando APIs com versão web
- ✅ Estrutura organizada e mantível
