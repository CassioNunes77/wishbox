# 🔑 Como Obter Token e Site ID do Netlify

## ⚠️ IMPORTANTE: Isso é no NETLIFY, não no GitHub!

---

## 1️⃣ Obter o Token do Netlify

### Passo a Passo:

1. **Acesse o Netlify:**
   - Vá em: https://app.netlify.com
   - Faça login

2. **Vá em User Settings:**
   - Clique no seu **avatar/foto** no canto superior direito
   - Clique em **User settings** (ou **Account settings**)

3. **Vá em Applications:**
   - No menu lateral esquerdo, procure por **"Applications"**
   - Ou vá direto em: https://app.netlify.com/user/applications

4. **Criar Token:**
   - Clique em **"New access token"** (ou **"Create access token"**)
   - Dê um nome: `GitHub Actions` (ou qualquer nome)
   - Clique em **Generate token**
   - **COPIE O TOKEN IMEDIATAMENTE** (você só verá uma vez!)

---

## 2️⃣ Obter o Site ID do Netlify

### Passo a Passo:

1. **Acesse seu site no Netlify:**
   - Vá em: https://app.netlify.com
   - Clique no site **corevowishbox**

2. **Vá em Site settings:**
   - Clique no ícone de **engrenagem** (⚙️) no topo
   - Ou vá em: **Site settings**

3. **Vá em General:**
   - No menu lateral, clique em **General**

4. **Copie o Site ID:**
   - Na seção **"Site details"**
   - Procure por **"Site ID"**
   - Clique no ícone de **copiar** ao lado do ID
   - Ou selecione e copie manualmente

---

## 3️⃣ Adicionar Secrets no GitHub

Agora sim, no GitHub:

1. **Acesse:**
   - https://github.com/CassioNunes77/wishbox/settings/secrets/actions

2. **Ou navegue:**
   - GitHub > wishbox > **Settings** (no topo)
   - No menu lateral: **Secrets and variables** > **Actions**

3. **Adicionar Secret 1:**
   - Clique em **"New repository secret"**
   - Name: `NETLIFY_AUTH_TOKEN`
   - Value: (cole o token que você copiou do Netlify)
   - Clique em **Add secret**

4. **Adicionar Secret 2:**
   - Clique em **"New repository secret"** novamente
   - Name: `NETLIFY_SITE_ID`
   - Value: (cole o Site ID que você copiou)
   - Clique em **Add secret**

---

## ✅ Pronto!

Agora quando você fizer push no GitHub:
- GitHub Actions vai fazer build automaticamente
- Vai fazer deploy no Netlify automaticamente
- Site atualizado! 🎉

---

## 🔍 Se não encontrar "Applications" no Netlify:

### Alternativa 1: Via URL direta
- Token: https://app.netlify.com/user/applications
- Site ID: https://app.netlify.com/sites/corevowishbox/configuration/general

### Alternativa 2: Menu do usuário
1. Clique no seu **avatar** (canto superior direito)
2. Procure por **"User settings"** ou **"Account settings"**
3. No menu lateral, procure por **"Applications"** ou **"Access tokens"**

### Alternativa 3: Se ainda não encontrar
- Pode estar como **"Personal access tokens"**
- Ou **"API tokens"**
- Ou **"Access tokens"**

---

## 📝 Resumo Rápido:

1. ✅ Netlify > Avatar > User settings > Applications > New token
2. ✅ Netlify > Site > Settings > General > Site ID
3. ✅ GitHub > Settings > Secrets > Actions > Adicionar os 2 secrets

