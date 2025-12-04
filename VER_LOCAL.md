# 🌐 Ver Localmente - SUPER SIMPLES

## ✅ Opção 1: Flutter Run (Mais Fácil)

```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter run -d chrome
```

**Pronto!** O Chrome abre automaticamente com o app.

---

## ✅ Opção 2: Servir a Pasta Build (Se já fez build)

```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox/build/web"
python3 -m http.server 8000
```

Depois acesse: **http://localhost:8000**

---

## ✅ Opção 3: Servidor HTTP Simples (Mac)

```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox/build/web"
open -a "Google Chrome" http://localhost:8000
python3 -m http.server 8000
```

---

## 🎯 Recomendado:

**Use a Opção 1** - É a mais simples:
- `flutter run -d chrome`
- Pronto! Sem configurações!

