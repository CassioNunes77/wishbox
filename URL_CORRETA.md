# 🌐 URL CORRETA para Acessar o Site

## ❌ URL ERRADA:
```
https://corevowishbox.netlify.app/web/index.html
```

## ✅ URL CORRETA:
```
https://corevowishbox.netlify.app/
```

---

## 🎯 Por quê?

O Netlify serve os arquivos da pasta `build/web` na **raiz** do site, não em `/web/`.

Quando você acessa `/web/index.html`, o Netlify procura por uma pasta `web` dentro do deploy, mas os arquivos estão na raiz.

---

## ✅ Teste Agora:

Acesse: **https://corevowishbox.netlify.app/**

(URL raiz, sem `/web/`)

---

## 🔍 Se ainda estiver em branco:

1. **Verifique se o deploy foi feito:**
   - https://app.netlify.com/sites/corevowishbox/deploys
   - Há um deploy recente? Está publicado?

2. **Console do navegador (F12):**
   - Abra a URL correta: https://corevowishbox.netlify.app/
   - Pressione F12
   - Vá em Console
   - Há erros? Quais?

3. **Arquivos no Netlify:**
   - No deploy, clique em "Published files"
   - Existe `index.html` na raiz?
   - Existe `flutter_bootstrap.js`?

---

## 📝 Resumo:

- ❌ **ERRADO:** `/web/index.html`
- ✅ **CORRETO:** `/` (raiz)

