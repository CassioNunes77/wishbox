# Debug - Problema com Pesquisa

## Problema Identificado

A pesquisa não está retornando produtos. Os motivos mais comuns são:

### 1. **Backend não configurado no Netlify** ⚠️ MAIS PROVÁVEL

O frontend está tentando acessar `http://localhost:3000`, que não funciona em produção.

**Solução:**
1. Acesse o Netlify Dashboard
2. Vá em: **Site settings → Environment variables**
3. Adicione:
   - **Key:** `NEXT_PUBLIC_BACKEND_URL`
   - **Value:** URL do seu backend deployado (ex: `https://seu-backend.herokuapp.com`)
4. Faça um novo deploy

### 2. **Backend não está rodando**

Verifique se o backend está respondendo:
```bash
curl https://seu-backend.herokuapp.com/api/search?query=presentes
```

### 3. **Nenhuma loja ativa configurada**

Se não houver lojas ativas na área admin, a pesquisa não funcionará.

**Solução:**
1. Acesse: `https://wish2box.netlify.app/admin`
2. Verifique se há lojas cadastradas
3. Certifique-se de que pelo menos uma loja está **ATIVA**

## Como Verificar o Problema

### Em Desenvolvimento (Local):

1. Abra o console do navegador (F12)
2. Procure por logs começando com `=== ApiService:` ou `=== SuggestionsPage:`
3. Verifique:
   - URL do backend sendo usada
   - Lojas ativas encontradas
   - Erros de conexão

### Em Produção (Netlify):

1. Abra o console do navegador no site deployado
2. Procure por erros de rede ou CORS
3. Verifique se a variável `NEXT_PUBLIC_BACKEND_URL` está configurada

## Mensagens de Erro e Soluções

### "Não foi possível conectar ao backend"
- **Causa:** Backend não está acessível na URL configurada
- **Solução:** Verifique se o backend está deployado e a URL está correta

### "Nenhum produto encontrado"
- **Causa:** Backend retornou vazio (pode ser problema no scraping)
- **Solução:** Verifique os logs do backend

### "Endpoint do backend não encontrado"
- **Causa:** URL do backend está incorreta
- **Solução:** Corrija a variável `NEXT_PUBLIC_BACKEND_URL`

## Teste Rápido

Execute no console do navegador:

```javascript
// Verificar URL do backend
console.log('Backend URL:', process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:3000');

// Testar conexão
fetch('http://localhost:3000/api/search?query=presentes')
  .then(r => r.json())
  .then(d => console.log('Backend response:', d))
  .catch(e => console.error('Backend error:', e));
```

## Próximos Passos

1. **Configurar variável de ambiente no Netlify**
2. **Deploy do backend** (se ainda não estiver deployado)
3. **Verificar logs** do backend durante uma busca
4. **Testar com console aberto** para ver erros específicos
