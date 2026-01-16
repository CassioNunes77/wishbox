# 📱 WishBox iOS App

App iOS nativo do WishBox usando SwiftUI, compartilhando lógica e APIs com a versão web Next.js.

## 🎯 Visão Geral

Esta é a versão iOS nativa do WishBox, construída para:
- ✅ Compartilhar APIs com a versão web (Netlify Functions)
- ✅ Usar mesma estrutura de dados
- ✅ Manter consistência de funcionalidades

## 📁 Estrutura

A estrutura segue o mesmo padrão da versão OLD (Flutter):

```
WishBox/
├── App/                    # Entry point
├── Core/                   # Lógica core
│   ├── Constants/          # Constantes (AppConstants)
│   ├── Services/           # Serviços (API, Store, Favorites)
│   └── Types/              # Modelos (Product, Store)
└── Presentation/           # UI
    ├── Views/              # Telas principais
    └── Components/         # Componentes reutilizáveis
```

## 🚀 Setup

### Requisitos
- Xcode 15+
- iOS 16+
- Swift 5.9+

### Instruções

1. Abra o projeto no Xcode:
   ```bash
   open ios/WishBox/WishBox.xcodeproj
   ```

2. Configure o Backend URL (opcional):
   - Para desenvolvimento local, adicione no `Info.plist`:
     ```xml
     <key>BACKEND_URL</key>
     <string>http://localhost:3000</string>
     ```
   - Em produção, o app usa automaticamente a função Netlify

3. Compile e execute:
   - Selecione um simulador ou dispositivo
   - Pressione Cmd+R

## 🔗 Integração com Web

### APIs Compartilhadas

O app iOS usa as **mesmas APIs** que a versão web:

- **Busca de produtos**: `GET /api/search`
- **Mesma estrutura de resposta**: `SearchProductsResponse`
- **Mesmos parâmetros**: `query`, `limit`, `affiliateUrl`

### Tipos Compartilhados

Os modelos Swift são equivalentes aos tipos TypeScript:

| TypeScript | Swift |
|------------|-------|
| `Product` | `Product` |
| `AffiliateStore` | `AffiliateStore` |
| `GiftSuggestion` | `GiftSuggestion` |

## 📱 Funcionalidades

- ✅ Busca de produtos
- ✅ Filtro por faixa de preço
- ✅ Lista de favoritos
- ✅ Detalhes do produto
- ✅ Área administrativa (gerenciar lojas)
- ✅ Links de afiliado

## 🔄 Mantendo Sincronizado com Web

### Quando adicionar novo campo em Product:

1. **Atualizar TypeScript** (`lib/types/product.ts`)
2. **Atualizar Swift** (`Core/Types/Product.swift`)
3. **Atualizar parseProduct** em ambos os lados

### Quando alterar API:

1. **Verificar resposta** da API
2. **Atualizar modelo** se necessário
3. **Atualizar ambos** web e iOS

## 📝 Próximos Passos

- [ ] Adicionar testes unitários
- [ ] Implementar cache de imagens
- [ ] Adicionar suporte a notificações
- [ ] Integrar com sistema de favoritos do iOS
