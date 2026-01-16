# 🗑️ Como Remover o Link de Afiliado de Teste

## 📍 Localização

O link de afiliado de teste `https://www.magazinevoce.com.br/elislecio/` está configurado em **2 arquivos**:

### 1. iOS (Swift)
📁 `ios/Runner/Core/Services/StoreService.swift`

### 2. Web (TypeScript)
📁 `lib/services/store.ts`

## ✅ Como Remover (Passo a Passo)

### Opção 1: Remover Completamente

**No iOS (`StoreService.swift`):**
```swift
// ANTES (com teste):
private let TEST_AFFILIATE_URL = "https://www.magazinevoce.com.br/elislecio/"
affiliateUrlTemplate: TEST_AFFILIATE_URL,

// DEPOIS (removido):
affiliateUrlTemplate: "", // ou null/nil
```

**No Web (`store.ts`):**
```typescript
// ANTES (com teste):
private static readonly TEST_AFFILIATE_URL = 'https://www.magazinevoce.com.br/elislecio/';
affiliateUrlTemplate: this.TEST_AFFILIATE_URL,

// DEPOIS (removido):
affiliateUrlTemplate: '', // string vazia
```

### Opção 2: Manter mas Desativar

**No iOS:**
```swift
isActive: false, // Desativa a loja de teste
```

**No Web:**
```typescript
isActive: false, // Desativa a loja de teste
```

## 🔍 Buscar por Referências

Para encontrar todas as referências ao link de teste:

```bash
# Buscar no código
grep -r "elislecio" ios/ lib/
grep -r "TEST_AFFILIATE_URL" ios/ lib/
grep -r "REMOVER TESTE" ios/ lib/
```

## 📝 Notas

- O link está marcado com `TODO: REMOVER TESTE` nos comentários
- A constante `TEST_AFFILIATE_URL` foi criada especificamente para facilitar a remoção
- Após remover, o app usará as lojas cadastradas pelo usuário na área administrativa
- Se não houver lojas cadastradas, o app funcionará sem link de afiliado padrão
