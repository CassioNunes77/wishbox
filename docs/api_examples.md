# Exemplos de Respostas da API

Este documento contém exemplos de JSON para as respostas esperadas da API do backend.

## 1. Criar Perfil e Obter Sugestões

### Request
```json
POST /api/v1/gifts/profile-and-suggestions

{
  "isSelfGift": false,
  "relationType": "Namorado(a)",
  "ageRange": "26-40 anos",
  "gender": "Feminino",
  "occasion": "Aniversário",
  "descriptionRaw": "Gosta de café, leitura, é caseira, trabalha com tecnologia, gosta de coisas minimalistas",
  "priceMin": 50.0,
  "priceMax": 500.0,
  "giftTypes": ["Romântico", "Útil no dia a dia"],
  "preferredStores": ["Amazon", "Mercado Livre"],
  "constraints": ["nada de bebida alcoólica"]
}
```

### Response
```json
{
  "recipientProfile": {
    "id": "profile-123",
    "userId": "user-456",
    "isSelfGift": false,
    "relationType": "Namorado(a)",
    "ageRange": "26-40 anos",
    "gender": "Feminino",
    "occasion": "Aniversário",
    "descriptionRaw": "Gosta de café, leitura, é caseira, trabalha com tecnologia, gosta de coisas minimalistas",
    "interests": ["café", "leitura", "tecnologia", "minimalismo"],
    "personalityTags": ["caseira", "romântica", "prática", "minimalista"],
    "giftStylePriority": "Romântico",
    "constraints": ["nada de bebida alcoólica"],
    "createdAt": "2025-01-15T10:30:00Z"
  },
  "suggestions": [
    {
      "id": "sug-001",
      "giftSearchSessionId": "session-789",
      "product": {
        "id": "prod-001",
        "externalId": "amz-123456",
        "affiliateSource": "amazon",
        "name": "Kit Café Gourmet com Caneca Personalizada",
        "description": "Kit completo com café especial, caneca de cerâmica personalizada e colher de madeira.",
        "price": 89.90,
        "currency": "BRL",
        "category": "Casa e Cozinha",
        "imageUrl": "https://example.com/images/kit-cafe.jpg",
        "productUrlBase": "https://amazon.com.br/product/123456",
        "affiliateUrl": "https://amazon.com.br/product/123456?tag=affiliate-xxx",
        "rating": 4.8,
        "reviewCount": 234,
        "tags": ["Romântico", "Útil", "Casa"]
      },
      "relevanceScore": 0.95,
      "reasonText": "Esse kit café combina perfeitamente porque junta algo útil para o dia a dia com um toque romântico e personalizado, ideal para quem gosta de momentos tranquilos.",
      "position": 1
    },
    {
      "id": "sug-002",
      "giftSearchSessionId": "session-789",
      "product": {
        "id": "prod-002",
        "externalId": "ml-789012",
        "affiliateSource": "mercado_livre",
        "name": "Livro: Romance Contemporâneo - Edição Especial",
        "description": "Livro de romance contemporâneo com capa dura e marcador de páginas.",
        "price": 45.00,
        "currency": "BRL",
        "category": "Livros",
        "imageUrl": "https://example.com/images/livro.jpg",
        "productUrlBase": "https://mercadolivre.com.br/item/789012",
        "affiliateUrl": "https://mercadolivre.com.br/item/789012?affiliate=xxx",
        "rating": 4.6,
        "reviewCount": 189,
        "tags": ["Romântico", "Divertido"]
      },
      "relevanceScore": 0.88,
      "reasonText": "Este livro é uma excelente escolha para quem aprecia leitura e histórias emocionantes, oferecendo momentos de entretenimento e reflexão.",
      "position": 2
    }
  ]
}
```

## 2. Obter Histórico de Buscas

### Request
```json
GET /api/v1/users/user-456/history
```

