# 🚀 Como Obter a URL do Backend no Railway

## Passo a Passo Visual

### 1. Na tela de Settings que você está:

1. **Encontre a seção "Public Networking"**
   - Está logo abaixo do título "Networking"
   - Tem a descrição: "Access to this service publicly through HTTP or TCP"

2. **Clique no botão "Generate Domain"** ⚡
   - É o primeiro botão roxo com ícone de raio
   - Está ao lado de "Custom Domain" e "TCP Proxy"

3. **Aguarde alguns segundos**
   - Railway vai gerar uma URL automática
   - Algo como: `https://wishbox-production.up.railway.app`

4. **Copie a URL gerada**
   - Aparecerá abaixo do botão ou em uma nova seção
   - Copie essa URL completa

### 2. Alternativa: Verificar em "Deployments"

Se não aparecer na Settings:

1. Clique na aba **"Deployments"** (no topo)
2. Clique no deployment mais recente
3. Procure por "Public URL" ou "Domain"
4. Copie a URL

### 3. Verificar se está funcionando

Depois de obter a URL, teste:

```bash
# No terminal ou navegador, teste:
https://sua-url-railway.app/health
```

Deve retornar:
```json
{"status":"ok","timestamp":"...","service":"wishbox-backend"}
```

## ⚠️ Importante

- A URL gerada é permanente (não muda)
- Use essa URL no Netlify como `NEXT_PUBLIC_BACKEND_URL`
- Não precisa configurar nada mais no Railway

## 📝 Próximo Passo

Depois de copiar a URL:

1. Vá para o Netlify
2. Site settings → Environment variables
3. Adicione: `NEXT_PUBLIC_BACKEND_URL` = sua URL do Railway
4. Faça novo deploy

✅ Pronto!
