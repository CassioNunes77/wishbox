# 🔧 Fix: Erro 403 do Magazine Luiza

## ❌ Erro

```
=== ApiService: Response status: 403
```

## 🔍 Causa

O Magazine Luiza está **bloqueando requisições automatizadas** com erro **403 (Forbidden)**. Isso acontece porque:

1. **IP da Netlify Function** pode estar em uma blacklist
2. **Headers insuficientes** - falta headers que navegadores reais enviam
3. **Falta de Referer/Origin** - sites de e-commerce verificam de onde vem a requisição
4. **Falta de headers Sec-Fetch-*** - navegadores modernos enviam esses headers

## ✅ Solução Aplicada

### 1. Headers Completos Adicionados

Agora a Netlify Function envia headers completos que simulam um navegador real:

```javascript
headers: {
  'User-Agent': 'Mozilla/5.0...',
  'Accept': 'text/html,application/xhtml+xml...',
  'Accept-Language': 'pt-BR,pt;q=0.9...',
  'Accept-Encoding': 'gzip, deflate, br',
  'Connection': 'keep-alive',
  'Upgrade-Insecure-Requests': '1',
  'Sec-Fetch-Dest': 'document',      // ✅ NOVO
  'Sec-Fetch-Mode': 'navigate',      // ✅ NOVO
  'Sec-Fetch-Site': 'none',          // ✅ NOVO
  'Sec-Fetch-User': '?1',            // ✅ NOVO
  'Cache-Control': 'max-age=0',      // ✅ NOVO
  'DNT': '1',                        // ✅ NOVO
  'Referer': 'https://www.google.com/', // ✅ NOVO
  'Origin': 'https://www.magazineluiza.com.br', // ✅ NOVO
}
```

### 2. Tratamento de Erro 403

Agora o erro 403 retorna uma mensagem descritiva:

```json
{
  "success": false,
  "error": "Acesso negado pelo Magazine Luiza...",
  "details": "O Magazine Luiza detectou que esta é uma requisição automatizada...",
  "products": [],
  "count": 0
}
```

### 3. Logs Detalhados

Adicionados logs para debug:
- Response headers
- Preview dos dados da resposta
- Status HTTP detalhado

## 🔄 Próximos Passos

### 1. Testar Novamente

Após o deploy no Netlify, teste novamente no app iOS.

### 2. Se Ainda Der 403

**Opções:**

#### Opção A: Usar Backend Separado (Recomendado)

Configure um backend separado (ex: Railway, Render) que:
- Tenha IP fixo/dedicado
- Possa fazer requisições mais parecidas com navegadores
- Use proxy/rotating IPs se necessário

#### Opção B: Usar API Oficial

Se o Magazine Luiza tiver uma API oficial, use ela em vez de scraping.

#### Opção C: Adicionar Delay/Throttling

Adicione delays entre requisições para parecer mais humano:

```javascript
// Esperar 1-3 segundos antes de fazer requisição
await new Promise(resolve => setTimeout(resolve, Math.random() * 2000 + 1000));
```

#### Opção D: Usar Proxy Service

Use um serviço de proxy como:
- Bright Data
- ScraperAPI
- ProxyMesh

## 📝 Notas

- **Scraping pode ser bloqueado** por sites de e-commerce
- **Headers completos** ajudam, mas não garantem 100% de sucesso
- **IP do servidor** pode estar em blacklist do Magazine Luiza
- **Melhor solução**: usar API oficial ou backend dedicado

## 🎯 Status

- ✅ Headers completos adicionados
- ✅ Tratamento de erro 403 melhorado
- ✅ Logs detalhados para debug
- ⚠️ Pode ainda receber 403 se IP estiver bloqueado
