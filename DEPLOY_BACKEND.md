# 🚀 Guia de Deploy do Backend WishBox

Este guia mostra como fazer deploy do backend em diferentes plataformas.

## 📋 Pré-requisitos

- Conta na plataforma escolhida (Heroku, Railway, Render, etc.)
- Git configurado
- Backend funcionando localmente

---

## 🟣 Opção 1: Railway (Recomendado - Mais Fácil)

### Passo a passo:

1. **Acesse Railway:**
   - Vá em: https://railway.app
   - Faça login com GitHub

2. **Criar novo projeto:**
   - Clique em "New Project"
   - Selecione "Deploy from GitHub repo"
   - Escolha o repositório `wishbox`
   - Selecione a pasta `backend`

3. **Configurar:**
   - Railway detecta automaticamente Node.js
   - O comando de start já está configurado (`npm start`)
   - Porta será configurada automaticamente

4. **Obter URL:**
   - Após o deploy, Railway gera uma URL automática
   - Exemplo: `https://wishbox-backend-production.up.railway.app`
   - Copie essa URL

5. **Configurar no Netlify:**
   - Vá em: Netlify Dashboard → Site settings → Environment variables
   - Adicione: `NEXT_PUBLIC_BACKEND_URL` = URL do Railway
   - Faça novo deploy do frontend

✅ **Pronto!** Railway é gratuito e muito simples.

---

## 🔵 Opção 2: Render

### Passo a passo:

1. **Acesse Render:**
   - Vá em: https://render.com
   - Faça login com GitHub

2. **Criar novo Web Service:**
   - Clique em "New +" → "Web Service"
   - Conecte o repositório GitHub `wishbox`
   - Configure:
     - **Name:** `wishbox-backend`
     - **Root Directory:** `backend`
     - **Environment:** `Node`
     - **Build Command:** `npm install`
     - **Start Command:** `npm start`

3. **Configurar variáveis (opcional):**
   - Se precisar de variáveis de ambiente, adicione aqui

4. **Deploy:**
   - Clique em "Create Web Service"
   - Aguarde o deploy (pode levar alguns minutos)

5. **Obter URL:**
   - Render gera uma URL: `https://wishbox-backend.onrender.com`
   - Copie essa URL

6. **Configurar no Netlify:**
   - Adicione `NEXT_PUBLIC_BACKEND_URL` = URL do Render

✅ **Pronto!** Render tem plano gratuito (pode "dormir" após inatividade).

---

## 🟢 Opção 3: Heroku

### Passo a passo:

1. **Instalar Heroku CLI:**
   ```bash
   # macOS
   brew tap heroku/brew && brew install heroku
   
   # Ou baixe de: https://devcenter.heroku.com/articles/heroku-cli
   ```

2. **Login no Heroku:**
   ```bash
   heroku login
   ```

3. **Criar app:**
   ```bash
   cd backend
   heroku create wishbox-backend
   ```

4. **Deploy:**
   ```bash
   # Se o backend está em subpasta, precisa configurar
   git subtree push --prefix backend heroku main
   
   # Ou faça deploy manual:
   # 1. Crie um repositório separado só do backend
   # 2. Ou use heroku git:remote
   ```

5. **Configurar:**
   ```bash
   heroku config:set NODE_ENV=production
   ```

6. **Obter URL:**
   - URL será: `https://wishbox-backend.herokuapp.com`

7. **Configurar no Netlify:**
   - Adicione `NEXT_PUBLIC_BACKEND_URL` = URL do Heroku

⚠️ **Nota:** Heroku não tem mais plano gratuito. Use Railway ou Render.

---

## 🟡 Opção 4: Vercel (Serverless Functions)

### Passo a passo:

1. **Acesse Vercel:**
   - Vá em: https://vercel.com
   - Faça login com GitHub

2. **Importar projeto:**
   - Clique em "Add New" → "Project"
   - Importe o repositório `wishbox`
   - Configure:
     - **Root Directory:** `backend`
     - **Framework Preset:** Other
     - **Build Command:** (deixe vazio ou `npm install`)
     - **Output Directory:** (deixe vazio)

3. **Criar `vercel.json`:**
   ```json
   {
     "version": 2,
     "builds": [
       {
         "src": "server.js",
         "use": "@vercel/node"
       }
     ],
     "routes": [
       {
         "src": "/(.*)",
         "dest": "server.js"
       }
     ]
   }
   ```

4. **Deploy:**
   - Clique em "Deploy"
   - Aguarde

5. **Obter URL:**
   - Vercel gera: `https://wishbox-backend.vercel.app`

---

## 🎯 Recomendação: Railway

**Por quê Railway?**
- ✅ Gratuito
- ✅ Muito fácil de usar
- ✅ Deploy automático do GitHub
- ✅ Não "dorme" como Render
- ✅ Configuração mínima

---

## 📝 Após o Deploy

### 1. Testar o backend:
```bash
curl https://seu-backend.railway.app/health
# Deve retornar: {"status":"ok",...}

curl "https://seu-backend.railway.app/api/search?query=presentes&limit=3"
# Deve retornar produtos
```

### 2. Configurar no Netlify:
1. Netlify Dashboard → Site settings → Environment variables
2. Adicione:
   - **Key:** `NEXT_PUBLIC_BACKEND_URL`
   - **Value:** `https://seu-backend.railway.app` (sua URL)
3. Salve
4. Faça novo deploy do frontend

### 3. Testar no site:
- Acesse: https://wish2box.netlify.app
- Faça uma busca
- Verifique o console (F12) para logs

---

## 🐛 Troubleshooting

### Backend não responde:
- Verifique se o deploy foi concluído
- Verifique os logs na plataforma
- Teste o endpoint `/health`

### CORS errors:
- O backend já tem `cors()` configurado
- Se ainda der erro, verifique se o backend está acessível

### Timeout:
- Algumas plataformas têm timeout (Render: 30s)
- O backend já tem timeout de 15s configurado

---

## ✅ Checklist

- [ ] Backend deployado e acessível
- [ ] Endpoint `/health` funcionando
- [ ] Endpoint `/api/search` funcionando
- [ ] Variável `NEXT_PUBLIC_BACKEND_URL` configurada no Netlify
- [ ] Frontend redeployado no Netlify
- [ ] Teste de busca funcionando

---

**Pronto!** Seu backend estará funcionando em produção! 🎉
