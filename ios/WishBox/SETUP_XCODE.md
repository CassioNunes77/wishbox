# 📱 Setup do Projeto Xcode

## 🎯 Como Criar o Projeto Xcode

### Opção 1: Usar Projeto Existente

Se você já tem um projeto Xcode (`WishBox.xcodeproj`), siga:

1. **Adicione os arquivos ao projeto:**
   - Abra o projeto no Xcode
   - Clique com botão direito na pasta do projeto
   - Selecione "Add Files to WishBox..."
   - Selecione a pasta `ios/WishBox/WishBox/`
   - Certifique-se de marcar "Create groups" (não "Create folder references")
   - Clique em "Add"

2. **Configure Build Settings:**
   - Selecione o projeto no Navigator
   - Target: WishBox → Build Settings
   - Certifique-se que "Deployment Target" é iOS 16.0+

3. **Configure Info.plist:**
   - Adicione chave `BACKEND_URL` (opcional para desenvolvimento local)

### Opção 2: Criar Novo Projeto

1. **Criar projeto no Xcode:**
   ```
   File → New → Project
   → iOS → App
   → Product Name: WishBox
   → Interface: SwiftUI
   → Language: Swift
   → Storage: None (usaremos UserDefaults)
   ```

2. **Adicionar arquivos:**
   - Arraste a pasta `ios/WishBox/WishBox/` para o projeto
   - Selecione "Copy items if needed"
   - Selecione "Create groups"

3. **Substituir arquivo gerado:**
   - Delete `ContentView.swift` gerado
   - Use `SplashView.swift` como entry point

4. **Configurar App.swift:**
   - Substitua o conteúdo por `WishBoxApp.swift`

## 📋 Estrutura de Pastas no Xcode

```
WishBox/
├── App/
│   └── WishBoxApp.swift
├── Core/
│   ├── Constants/
│   │   └── AppConstants.swift
│   ├── Services/
│   │   ├── ApiService.swift
│   │   ├── StoreService.swift
│   │   └── FavoritesService.swift
│   └── Types/
│       ├── Product.swift
│       └── AffiliateStore.swift
└── Presentation/
    ├── Views/
    │   ├── SplashView.swift
    │   ├── HomeView.swift
    │   ├── SuggestionsView.swift
    │   ├── ProductDetailView.swift
    │   ├── FavoritesView.swift
    │   └── AdminView.swift
    └── Components/
        ├── ProductCard.swift
        ├── ErrorView.swift
        └── EmptyStateView.swift
```

## ⚙️ Configurações Necessárias

### Info.plist

Adicione (opcional para desenvolvimento local):

```xml
<key>BACKEND_URL</key>
<string>http://localhost:3000</string>
```

### Build Settings

- **Deployment Target**: iOS 16.0+
- **Swift Version**: 5.9+

## ✅ Checklist

- [ ] Projeto Xcode criado ou existente configurado
- [ ] Todos os arquivos Swift adicionados ao projeto
- [ ] Estrutura de pastas organizada no Xcode
- [ ] Build Settings configurados (iOS 16.0+)
- [ ] Info.plist configurado (opcional)
- [ ] Projeto compila sem erros

## 🚀 Próximos Passos

1. Compile o projeto: Cmd+B
2. Execute no simulador: Cmd+R
3. Teste as funcionalidades
