# 🔧 Como Configurar Backend no Netlify

## Problema: "Endpoint do backend não encontrado"

O backend está funcionando no Railway, mas o Netlify não está conseguindo acessar.

---

## ✅ Solução Passo a Passo

### 1. Obter URL do Backend (Railway)

Você já tem: `https://wishbox-production-f9ef.up.railway.app`

Teste para confirmar:
```
https://wishbox-production-f9ef.up.railway.app/health
```
Deve retornar: `{"status":"ok",...}` ✅

---

### 2. Configurar no Netlify

1. **Acesse:** https://app.netlify.com
2. **Selecione seu site:** `wish2box` (ou o nome do seu site)
3. **Vá em:** Site settings (ícone de engrenagem no topo)
4. **Clique em:** "Environment variables" (no menu lateral)
5. **Clique em:** "Add variable" (botão)
6. **Configure:**
   - **Key:** `NEXT_PUBLIC_BACKEND_URL`
   - **Value:** `https://wishbox-production-f9ef.up.railway.app`
   - ⚠️ **IMPORTANTE:** Sem barra no final!
7. **Clique em:** "Save"

---

### 3. Fazer Novo Deploy

⚠️ **CRUCIAL:** Após adicionar a variável, você DEVE fazer um novo deploy!

1. **Vá em:** "Deploys" (no menu superior)
2. **Clique em:** "Trigger deploy" (botão no canto superior direito)
3. **Selecione:** "Deploy site"
4. **Aguarde** o deploy completar (pode levar 2-5 minutos)

---

### 4. Verificar se Funcionou

1. **Acesse:** https://wish2box.netlify.app
2. **Abra o console:** Pressione F12
3. **Procure por logs:** `=== ApiService:`
4. **Verifique:**
   - Deve mostrar: `Using backend: https://wishbox-production-f9ef.up.railway.app`
   - Não deve mostrar: `http://localhost:3000`

---

## 🔍 Verificação Rápida

### No Console do Navegador (F12):

Cole este código e pressione Enter:

```javascript
console.log('Backend URL:', process.env.NEXT_PUBLIC_BACKEND_URL);
```

**Deve mostrar:**
```
Backend URL: https://wishbox-production-f9ef.up.railway.app
```

**Se mostrar `undefined` ou `http://localhost:3000`:**
- Variável não está configurada
- Ou frontend não foi redeployado

---

## ⚠️ Erros Comuns

### Erro: "Endpoint do backend não encontrado"
**Causa:** Variável não configurada ou frontend não redeployado
**Solução:** 
1. Configure a variável
2. **FAÇA NOVO DEPLOY** (muito importante!)

### Erro: "Network Error" ou CORS
**Causa:** Backend não está acessível ou CORS bloqueado
**Solução:** 
- Teste a URL diretamente: `https://wishbox-production-f9ef.up.railway.app/health`
- Se funcionar, o problema é no Netlify (variável ou deploy)

### Variável não aparece no código
**Causa:** Frontend não foi redeployado após configurar
**Solução:** 
- Variáveis de ambiente só são aplicadas em novos deploys
- **SEMPRE faça novo deploy após adicionar variáveis!**

---

## 📝 Checklist

- [ ] Backend funcionando no Railway (`/health` retorna OK)
- [ ] Variável `NEXT_PUBLIC_BACKEND_URL` configurada no Netlify
- [ ] URL está correta (sem barra no final)
- [ ] **NOVO DEPLOY feito após configurar a variável** ⚠️
- [ ] Console mostra a URL correta sendo usada
- [ ] Teste de busca funciona

---

## 🚨 Lembrete Importante

**Variáveis de ambiente no Netlify só funcionam após um novo deploy!**

Se você configurou a variável mas não fez deploy, ela não será aplicada.

**Sempre faça:**
1. Configurar variável → Salvar
2. **Trigger deploy** → Deploy site
3. Aguardar deploy completar
4. Testar

---

## ✅ Próximos Passos

1. Configure `NEXT_PUBLIC_BACKEND_URL` no Netlify
2. **FAÇA NOVO DEPLOY** (muito importante!)
3. Aguarde deploy completar
4. Teste a busca no site
5. Verifique o console (F12) para logs

Se ainda não funcionar após o deploy, me avise!
