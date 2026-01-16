# Build e Deploy da Versão Web

## Desenvolvimento Local

Para rodar a versão web localmente:

```bash
# Instalar dependências
flutter pub get

# Rodar em modo desenvolvimento
flutter run -d chrome

# Ou buildar para produção
flutter build web --release
```

## Build para Produção

```bash
# Build otimizado para produção
flutter build web --release

# Os arquivos compilados estarão em: build/web/
```

## Deploy no GitHub Pages

### Opção 1: Deploy Automático (Recomendado)

O projeto já está configurado com GitHub Actions. Quando você fizer push para a branch `main` ou `master`, o workflow automaticamente:

1. Builda o projeto Flutter para web
2. Faz deploy para GitHub Pages na branch `gh-pages`

**Para ativar:**
1. Vá em Settings > Pages no seu repositório GitHub
2. Selecione "Deploy from a branch"
3. Escolha a branch `gh-pages` e pasta `/ (root)`
4. Salve

### Opção 2: Deploy Manual

```bash
# 1. Build do projeto
flutter build web --release --base-href /WishBox/

# 2. Copiar arquivos para pasta docs (alternativa)
cp -r build/web/* docs/

# 3. Commit e push
git add docs/
git commit -m "Deploy web version"
git push origin main
```

Depois, configure GitHub Pages para servir da pasta `docs/`.

## Estrutura de Arquivos

```
WishBox/
├── lib/                    # Código Flutter compartilhado
├── web/                     # Arquivos web específicos
│   ├── index.html          # HTML principal
│   ├── manifest.json       # PWA manifest
│   └── icons/              # Ícones do app
├── index.html              # Redirecionamento para GitHub Pages
└── build/web/              # Arquivos compilados (gerado)
```

## Notas

- O código Flutter em `lib/` é compartilhado entre mobile e web
- A pasta `web/` contém apenas arquivos específicos da web (HTML, manifest, ícones)
- O `index.html` na raiz redireciona para a versão web quando acessado via GitHub Pages
- Para desenvolvimento local, use `flutter run -d chrome`



