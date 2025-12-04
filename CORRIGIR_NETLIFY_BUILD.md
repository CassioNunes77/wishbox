# 🔧 Corrigir Erro: "Deploy directory 'build/web' does not exist"

## ❌ O Problema:

O Netlify está tentando fazer build, mas não tem Flutter instalado. A pasta `build/web` só existe DEPOIS que o GitHub Actions faz o build e deploy.

---

## ✅ Solução:

### No Netlify Dashboard:

1. **Acesse:** https://app.netlify.com/sites/corevowishbox/configuration/build

2. **Configure:**
   - **Build command:** Deixe **VAZIO** (remova qualquer comando)
   - **Publish directory:** `build/web`
   - **Base directory:** Deixe **VAZIO**

3. **Salve**

---

## 🎯 Como Funciona Agora:

1. **GitHub Actions** faz o build do Flutter
2. **GitHub Actions** faz deploy no Netlify (cria a pasta `build/web`)
3. **Netlify** serve os arquivos da pasta `build/web`

**O Netlify NÃO deve tentar fazer build!**

---

## ⚠️ IMPORTANTE:

O Netlify só vai ter os arquivos DEPOIS que o GitHub Actions fizer o deploy.

**Ordem correta:**
1. GitHub Actions faz build ✅
2. GitHub Actions faz deploy no Netlify ✅
3. Netlify serve os arquivos ✅

**Se o Netlify tentar fazer build ANTES do GitHub Actions:**
- ❌ Vai falhar (não tem Flutter)
- ❌ Vai dar erro "build/web does not exist"

---

## 🔄 Depois de Configurar:

1. **Force o GitHub Actions a rodar:**
   - https://github.com/CassioNunes77/wishbox/actions
   - "Run workflow" > "Run workflow"

2. **Aguarde** o GitHub Actions completar (5-10 minutos)

3. **Verifique** se o deploy foi feito no Netlify

4. **Teste** o site

