# 🧪 Teste Local do Backend

## Por Que Testar Localmente?

O erro 403 pode ser causado por:
1. **IP do Railway bloqueado** pelo Magazine Luiza
2. **Proteção anti-bot melhorada** no Magazine Luiza
3. **Problema específico do ambiente** Railway

Testar localmente ajuda a identificar se o problema é o IP ou o código.

---

## ✅ Como Testar Localmente

### 1. Iniciar Backend Local

```bash
cd backend
npm install  # Se ainda não instalou
npm start
```

Você deve ver:
```
🚀 Servidor rodando na porta 3000
📡 Health check: http://localhost:3000/health
```

### 2. Testar Health Check

Em outro terminal:
```bash
curl http://localhost:3000/health
```

Deve retornar:
```json
{"status":"ok","timestamp":"...","service":"wishbox-backend"}
```

### 3. Testar Busca de Produtos

```bash
curl "http://localhost:3000/api/search?query=café&limit=3"
```

**Se funcionar localmente:**
- ✅ Código está correto
- ❌ IP do Railway está bloqueado
- 💡 Solução: Usar proxy ou mudar de plataforma

**Se não funcionar localmente:**
- ❌ Magazine Luiza melhorou proteção anti-bot
- 💡 Solução: Usar Puppeteer ou serviço de proxy

---

## 🔍 Verificar Logs

Quando testar, veja os logs no terminal onde o backend está rodando:

**Sucesso:**
```
[2024-01-16T...] Buscando produtos: "café"
[2024-01-16T...] URL de busca: https://www.magazineluiza.com.br/busca/café
[2024-01-16T...] HTML recebido (123456 bytes)
[2024-01-16T...] 3 produtos encontrados
```

**Erro 403:**
```
[2024-01-16T...] Buscando produtos: "café"
[2024-01-16T...] URL de busca: https://www.magazineluiza.com.br/busca/café
[2024-01-16T...] HTTP 403
[2024-01-16T...] Erro 403: Magazine Luiza bloqueou a requisição
```

---

## 📊 Interpretação dos Resultados

### Cenário 1: Funciona Localmente, Não Funciona no Railway

**Causa:** IP do Railway bloqueado

**Soluções:**
1. Usar serviço de proxy (ScraperAPI, Bright Data)
2. Deploy em outra plataforma (Render, Heroku)
3. Usar VPN/proxy no Railway

### Cenário 2: Não Funciona Nem Localmente

**Causa:** Magazine Luiza melhorou proteção anti-bot

**Soluções:**
1. Implementar Puppeteer (navegador real)
2. Usar serviço de scraping profissional
3. Verificar se há API oficial do Magazine Luiza

### Cenário 3: Funciona em Ambos

**Causa:** Problema temporário ou cache

**Solução:** Aguardar e tentar novamente

---

## 🚀 Próximos Passos

1. **Teste localmente** seguindo os passos acima
2. **Compare resultados** local vs Railway
3. **Me informe o resultado** para decidirmos a melhor solução

---

## 💡 Dica

Se funcionar localmente mas não no Railway, o problema é o IP. Nesse caso, a melhor solução é usar um serviço de proxy profissional que rotaciona IPs.
