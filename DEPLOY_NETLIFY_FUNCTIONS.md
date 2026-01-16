# 🚀 Deploy Completo no Netlify com Functions

## ✅ O Que Foi Feito

Convertemos o backend para **Netlify Functions** (serverless), permitindo fazer todo o deploy no Netlify sem precisar de Railway ou outras plataformas.

---

## 📁 Estrutura Criada

```
wishbox/
├── netlify/
│   └── functions/
│       └── api-search.js    # Função serverless para busca de produtos
├── netlify.toml              # Configuração do Netlify
└── package.json              # Dependências (cheerio adicionado)
```

---

## 🔧 Configurações

### 1. Netlify Function (`netlify/functions/api-search.js`)
- ✅ Toda a lógica do backend convertida
- ✅ Suporte a CORS
- ✅ Timeout de 10s (plano gratuito)
- ✅ Tratamento de erros 403

### 2. `netlify.toml`
- ✅ Configurado `functions = "netlify/functions"`
- ✅ Redirect `/api/search` → `/.netlify/functions/api-search`

### 3. Frontend (`lib/services/api.ts`)
- ✅ Detecta automaticamente se está em produção
- ✅ Usa função Netlify em produção
- ✅ Usa backend separado em desenvolvimento

---

## 🚀 Como Fazer Deploy

### 1. Commit e Push

```bash
git add .
git commit -m "feat: converte backend para Netlify Functions"
git push origin main
```

### 2. No Netlify

1. **Acesse:** https://app.netlify.com
2. **Seu site** → **Deploys**
3. O Netlify detectará automaticamente e fará deploy
4. **Aguarde** o deploy completar (2-5 minutos)

### 3. Verificar

Após o deploy:
- ✅ Frontend funcionando
- ✅ Função serverless disponível em `/api/search`
- ✅ Busca de produtos funcionando

---

## 🧪 Testar Localmente

### Opção 1: Netlify Dev (Recomendado)

```bash
# Instalar Netlify CLI (se ainda não tiver)
npm install -g netlify-cli

# Iniciar ambiente local
netlify dev
```

Isso iniciará:
- Frontend Next.js
- Netlify Functions
- Tudo funcionando localmente

### Opção 2: Backend Separado (Desenvolvimento)

Se preferir usar backend separado em desenvolvimento:

1. **Iniciar backend:**
   ```bash
   cd backend
   npm start
   ```

2. **Iniciar frontend:**
   ```bash
   npm run dev
   ```

3. **Configurar variável:**
   ```bash
   # .env.local
   NEXT_PUBLIC_BACKEND_URL=http://localhost:3000
   ```

---

## ⚙️ Variáveis de Ambiente

### Em Produção (Netlify)

**Não precisa configurar nada!** A função Netlify é usada automaticamente.

### Em Desenvolvimento

Se quiser usar backend separado:

1. **Netlify Dashboard** → **Site settings** → **Environment variables**
2. **Adicionar:**
   - `NEXT_PUBLIC_BACKEND_URL` = `http://localhost:3000` (apenas para dev local)

---

## 📊 Vantagens

### ✅ Tudo no Netlify
- Frontend e backend no mesmo lugar
- Sem necessidade de Railway/Heroku
- Deploy simplificado

### ✅ Serverless
- Escala automaticamente
- Paga apenas pelo uso
- Sem servidor para gerenciar

### ✅ Performance
- Funções próximas ao frontend
- Menor latência
- CDN global do Netlify

---

## ⚠️ Limitações

### Timeout
- **Plano gratuito:** 10 segundos
- **Plano pago:** 26 segundos

Se o scraping demorar mais, pode dar timeout. Nesse caso:
- Otimizar scraping
- Usar Background Functions (plano pago)
- Ou manter backend separado para scraping pesado

---

## 🔍 Debug

### Ver Logs da Function

1. **Netlify Dashboard** → **Functions**
2. **Clique em `api-search`**
3. **Veja os logs** de execução

### Testar Function Diretamente

```bash
# Localmente com Netlify Dev
curl "http://localhost:8888/api/search?query=café&limit=3"

# Em produção
curl "https://seu-site.netlify.app/api/search?query=café&limit=3"
```

---

## 📝 Próximos Passos

1. ✅ **Commit e push** para GitHub
2. ✅ **Aguardar deploy** no Netlify
3. ✅ **Testar** busca de produtos
4. ✅ **Verificar logs** se houver problemas

---

## 🎉 Resultado Final

Agora você tem:
- ✅ Frontend Next.js no Netlify
- ✅ Backend como Netlify Function
- ✅ Tudo funcionando em um só lugar
- ✅ Sem necessidade de Railway/Heroku

**Tudo deployado no Netlify!** 🚀
