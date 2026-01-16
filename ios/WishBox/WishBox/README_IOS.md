# 📱 WishBox iOS

Versão iOS nativa do WishBox, compartilhando lógica e APIs com a versão web.

## 📁 Estrutura do Projeto

```
ios/WishBox/WishBox/
├── App/
│   └── WishBoxApp.swift           # Entry point
├── Core/
│   ├── Constants/
│   │   └── AppConstants.swift     # Constantes (compartilhadas com web)
│   ├── Services/
│   │   ├── ApiService.swift       # API service (usa mesma API do web)
│   │   ├── StoreService.swift     # Gerenciamento de lojas
│   │   └── FavoritesService.swift # Gerenciamento de favoritos
│   └── Types/
│       ├── Product.swift          # Modelo Product
│       └── AffiliateStore.swift   # Modelo AffiliateStore
└── Presentation/
    ├── Views/
    │   ├── SplashView.swift       # Tela inicial
    │   ├── HomeView.swift         # Tela principal de busca
    │   ├── SuggestionsView.swift  # Lista de produtos
    │   ├── ProductDetailView.swift # Detalhes do produto
    │   ├── FavoritesView.swift    # Lista de favoritos
    │   └── AdminView.swift        # Área administrativa
    └── Components/
        ├── ProductCard.swift      # Card de produto
        ├── ErrorView.swift        # Tela de erro
        └── EmptyStateView.swift   # Estado vazio
```

## 🔗 Compartilhamento com Web

### APIs Compartilhadas
- ✅ Mesma API: `/api/search` (Netlify Function)
- ✅ Mesmos tipos: Product, AffiliateStore
- ✅ Mesma lógica de busca e filtros

### Dados Compartilhados
- ❌ Storage local separado (UserDefaults vs localStorage)
- ✅ Mesma estrutura de dados JSON

## 🚀 Como Usar

### 1. Configurar Backend URL (Opcional)

Para desenvolvimento local, configure a URL do backend no `Info.plist`:

```xml
<key>BACKEND_URL</key>
<string>http://localhost:3000</string>
```

Em produção, o app usa automaticamente a função Netlify.

### 2. Compilar no Xcode

1. Abra `ios/WishBox/WishBox.xcodeproj` no Xcode
2. Selecione um simulador ou dispositivo
3. Pressione Cmd+R para compilar e executar

## 📋 Telas Implementadas

- ✅ Splash Screen
- ✅ Home (Busca)
- ✅ Lista de Sugestões
- ✅ Detalhes do Produto
- ✅ Favoritos
- ✅ Área Administrativa

## 🔄 Sincronização com Web

### Quando alterar a web:

1. **Tipos (TypeScript)**: Atualizar também os modelos Swift
2. **APIs**: Usar as mesmas URLs e parâmetros
3. **Lógica de negócio**: Manter consistência entre web e iOS

### Exemplo de Sincronização:

**Web (TypeScript):**
```typescript
interface Product {
  id: string;
  name: string;
  price: number;
  // ...
}
```

**iOS (Swift):**
```swift
struct Product: Codable {
    let id: String
    let name: String
    let price: Double
    // ...
}
```

## 🔐 Autenticação Admin

Senha padrão: `admin123`

## 📝 Notas

- O app usa UserDefaults para armazenamento local
- Para compartilhar dados entre web e iOS, usar API compartilhada
- Imagens são carregadas via AsyncImage (SwiftUI)
