# 🔧 Troubleshooting - Página em Branco

## ✅ Checklist Rápido

### 1️⃣ Verificar GitHub Actions

1. Acesse: https://github.com/CassioNunes77/wishbox/actions
2. Veja se há workflows rodando ou que falharam
3. Clique no último workflow
4. Veja se deu erro em algum passo

**Se deu erro:**
- Verifique se os secrets estão configurados corretamente
- Veja a mensagem de erro específica

**Se não há workflow rodando:**
- Faça um push qualquer (edite um arquivo e commite)
- Ou vá em Actions > "Build Flutter Web and Deploy to Netlify" > "Run workflow"

---

### 2️⃣ Verificar Netlify Deploys

1. Acesse: https://app.netlify.com/sites/corevowishbox/deploys
2. Veja o último deploy
3. Verifique se foi bem-sucedido

**Se o deploy falhou:**
- Veja os logs de erro
- Verifique se a pasta `build/web` existe

**Se não há deploy:**
- O GitHub Actions pode não ter feito deploy ainda
- Ou os secrets podem estar errados

---

### 3️⃣ Verificar Console do Navegador

1. Abra o site: https://corevowishbox.netlify.app/
2. Pressione **F12** (ou clique com botão direito > Inspecionar)
3. Vá na aba **Console**
4. Veja se há erros em vermelho

**Erros comuns:**
- `flutter_bootstrap.js not found` → Arquivos não foram deployados
- `main.dart.js not found` → Build não foi feito corretamente
- Erros de CORS → Problema de configuração

---

### 4️⃣ Verificar Arquivos no Netlify

1. No Netlify, vá em: **Deploys** > Clique no último deploy
2. Vá em **Published files**
3. Verifique se existem:
   - `index.html`
   - `flutter_bootstrap.js`
   - `main.dart.js`
   - `assets/` (pasta)
   - `canvaskit/` (pasta)

**Se não existem:**
- O build não foi feito corretamente
- Ou o deploy não funcionou

---

## 🔧 Soluções

### Solução 1: Forçar Novo Deploy

1. **No GitHub:**
   - Edite qualquer arquivo (ex: README.md)
   - Adicione um espaço
   - Commit e push

2. **Ou no GitHub Actions:**
   - Vá em Actions
   - Clique em "Build Flutter Web and Deploy to Netlify"
   - Clique em "Run workflow" > "Run workflow"

3. **Aguarde** o workflow terminar
4. **Verifique** se o deploy foi feito no Netlify

---

### Solução 2: Verificar Secrets

1. **No GitHub:**
   - https://github.com/CassioNunes77/wishbox/settings/secrets/actions
   - Verifique se existem:
     - `NETLIFY_AUTH_TOKEN`
     - `NETLIFY_SITE_ID`

2. **Se não existem ou estão errados:**
   - Crie/atualize os secrets
   - Faça um novo push

---

### Solução 3: Deploy Manual (Temporário)

Se nada funcionar, faça deploy manual:

1. **Build local:**
   ```bash
   cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
   flutter build web --release
   ```

2. **No Netlify:**
   - Vá em **Deploys**
   - Arraste a pasta `build/web` para a área de deploy
   - Aguarde upload
   - Site deve funcionar

---

### Solução 4: Verificar Base Href

1. Abra: `build/web/index.html`
2. Verifique se tem: `<base href="/">`
3. Se tiver outro valor, pode causar problemas

---

## 🎯 Passos para Diagnosticar

1. ✅ Verificar GitHub Actions (está rodando? deu erro?)
2. ✅ Verificar Netlify Deploys (foi feito? foi bem-sucedido?)
3. ✅ Verificar Console do navegador (há erros?)
4. ✅ Verificar arquivos no Netlify (existem os arquivos?)

---

## 📝 Informações para Me Passar

Se ainda não funcionar, me diga:

1. **GitHub Actions:**
   - Está rodando? Deu erro? Qual erro?

2. **Netlify:**
   - Há deploy? Foi bem-sucedido? Há erros nos logs?

3. **Console do navegador:**
   - Há erros? Quais?

4. **Arquivos:**
   - Os arquivos aparecem no "Published files" do Netlify?

Com essas informações, consigo identificar o problema exato!

