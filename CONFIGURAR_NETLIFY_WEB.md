# 🌐 Configurar Netlify para Build Automático (100% Web)

## ✅ Passo a Passo SIMPLES - Tudo na Web!

### 1️⃣ **Conectar GitHub ao Netlify**

1. Acesse: https://app.netlify.com
2. Clique em **Add new site** > **Import an existing project**
3. Escolha **GitHub**
4. Autorize o Netlify a acessar seu GitHub
5. Selecione o repositório: **wishbox**
6. Clique em **Next**

---

### 2️⃣ **Configurar Build Settings**

Na tela de configuração:

1. **Branch to deploy:** `main` (já deve estar selecionado)

2. **Build command:** 
   ```
   echo "Build será feito pelo GitHub Actions"
   ```
   *(Ou deixe vazio - o GitHub Actions fará o build)*

3. **Publish directory:** 
   ```
   build/web
   ```

4. Clique em **Deploy site**

---

### 3️⃣ **Configurar Secrets no GitHub (Para Deploy Automático)**

#### A) Obter Token do Netlify:

1. No Netlify, vá em: **User settings** > **Applications** > **New access token**
2. Dê um nome (ex: "GitHub Actions")
3. Clique em **Generate token**
4. **COPIE O TOKEN** (você só verá uma vez!)

#### B) Obter Site ID do Netlify:

1. No Netlify, vá em: **Site settings** > **General**
2. Em **Site details**, copie o **Site ID**

#### C) Adicionar Secrets no GitHub:

1. Acesse: https://github.com/CassioNunes77/wishbox/settings/secrets/actions
2. Clique em **New repository secret**
3. Adicione dois secrets:

   **Secret 1:**
   - Name: `NETLIFY_AUTH_TOKEN`
   - Value: (cole o token que você copiou)

   **Secret 2:**
   - Name: `NETLIFY_SITE_ID`
   - Value: (cole o Site ID que você copiou)

4. Clique em **Add secret** para cada um

---

### 4️⃣ **Pronto! Agora é Automático! 🎉**

Agora, **sempre que você fizer push no GitHub**:

1. ✅ GitHub Actions faz o build do Flutter automaticamente
2. ✅ Faz deploy no Netlify automaticamente
3. ✅ Seu site atualiza sozinho!

---

## 🔄 Como Funciona?

1. Você faz **push** no GitHub
2. **GitHub Actions** detecta o push
3. Instala Flutter automaticamente
4. Faz `flutter build web --release`
5. Faz deploy no Netlify automaticamente
6. Site atualizado! ✅

---

## 📝 Resumo Rápido

1. ✅ Netlify > Import from GitHub > Escolher repositório
2. ✅ Publish directory: `build/web`
3. ✅ GitHub > Settings > Secrets > Adicionar `NETLIFY_AUTH_TOKEN` e `NETLIFY_SITE_ID`
4. ✅ Pronto! Tudo automático!

---

## ❓ Problemas?

### Deploy não funciona automaticamente?

1. Verifique se os secrets estão configurados no GitHub
2. Vá em **Actions** no GitHub e veja se o workflow está rodando
3. Verifique se há erros no log do workflow

### Site ainda em branco?

1. No Netlify, vá em **Deploys**
2. Veja se o último deploy foi bem-sucedido
3. Verifique se o "Publish directory" está como `build/web`

---

## 🎯 Depois de Configurado

**Você nunca mais precisa fazer build manual!**

- Faça push no GitHub
- Tudo acontece automaticamente
- Site atualiza sozinho! 🚀

