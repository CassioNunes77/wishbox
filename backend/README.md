# WishBox Backend

Backend Node.js para fazer scraping de produtos da Magazine Luiza e outras lojas afiliadas.

## 🚀 Instalação

```bash
cd backend
npm install
```

## ▶️ Executar

### Modo Desenvolvimento (com auto-reload):
```bash
npm run dev
```

### Modo Produção:
```bash
npm start
```

O servidor estará rodando em `http://localhost:3000`

## 📡 Endpoints

### GET /api/search

Busca produtos na Magazine Luiza.

**Parâmetros:**
- `query` (obrigatório): Termo de busca
- `affiliateUrl` (opcional): URL do afiliado (ex: `https://www.magazinevoce.com.br/elislecio/`)
- `limit` (opcional): Número máximo de produtos (padrão: 20)

**Exemplo:**
```
GET http://localhost:3000/api/search?query=presentes&affiliateUrl=https://www.magazinevoce.com.br/elislecio/&limit=15
```

**Resposta:**
```json
{
  "success": true,
  "query": "presentes",
  "affiliateUrl": "https://www.magazinevoce.com.br/elislecio/",
  "products": [
    {
      "id": "ml_123456",
      "externalId": "ml_123456",
      "affiliateSource": "magazine_luiza",
      "name": "Produto Exemplo",
      "description": "Descrição do produto",
      "price": 299.90,
      "currency": "BRL",
      "category": "Eletrônicos",
      "imageUrl": "https://...",
      "productUrlBase": "https://www.magazineluiza.com.br/produto/...",
      "affiliateUrl": "https://www.magazinevoce.com.br/elislecio/produto/...",
      "rating": 4.5,
      "reviewCount": 150,
      "tags": ["Útil", "Qualidade"]
    }
  ],
  "count": 15
}
```

### GET /health

Health check do servidor.

**Resposta:**
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "service": "wishbox-backend"
}
```

## 🌐 Deploy

### Opções de Deploy:

1. **Heroku:**
   ```bash
   heroku create wishbox-backend
   git push heroku main
   ```

2. **Railway:**
   - Conecte seu repositório GitHub
   - Railway detecta automaticamente Node.js

3. **Render:**
   - Crie um novo Web Service
   - Conecte seu repositório
   - Build Command: `npm install`
   - Start Command: `npm start`

4. **Vercel:**
   - Conecte repositório
   - Configure como Node.js project

5. **DigitalOcean App Platform:**
   - Conecte repositório
   - Configure build e start commands

## ⚙️ Variáveis de Ambiente

- `PORT`: Porta do servidor (padrão: 3000)

## 📝 Notas

- O scraping pode ser afetado por mudanças na estrutura HTML da Magazine Luiza
- Em produção, considere adicionar cache para melhorar performance
- Adicione rate limiting para evitar bloqueios
- Considere usar um serviço de proxy rotativo para evitar IP bans

