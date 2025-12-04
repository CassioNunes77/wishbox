# 🚀 Como Configurar o Netlify - Passo a Passo

## ⚠️ IMPORTANTE: O Netlify NÃO tem Flutter instalado!

Por isso, você precisa fazer o build localmente primeiro.

---

## 📋 Passo a Passo SIMPLES

### 1️⃣ **Build Local (No Seu Computador)**

Abra o terminal e execute:

```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter build web --release
```

Aguarde terminar (vai demorar alguns minutos).

---

### 2️⃣ **No Netlify Dashboard**

#### A) Acesse o Netlify:
- Vá em: https://app.netlify.com
- Entre na sua conta
- Clique no site **corevowishbox**

#### B) Vá em **Site settings** (ícone de engrenagem no topo)

#### C) Clique em **Build & deploy** (menu lateral esquerdo)

#### D) Na seção **Build settings**, configure:

1. **Build command:** 
   - Deixe **VAZIO** ou remova qualquer comando que esteja lá
   - (Não precisa de comando porque você já fez o build local)

2. **Publish directory:**
   - Digite exatamente: `build/web`
   - (Sem aspas, sem barra no final)

#### E) Clique em **Save** (salvar)

---

### 3️⃣ **Fazer Deploy Manual**

#### Opção A: Via Dashboard (Mais Fácil)

1. No menu lateral, clique em **Deploys**
2. Clique no botão **Trigger deploy** (canto superior direito)
3. Escolha **Deploy site**
4. Aguarde alguns segundos
5. Pronto! ✅

#### Opção B: Arrastar e Soltar (Ainda Mais Fácil)

1. No menu lateral, clique em **Deploys**
2. Procure a área **"Want to deploy a new version without connecting to Git?"**
3. Arraste a pasta `build/web` do seu computador para essa área
4. Aguarde o upload
5. Pronto! ✅

---

## 🎯 Onde Encontrar a Pasta `build/web`?

No seu computador:
```
/Users/Cassio/Documents/Xcode Projects/WishBox/build/web
```

Essa pasta contém todos os arquivos que o Netlify precisa servir.

---

## ✅ Como Saber se Funcionou?

1. Após o deploy, acesse: **https://corevowishbox.netlify.app/**
2. A página deve abrir normalmente (não em branco)
3. Você deve ver a tela inicial do WishBox

---

## 🔄 Para Atualizar o Site (Sempre que Fizer Mudanças)

Sempre que você modificar o código:

1. **Build local novamente:**
   ```bash
   flutter build web --release
   ```

2. **Deploy no Netlify:**
   - Opção A: Arraste a pasta `build/web` novamente
   - Opção B: Use "Trigger deploy" no dashboard

---

## ❓ Problemas?

### Página ainda em branco?

1. Abra o console do navegador (F12)
2. Veja se há erros em vermelho
3. Verifique se o deploy foi concluído com sucesso no Netlify

### Erro no deploy?

1. Verifique se a pasta `build/web` existe
2. Verifique se tem o arquivo `index.html` dentro dela
3. Certifique-se de que o "Publish directory" está como `build/web` (sem barra no final)

---

## 📝 Resumo Rápido

1. ✅ `flutter build web --release` (no terminal)
2. ✅ Netlify > Site settings > Build & deploy
3. ✅ Publish directory: `build/web`
4. ✅ Build command: **VAZIO**
5. ✅ Deploys > Arrastar pasta `build/web`
6. ✅ Pronto!

