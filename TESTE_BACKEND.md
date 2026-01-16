# 🔍 Como Testar se o Backend Está Funcionando

## 1. Teste Básico - Health Check

Abra no navegador ou terminal:

```
https://sua-url-railway.app/health
```

**Deve retornar:**
```json
{
  "status": "ok",
  "timestamp": "2024-...",
  "service": "wishbox-backend"
}
```

✅ **Se funcionar:** Backend está rodando
❌ **Se der erro 404:** URL está errada ou backend não está deployado
❌ **Se der erro de conexão:** Backend não está acessível

---

## 2. Teste de Busca

```
https://sua-url-railway.app/api/search?query=presentes&limit=3
```

**Deve retornar:**
```json
{
  "success": true,
  "query": "presentes",
  "products": [...],
  "count": 3
}
```

✅ **Se funcionar:** Backend está OK
❌ **Se der erro:** Verifique os logs do Railway

---

## 3. Verificar URL no Netlify

1. Acesse: https://app.netlify.com
2. Seu site → **Site settings** → **Environment variables**
3. Verifique se `NEXT_PUBLIC_BACKEND_URL` está configurada
4. **IMPORTANTE:** A URL deve:
   - Começar com `https://`
   - Não terminar com `/`
   - Exemplo correto: `https://wishbox-production.up.railway.app`
   - Exemplo ERRADO: `https://wishbox-production.up.railway.app/`

---

## 4. Verificar no Console do Navegador

1. Abra o site: https://wish2box.netlify.app
2. Pressione F12 (abrir console)
3. Procure por logs começando com `=== ApiService:`
4. Verifique:
   - Qual URL está sendo usada
   - Qual erro está aparecendo

---

## 5. Problemas Comuns

### Erro: "Endpoint do backend não encontrado"
**Causa:** URL está errada ou backend não está acessível

**Solução:**
1. Teste a URL diretamente no navegador: `https://sua-url/health`
2. Se não funcionar, verifique se o backend está deployado no Railway
3. Verifique se a URL no Netlify está correta (sem barra no final)

### Erro: "Network Error" ou "CORS"
**Causa:** Backend não está permitindo requisições do Netlify

**Solução:**
- O backend já tem `cors()` configurado
- Se ainda der erro, verifique os logs do Railway

### Erro: "404 Not Found"
**Causa:** Endpoint não existe ou URL está errada

**Solução:**
- Verifique se a URL termina com `/api/search` (não `/api/search/`)
- Teste: `https://sua-url/api/search?query=teste`

---

## 6. Checklist de Verificação

- [ ] Backend está deployado no Railway
- [ ] URL do Railway está acessível (teste `/health`)
- [ ] Variável `NEXT_PUBLIC_BACKEND_URL` está configurada no Netlify
- [ ] URL no Netlify começa com `https://` e não termina com `/`
- [ ] Frontend foi redeployado após configurar a variável
- [ ] Console do navegador mostra a URL correta sendo usada

---

## 7. Debug Rápido

No console do navegador (F12), execute:

```javascript
// Ver qual URL está configurada
console.log('Backend URL:', process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:3000');

// Testar conexão
fetch(process.env.NEXT_PUBLIC_BACKEND_URL + '/health')
  .then(r => r.json())
  .then(d => console.log('✅ Backend OK:', d))
  .catch(e => console.error('❌ Backend Error:', e));
```

Isso mostrará exatamente qual URL está sendo usada e se está funcionando.
