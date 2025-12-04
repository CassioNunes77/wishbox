# 🚀 Deploy Simples - Passo a Passo

## ✅ MÉTODO MAIS SIMPLES POSSÍVEL

### 1. Build Local (No Seu Computador)

```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter build web --release
```

Aguarde terminar (alguns minutos).

---

### 2. Deploy no Netlify (Arrastar e Soltar)

1. **Acesse:** https://app.netlify.com/sites/corevowishbox/deploys

2. **Procure a área:** "Want to deploy a new version without connecting to Git?"

3. **Arraste a pasta `build/web`** do seu computador para essa área

4. **Aguarde** o upload terminar

5. **Pronto!** Acesse: https://corevowishbox.netlify.app/

---

## 📁 Onde está a pasta?

No Finder:
```
/Users/Cassio/Documents/Xcode Projects/WishBox/build/web
```

**Arraste essa pasta inteira para o Netlify!**

---

## ✅ É SÓ ISSO!

Não precisa de:
- ❌ GitHub Actions
- ❌ Secrets
- ❌ Configurações complexas
- ❌ Nada!

**Só:**
1. ✅ `flutter build web --release`
2. ✅ Arrastar `build/web` para o Netlify
3. ✅ Pronto!

---

## 🔄 Para Atualizar:

Sempre que fizer mudanças:
1. `flutter build web --release`
2. Arraste `build/web` para o Netlify novamente
3. Pronto!

