# 🔧 Como Corrigir o Deploy no Netlify

## Problema
O Netlify está servindo de `/web/index.html` mas os arquivos compilados estão em `build/web/`.

## ✅ Solução Rápida

### Opção 1: Deploy Manual (Mais Rápido)

1. **Build local:**
   ```bash
   flutter build web --release
   ```

2. **No Netlify Dashboard:**
   - Vá em **Site settings** > **Build & deploy**
   - **Publish directory:** `build/web`
   - **Build command:** Deixe vazio (já compilado localmente)
   - Salve

3. **Faça deploy manual:**
   - Vá em **Deploys**
   - Clique em **Trigger deploy** > **Deploy site**
   - Ou arraste a pasta `build/web` para o Netlify Drop

### Opção 2: Usar Netlify CLI

```bash
# Instalar Netlify CLI (se não tiver)
npm install -g netlify-cli

# Build
flutter build web --release

# Deploy
netlify deploy --prod --dir=build/web
```

### Opção 3: GitHub Actions (Automático)

1. **Configure secrets no GitHub:**
   - `NETLIFY_AUTH_TOKEN` - Token do Netlify
   - `NETLIFY_SITE_ID` - ID do site (encontre em Site settings > General)

2. **O workflow `.github/workflows/netlify-deploy.yml` fará tudo automaticamente**

## ⚠️ Importante

O Netlify **não tem Flutter instalado por padrão**. Você precisa:
- Fazer build localmente e fazer deploy dos arquivos estáticos, OU
- Usar GitHub Actions para fazer build e deploy automático

## 🔍 Verificação

Após o deploy, acesse:
- `https://corevowishbox.netlify.app/` (raiz, não `/web/`)

Se ainda abrir em branco:
1. Abra o console do navegador (F12)
2. Verifique erros de carregamento
3. Certifique-se de que `flutter_bootstrap.js` e `main.dart.js` estão sendo carregados

