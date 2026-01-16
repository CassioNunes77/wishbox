# 🔍 Debug: Endpoint do Backend Não Encontrado

## Problema Persistente

Mesmo com a variável configurada no Netlify, ainda dá erro.

---

## ✅ Verificações Necessárias

### 1. Confirmar que Fez Novo Deploy

⚠️ **CRÍTICO:** Variáveis de ambiente só funcionam após novo deploy!

1. No Netlify, vá em **"Deploys"**
2. Verifique o **horário do último deploy**
3. Se foi ANTES de configurar a variável, precisa fazer novo deploy:
   - Clique em **"Trigger deploy"** → **"Deploy site"**
   - Aguarde completar (2-5 minutos)

### 2. Verificar no Console do Navegador

1. Acesse: https://wish2box.netlify.app
2. Pressione **F12** (abrir console)
3. Procure por logs começando com `=== ApiService:`
4. Veja o que aparece:
   - `Using backend URL: https://wishbox-production-f9ef.up.railway.app` ✅
   - `Using backend URL: http://localhost:3000` ❌ (variável não aplicada)
   - `Using backend URL: undefined` ❌ (variável não configurada)

### 3. Teste Rápido no Console

Cole no console (F12):

```javascript
// Verificar variável
console.log('NEXT_PUBLIC_BACKEND_URL:', process.env.NEXT_PUBLIC_BACKEND_URL);

// Testar conexão
const backendUrl = process.env.NEXT_PUBLIC_BACKEND_URL || 'https://wishbox-production-f9ef.up.railway.app';
fetch(backendUrl + '/health')
  .then(r => r.json())
  .then(d => console.log('✅ Backend OK:', d))
  .catch(e => console.error('❌ Backend Error:', e));
```

### 4. Verificar URL do Backend

Teste diretamente no navegador:

```
https://wishbox-production-f9ef.up.railway.app/health
```

**Deve retornar:**
```json
{"status":"ok","timestamp":"...","service":"wishbox-backend"}
```

Se não funcionar, o problema é no Railway (não no Netlify).

---

## 🔧 Soluções

### Solução 1: Forçar Novo Deploy

1. No Netlify → **Deploys**
2. **Trigger deploy** → **Clear cache and deploy site**
3. Aguarde completar
4. Teste novamente

### Solução 2: Verificar Variável

1. Netlify → **Site settings** → **Environment variables**
2. Verifique se `NEXT_PUBLIC_BACKEND_URL` está lá
3. Verifique se o valor está correto: `https://wishbox-production-f9ef.up.railway.app`
4. ⚠️ **IMPORTANTE:** Deve começar com `https://`

### Solução 3: Hardcode Temporário (Teste)

Para testar se é problema da variável, podemos hardcodar temporariamente:

No arquivo `lib/constants/app.ts`, mude temporariamente:

```typescript
backendBaseUrl: 'https://wishbox-production-f9ef.up.railway.app',
```

Faça commit e push. Se funcionar, o problema é a variável de ambiente.

---

## 🐛 Problemas Comuns

### Variável não aparece no código
**Causa:** Deploy feito antes de configurar variável
**Solução:** Fazer novo deploy

### URL sem https://
**Causa:** Variável configurada sem `https://`
**Solução:** Adicionar `https://` no início da URL

### Cache do navegador
**Causa:** Navegador usando versão antiga
**Solução:** Limpar cache (Ctrl+Shift+R ou Cmd+Shift+R)

---

## 📝 Próximos Passos

1. **Verifique o console** (F12) e me diga o que aparece em `=== ApiService:`
2. **Confirme se fez novo deploy** após configurar a variável
3. **Teste a URL do backend** diretamente: `/health`
4. **Me envie os logs** do console para eu ver o que está acontecendo

---

## 💡 Dica

O código agora tem logs mais detalhados. Abra o console (F12) e veja exatamente qual URL está sendo usada. Isso vai mostrar se a variável está sendo aplicada ou não.
