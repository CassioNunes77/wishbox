# 🚫 Problema: Bloqueio 403 do Magazine Luiza

## Situação Atual

O Magazine Luiza está bloqueando requisições automatizadas (erro 403). Isso é comum em scraping - sites comerciais têm proteção anti-bot robusta.

**Status:**
- ✅ Backend funcionando corretamente
- ✅ Frontend conectando ao backend
- ✅ Mensagens de erro claras
- ❌ Magazine Luiza bloqueando scraping (403 Forbidden)

---

## 🔍 Por Que Está Acontecendo?

O Magazine Luiza detecta que as requisições não vêm de navegadores reais através de:
- Verificação de headers HTTP
- Análise de padrões de requisição
- Verificação de IP/geolocalização
- JavaScript challenges (Cloudflare, etc.)
- Rate limiting

---

## ✅ Melhorias Aplicadas

1. **Delay aleatório** (2-5 segundos) - Parecer mais humano
2. **Rotação de User-Agents** - Diferentes navegadores
3. **Headers completos** - Sec-Fetch, sec-ch-ua, etc.
4. **Referer do Google** - Parecer que veio de busca
5. **Timeout aumentado** - 25 segundos

---

## 🎯 Soluções Práticas

### Solução 1: Aguardar e Tentar Novamente ⏰

O bloqueio pode ser temporário:
- Aguarde 15-30 minutos
- Tente novamente
- Pode funcionar após algum tempo

### Solução 2: Usar Serviço de Proxy Profissional 💼 (Recomendado)

**ScraperAPI:**
- https://www.scraperapi.com
- Rotaciona IPs automaticamente
- Evita bloqueios
- Custo: ~$29/mês (100k requests)

**Implementação:**
```javascript
const response = await axios.get(searchUrl, {
  url: `http://api.scraperapi.com?api_key=YOUR_KEY&url=${encodeURIComponent(searchUrl)}`,
  // ... outros headers
});
```

### Solução 3: Implementar Puppeteer 🤖

Simular navegador real (mais pesado):

```bash
npm install puppeteer
```

```javascript
const puppeteer = require('puppeteer');

const browser = await puppeteer.launch({
  headless: true,
  args: ['--no-sandbox', '--disable-setuid-sandbox']
});
const page = await browser.newPage();
await page.goto(searchUrl, { waitUntil: 'networkidle2' });
const html = await page.content();
await browser.close();
```

**Vantagens:**
- Parece navegador real
- Executa JavaScript
- Menos bloqueios

**Desvantagens:**
- Muito mais pesado (mais memória)
- Mais lento (10-30s por requisição)
- Precisa de mais recursos no Railway

### Solução 4: Verificar API Oficial do Magazine Luiza 📡

O Magazine Luiza pode ter:
- API para parceiros/afiliados
- Programa de afiliados com API
- Contato: https://www.magazineluiza.com.br/parceiros

---

## 🔄 Teste Local Primeiro

Antes de implementar soluções complexas, teste localmente:

```bash
cd backend
npm start
```

Em outro terminal:
```bash
curl "http://localhost:3000/api/search?query=café&limit=3"
```

**Se funcionar localmente mas não no Railway:**
- IP do Railway pode estar bloqueado
- Solução: usar proxy

---

## 📊 Recomendação

**Para produção:**
1. **Curto prazo:** Aguardar e testar novamente
2. **Médio prazo:** Implementar ScraperAPI ou similar
3. **Longo prazo:** Verificar API oficial do Magazine Luiza

**Para desenvolvimento:**
- Testar localmente primeiro
- Se funcionar local, o problema é IP do Railway

---

## 🐛 Debug

### Ver Logs do Railway

1. Railway Dashboard → Seu projeto
2. Deployments → Último deployment
3. View logs
4. Procure por: `HTTP 403`, `Erro 403`, `Request failed`

### Testar Backend Diretamente

```bash
curl "https://wishbox-production-f9ef.up.railway.app/api/search?query=café&limit=3"
```

Veja a resposta completa.

---

## ⚠️ Nota Importante

Scraping de sites comerciais pode violar:
- Terms of Service (ToS)
- Políticas anti-bot
- Leis de propriedade intelectual

**Recomendação:** Use sempre APIs oficiais quando disponíveis, ou serviços de scraping profissionais que respeitam os ToS.

---

## 📝 Próximos Passos

1. **Aguardar deploy** das melhorias (já aplicadas)
2. **Testar novamente** após alguns minutos
3. **Se persistir:** Considerar ScraperAPI ou Puppeteer
4. **Verificar** se Magazine Luiza tem API oficial
