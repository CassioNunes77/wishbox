# 🚀 Como Rodar Localmente

## 📋 Pré-requisitos

- Node.js 18+
- npm ou yarn

## 🔧 Configuração

### 1. Backend (Porta 3001)

O backend Node.js deve estar rodando na porta **3001**:

```bash
cd backend
npm install
npm start
# ou
PORT=3001 node server.js
```

O backend estará disponível em: `http://localhost:3001`

### 2. Frontend (Porta 3000)

O frontend Next.js roda na porta **3000** (padrão):

```bash
# Na raiz do projeto
npm install
npm run dev
```

O frontend estará disponível em: `http://localhost:3000`

## 🔄 Como Funciona

### Desenvolvimento Local

1. **Backend rodando em `localhost:3001`**
   - Rota: `http://localhost:3001/api/search`
   - Código: `backend/server.js`

2. **Frontend rodando em `localhost:3000`**
   - Quando o frontend chama `/api/search`
   - Next.js intercepta em `app/api/search/route.ts`
   - Faz proxy para `http://localhost:3001/api/search`

### Produção (Netlify)

1. **Netlify Function**
   - Rota: `/.netlify/functions/api-search`
   - Código: `netlify/functions/api-search.js`

2. **Redirect**
   - `netlify.toml` redireciona `/api/search` → `/.netlify/functions/api-search`

## ⚙️ Variáveis de Ambiente

### Desenvolvimento Local

Crie um arquivo `.env.local` na raiz (opcional):

```env
# Se quiser usar porta diferente para o backend
NEXT_PUBLIC_DEV_PORT=3001

# Ou se quiser usar URL completa
# NEXT_PUBLIC_BACKEND_URL=http://localhost:3001
```

### Produção (Netlify)

No Netlify, **NÃO configure** `NEXT_PUBLIC_BACKEND_URL`:
- A Netlify Function será usada automaticamente

## ✅ Testar

1. **Iniciar backend:**
   ```bash
   cd backend
   npm start
   # Deve mostrar: "Server running on port 3001"
   ```

2. **Iniciar frontend:**
   ```bash
   npm run dev
   # Deve mostrar: "Ready on http://localhost:3000"
   ```

3. **Abrir navegador:**
   ```
   http://localhost:3000
   ```

4. **Fazer uma busca** e verificar no console:
   ```
   === ApiService: Using Next.js API route (dev mode): /api/search
   ```

## 🐛 Troubleshooting

### Erro: "Endpoint do backend não encontrado"

**Causa:** Backend não está rodando ou porta incorreta.

**Solução:**
1. Verifique se o backend está rodando: `http://localhost:3001/api/search?query=teste`
2. Verifique a porta no `backend/server.js` (deve ser 3001)
3. Verifique `NEXT_PUBLIC_DEV_PORT` se configurado

### Erro: 404 em `/api/search`

**Causa:** Rota Next.js não foi criada ou backend não está rodando.

**Solução:**
1. Verifique se `app/api/search/route.ts` existe
2. Reinicie o frontend: `npm run dev`
3. Verifique se o backend está rodando na porta 3001

### Erro: CORS

**Causa:** Backend não está permitindo requisições do frontend.

**Solução:**
- O backend já está configurado com `cors()` no `backend/server.js`
- Se persistir, verifique se o backend está aceitando requisições de `http://localhost:3000`

## 📝 Notas

- **Porta padrão do backend:** 3001
- **Porta padrão do frontend:** 3000
- **Em desenvolvimento:** Next.js API route faz proxy
- **Em produção:** Netlify Function é usada automaticamente
