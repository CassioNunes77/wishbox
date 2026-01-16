# 🔧 Como Corrigir Erro 404 no Railway

## Problema: 404 This page could not be found

Isso significa que o Railway não está encontrando o backend. Vamos corrigir:

---

## ✅ Solução Passo a Passo

### 1. Verificar Configuração no Railway

1. **Acesse o Railway Dashboard**
2. **Clique no seu projeto** `wishbox`
3. **Vá em "Settings"** (Configurações)
4. **Procure por "Root Directory"** ou "Source"
5. **Configure:**
   - **Root Directory:** `backend`
   - Ou **Source:** `backend`

⚠️ **IMPORTANTE:** O Railway precisa saber que o código está na pasta `backend`, não na raiz!

---

### 2. Verificar se o Deploy Está Rodando

1. **Vá na aba "Deployments"**
2. **Verifique o último deployment:**
   - ✅ **Sucesso (verde):** Deploy funcionou
   - ❌ **Erro (vermelho):** Clique para ver os logs

3. **Se houver erro, veja os logs:**
   - Clique no deployment com erro
   - Veja a mensagem de erro
   - Pode ser: "Cannot find module", "npm install failed", etc.

---

### 3. Verificar Comando de Start

No Railway, verifique se está configurado:

- **Start Command:** `npm start`
- Ou deixe vazio (Railway detecta automaticamente)

---

### 4. Verificar Estrutura do Projeto

O Railway precisa ver esta estrutura:

```
wishbox/
├── backend/
│   ├── server.js      ← Arquivo principal
│   ├── package.json   ← Dependências
│   └── ...
```

Se o Railway estiver olhando na raiz (não em `backend`), ele não vai encontrar o `server.js`.

---

### 5. Solução Rápida: Recriar o Projeto

Se nada funcionar:

1. **No Railway, delete o projeto atual**
2. **Crie um novo projeto:**
   - "New Project" → "Deploy from GitHub repo"
   - Escolha o repositório `wishbox`
3. **IMPORTANTE:** Quando criar, configure:
   - **Root Directory:** `backend`
4. **Aguarde o deploy**

---

### 6. Verificar Logs do Railway

1. **Vá em "Deployments"**
2. **Clique no deployment mais recente**
3. **Veja os logs:**
   - Procure por: "Server running on port"
   - Se não aparecer, o servidor não iniciou

**Logs esperados:**
```
🚀 Servidor rodando na porta 3000
📡 Health check: http://localhost:3000/health
```

---

### 7. Verificar Variáveis de Ambiente

No Railway Settings → Variables:

- **PORT:** Railway define automaticamente (não precisa configurar)
- Se tiver outras variáveis, verifique se estão corretas

---

## 🔍 Checklist de Verificação

- [ ] Root Directory está configurado como `backend`
- [ ] Deploy foi concluído com sucesso (verde)
- [ ] Logs mostram "Servidor rodando na porta"
- [ ] Não há erros nos logs
- [ ] package.json está na pasta `backend`
- [ ] server.js está na pasta `backend`

---

## 🚨 Problemas Comuns

### "Cannot find module"
**Causa:** Dependências não instaladas
**Solução:** Railway instala automaticamente, mas verifique os logs

### "Port already in use"
**Causa:** Conflito de porta
**Solução:** Railway define a porta automaticamente via `process.env.PORT`

### "Root directory not found"
**Causa:** Pasta `backend` não existe ou está com nome diferente
**Solução:** Verifique o nome da pasta no GitHub

---

## 📝 Próximos Passos

1. **Verifique Root Directory** no Railway Settings
2. **Veja os logs** do último deployment
3. **Se necessário, recrie o projeto** com Root Directory = `backend`
4. **Teste novamente:** `https://sua-url/health`

---

## 💡 Dica

O Railway precisa saber que o código está em `backend/`, não na raiz do repositório. Essa é a causa mais comum do erro 404!
