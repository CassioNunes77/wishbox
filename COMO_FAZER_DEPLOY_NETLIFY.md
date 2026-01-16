# 🚀 Como Fazer Deploy no Netlify

## Opções para Fazer Novo Deploy

### Opção 1: Trigger Deploy (Mais Comum)

1. **No Netlify Dashboard:**
   - Vá em **"Deploys"** (menu superior)
   - Clique no botão **"Trigger deploy"** (canto superior direito)
   - Selecione **"Deploy site"**
   - Aguarde completar

### Opção 2: Push para GitHub (Automático)

Se você fez commit e push para o GitHub:

1. **O Netlify faz deploy automaticamente**
2. Vá em **"Deploys"** para ver o progresso
3. Aguarde completar

### Opção 3: Redeploy do Último Deploy

1. **Vá em "Deploys"**
2. **Clique no último deploy** (o mais recente)
3. **Clique nos três pontinhos** (⋯) no canto superior direito
4. **Selecione "Redeploy"** ou **"Clear cache and retry deploy"**

### Opção 4: Forçar Novo Deploy via Git

Se nenhuma opção acima funcionar:

1. **Faça um pequeno commit:**
   ```bash
   git commit --allow-empty -m "trigger deploy"
   git push origin main
   ```

2. **O Netlify detecta automaticamente** e faz novo deploy

---

## ✅ Verificar se Deploy Foi Feito

1. **Vá em "Deploys"**
2. **Verifique o horário** do último deploy
3. **Deve ser DEPOIS** de você configurar a variável de ambiente
4. **Status deve estar verde** (sucesso)

---

## 🔍 Se Não Funcionar

### Verificar Variável de Ambiente

1. **Site settings** → **Environment variables**
2. **Confirme que `NEXT_PUBLIC_BACKEND_URL` está lá**
3. **Confirme que o valor está correto:** `https://wishbox-production-f9ef.up.railway.app`

### Verificar no Console

1. **Acesse o site:** https://wish2box.netlify.app
2. **Pressione F12**
3. **Console** → Procure por `=== ApiService:`
4. **Veja qual URL está sendo usada**

---

## 💡 Dica

**A forma mais garantida de forçar novo deploy:**

1. Faça um commit vazio:
   ```bash
   git commit --allow-empty -m "trigger netlify deploy"
   git push origin main
   ```

2. O Netlify detecta automaticamente e faz deploy
3. Aguarde 2-5 minutos
4. Teste novamente

---

## 📝 Checklist

- [ ] Variável `NEXT_PUBLIC_BACKEND_URL` configurada
- [ ] URL começa com `https://`
- [ ] Novo deploy feito (verificar horário em "Deploys")
- [ ] Deploy concluído com sucesso (verde)
- [ ] Console mostra URL correta
