# ❓ O que é `/health`?

## Explicação Simples

`/health` é um **endpoint de verificação** do backend. É como perguntar: "Backend, você está funcionando?"

## Como Funciona

### 1. O que é um endpoint?
- É uma **rota/URL** do backend
- Cada endpoint faz uma coisa diferente
- Exemplos:
  - `/health` → Verifica se está funcionando
  - `/api/search` → Busca produtos

### 2. O que `/health` faz?
- Retorna uma resposta simples dizendo que o backend está OK
- Não faz nada complexo, só confirma que está rodando

## Como Testar

### No Navegador:

1. Pegue a URL do seu backend no Railway
   - Exemplo: `https://wishbox-production.up.railway.app`

2. Adicione `/health` no final:
   ```
   https://wishbox-production.up.railway.app/health
   ```

3. Cole no navegador e pressione Enter

4. **O que deve aparecer:**
   ```json
   {
     "status": "ok",
     "timestamp": "2024-01-15T10:30:00.000Z",
     "service": "wishbox-backend"
   }
   ```

✅ **Se aparecer isso:** Backend está funcionando!
❌ **Se der erro 404:** URL está errada ou backend não está deployado
❌ **Se der erro de conexão:** Backend não está acessível

## Exemplo Visual

```
URL do Backend:  https://wishbox-production.up.railway.app
                    ↓
Adicione /health: https://wishbox-production.up.railway.app/health
                    ↓
Resultado:        {"status":"ok",...}
```

## Por que Usar?

- ✅ **Teste rápido:** Verifica se o backend está no ar
- ✅ **Diagnóstico:** Se `/health` não funciona, o backend não está acessível
- ✅ **Simples:** Não precisa passar parâmetros ou fazer login

## Outros Endpoints

- `/health` → Verifica se está funcionando
- `/api/search?query=presentes` → Busca produtos
- `/api/search?query=café&limit=10` → Busca com limite

## Resumo

**`/health` = "Backend, você está aí?"**
- Se responder `{"status":"ok"}` → ✅ Está funcionando
- Se não responder → ❌ Tem problema

É só uma forma simples de testar se o backend está acessível!
