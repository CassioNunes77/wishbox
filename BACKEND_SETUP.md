# 🚀 Configuração do Backend - Solução Definitiva para Scraping

## 📋 O que foi implementado

Foi criado um backend Node.js que resolve o problema de CORS fazendo scraping da Magazine Luiza no servidor e retornando os dados via API JSON.

## 🏗️ Estrutura

```
backend/
├── package.json      # Dependências do Node.js
├── server.js         # Servidor Express com scraping
├── .gitignore        # Arquivos ignorados
└── README.md         # Documentação do backend
```

## ⚙️ Instalação e Execução

### 1. Instalar dependências

```bash
cd backend
npm install
```

### 2. Executar o servidor

**Desenvolvimento (com auto-reload):**
```bash
npm run dev
```

**Produção:**
```bash
npm start
```

O servidor estará rodando em `http://localhost:3000`

## 🔧 Configuração no Flutter

O Flutter já está configurado para usar o backend. A URL do backend está definida em:

```dart
lib/core/constants/app_constants.dart
```

**Para desenvolvimento local:**
- Já está configurado: `http://localhost:3000`

**Para produção:**
Você precisa definir a variável de ambiente `BACKEND_URL` ao compilar:

```bash
flutter build web --dart-define=BACKEND_URL=https://seu-backend.com
```

Ou edite diretamente em `app_constants.dart`:

```dart
static const String backendBaseUrl = 'https://seu-backend.com';
```

## 🌐 Deploy do Backend

### Opção 1: Railway (Recomendado - Grátis)

1. Acesse [railway.app](https://railway.app)
2. Conecte seu repositório GitHub
3. Railway detecta automaticamente Node.js
4. Configure:
   - **Root Directory:** `backend`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
5. Railway fornece uma URL automática (ex: `https://wishbox-backend.railway.app`)

### Opção 2: Render (Grátis)

1. Acesse [render.com](https://render.com)
2. Crie um novo **Web Service**
3. Conecte seu repositório GitHub
4. Configure:
   - **Root Directory:** `backend`
   - **Build Command:** `npm install`
   - **Start Command:** `npm start`
   - **Environment:** Node
5. Render fornece uma URL (ex: `https://wishbox-backend.onrender.com`)

### Opção 3: Heroku

```bash
cd backend
heroku create wishbox-backend
git push heroku main
```

### Opção 4: DigitalOcean App Platform

1. Conecte repositório GitHub
2. Configure:
   - **Type:** Web Service
   - **Build Command:** `cd backend && npm install`
   - **Run Command:** `cd backend && npm start`

## ✅ Testar o Backend

### 1. Testar localmente

```bash
# Terminal 1: Iniciar backend
cd backend
npm start

# Terminal 2: Testar endpoint
curl "http://localhost:3000/api/search?query=presentes&affiliateUrl=https://www.magazinevoce.com.br/elislecio/&limit=5"
```

### 2. Testar health check

```bash
curl http://localhost:3000/health
```

Resposta esperada:
```json
{
  "status": "ok",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "service": "wishbox-backend"
}
```

## 🔍 Como Funciona

1. **Frontend Flutter** faz requisição para o backend:
   ```
   GET /api/search?query=presentes&affiliateUrl=...
   ```

2. **Backend Node.js**:
   - Recebe a requisição
   - Faz scraping da Magazine Luiza (sem restrições CORS)
   - Parse do HTML usando Cheerio
   - Extrai produtos, preços, imagens, etc.
   - Retorna JSON limpo

3. **Frontend Flutter**:
   - Recebe JSON
   - Converte para objetos `Product`
   - Exibe na interface

## 🐛 Troubleshooting

### Backend não retorna produtos

1. Verifique se o backend está rodando:
   ```bash
   curl http://localhost:3000/health
   ```

2. Verifique os logs do backend no terminal

3. Teste a URL de busca diretamente no navegador:
   ```
   http://localhost:3000/api/search?query=presentes
   ```

### Erro de CORS no Flutter

O backend já está configurado com `cors()` que permite todas as origens. Se ainda houver erro:

1. Verifique se está usando a URL correta do backend
2. Verifique se o backend está rodando
3. Verifique os logs do backend

### Produtos não aparecem

1. Verifique se a Magazine Luiza mudou a estrutura HTML
2. Verifique os logs do backend para ver o que está sendo extraído
3. O scraping pode precisar de ajustes se a estrutura HTML mudar

## 📝 Próximos Passos

1. **Deploy do backend** em um serviço (Railway, Render, etc.)
2. **Atualizar URL do backend** no Flutter para produção
3. **Adicionar cache** no backend para melhorar performance
4. **Adicionar rate limiting** para evitar bloqueios
5. **Monitorar logs** para detectar mudanças na estrutura HTML

## 🎯 Vantagens desta Solução

✅ **Resolve CORS definitivamente** - Backend não tem restrições  
✅ **Escalável** - Pode adicionar cache, rate limiting, etc.  
✅ **Manutenível** - Código centralizado no backend  
✅ **Profissional** - Padrão da indústria  
✅ **Flexível** - Pode adicionar outras lojas facilmente  