### Response
```json
{
  "sessions": [
    {
      "id": "session-789",
      "userId": "user-456",
      "recipientProfile": {
        "id": "profile-123",
        "userId": "user-456",
        "isSelfGift": false,
        "relationType": "Namorado(a)",
        "ageRange": "26-40 anos",
        "gender": "Feminino",
        "occasion": "Aniversário",
        "descriptionRaw": "Gosta de café, leitura, é caseira...",
        "interests": ["café", "leitura", "tecnologia"],
        "personalityTags": ["caseira", "romântica", "prática"],
        "giftStylePriority": "Romântico",
        "constraints": [],
        "createdAt": "2025-01-15T10:30:00Z"
      },
      "priceMin": 50.0,
      "priceMax": 500.0,
      "preferredStores": ["Amazon", "Mercado Livre"],
      "createdAt": "2025-01-15T10:30:00Z",
      "suggestionsCount": 6,
      "clicksCount": 3,
      "savedCount": 2
    },
    {
      "id": "session-790",
      "userId": "user-456",
      "recipientProfile": {
        "id": "profile-124",
        "userId": "user-456",
        "isSelfGift": true,
        "relationType": null,
        "ageRange": null,
        "gender": null,
        "occasion": null,
        "descriptionRaw": "Gosto de tecnologia, jogos, coisas úteis",
        "interests": ["tecnologia", "jogos"],
        "personalityTags": ["prático", "tecnológico"],
        "giftStylePriority": "Tecnológico",
        "constraints": [],
        "createdAt": "2025-01-10T14:20:00Z"
      },
      "priceMin": 100.0,
      "priceMax": 400.0,
      "preferredStores": ["Shopee", "AliExpress"],
      "createdAt": "2025-01-10T14:20:00Z",
      "suggestionsCount": 4,
      "clicksCount": 1,
      "savedCount": 1
    }
  ]
}
```

## 3. Registrar Clique em Produto

### Request
```json
POST /api/v1/gifts/session-789/product/prod-001/click

{
  "userId": "user-456",
  "clickedAt": "2025-01-15T11:00:00Z"
}
```

### Response
```json
{
  "success": true,
  "message": "Clique registrado com sucesso",
  "clickId": "click-123"
}
```

## 4. Registrar Compra

### Request
```json
POST /api/v1/purchases

{
  "userId": "user-456",
  "recipientProfileId": "profile-123",
  "productId": "prod-001",
  "giftSearchSessionId": "session-789",
  "purchaseValue": 89.90,
  "purchaseDate": "2025-01-16T09:00:00Z",
  "source": "manual",
  "notes": "Comprado para aniversário da namorada"
}
```

### Response
```json
{
  "success": true,
  "message": "Compra registrada com sucesso",
  "purchaseId": "purchase-456"
}
```

## 5. Enviar Feedback (Gostei/Não Gostei)

### Request
```json
POST /api/v1/gifts/suggestions/sug-001/feedback

{
  "userId": "user-456",
  "feedback": "like" // ou "dislike"
}
```

### Response
```json
{
  "success": true,
  "message": "Feedback registrado com sucesso"
}
```

## 6. Salvar Presente na Lista

### Request
```json
POST /api/v1/users/user-456/saved-gifts

{
  "suggestionId": "sug-001",
  "notes": "Presente perfeito para o aniversário"
}
```

### Response
```json
{
  "success": true,
  "message": "Presente salvo com sucesso",
  "savedGiftId": "saved-789"
}
```

## Códigos de Erro

### 400 - Bad Request
```json
{
  "error": "Bad Request",
  "message": "Campos obrigatórios faltando: relationType, ageRange",
  "code": "VALIDATION_ERROR"
}
```

### 404 - Not Found
```json
{
  "error": "Not Found",
  "message": "Produto não encontrado",
  "code": "PRODUCT_NOT_FOUND"
}
```

### 500 - Internal Server Error
```json
{
  "error": "Internal Server Error",
  "message": "Erro ao processar requisição",
  "code": "INTERNAL_ERROR"
}
```



