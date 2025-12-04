# ✅ Configurar Netlify AGORA - Passo a Passo

## 🎯 O que você precisa fazer na tela que está vendo:

### 1. **Publish directory:**
   - **Digite:** `build/web`
   - (Está vazio, precisa preencher!)

### 2. **Build command:**
   - **Deixe VAZIO** ✅ (já está vazio, perfeito!)

### 3. **Base directory:**
   - **Deixe VAZIO** ✅ (já está vazio, perfeito!)

### 4. **Build status:**
   - **Mude para:** "Stop builds" ou desative
   - (Isso vai impedir o Netlify de tentar fazer build automaticamente)

### 5. **Clique em "Save" ou "Update"**

---

## ⚠️ IMPORTANTE:

O Netlify **NÃO deve tentar fazer build** porque não tem Flutter.

**O GitHub Actions faz:**
1. ✅ Build do Flutter
2. ✅ Deploy no Netlify

**O Netlify só:**
- ✅ Serve os arquivos que o GitHub Actions enviou

---

## 🔄 Depois de Salvar:

1. **Force o GitHub Actions:**
   - https://github.com/CassioNunes77/wishbox/actions
   - "Run workflow" > "Run workflow"

2. **Aguarde** 5-10 minutos

3. **Teste** o site

---

## 📝 Resumo:

- ✅ Publish directory: `build/web`
- ✅ Build command: **VAZIO**
- ✅ Base directory: **VAZIO**
- ✅ Build status: **Desativado** (ou "Stop builds")

**Salve e pronto!**

