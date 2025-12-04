# Deploy no Netlify

## Configuração Automática

O projeto já está configurado com `netlify.toml`. Para fazer deploy:

### Opção 1: Deploy via GitHub (Recomendado)

1. Conecte seu repositório GitHub ao Netlify
2. O Netlify detectará automaticamente o `netlify.toml`
3. Configure:
   - **Build command:** `flutter pub get && flutter build web --release`
   - **Publish directory:** `build/web`
   - **Flutter version:** 3.24.0 (ou a versão que você tem instalada)

### Opção 2: Deploy Manual

1. Build local:
   ```bash
   flutter pub get
   flutter build web --release
   ```

2. Arraste a pasta `build/web` para o Netlify Drop

## Configurações Importantes

### Variáveis de Ambiente (se necessário)

No Netlify Dashboard:
- Site settings > Build & deploy > Environment variables

### Build Settings

O `netlify.toml` já está configurado com:
- Build command: `flutter pub get && flutter build web --release`
- Publish directory: `build/web`
- Redirects para SPA (Single Page Application)
- Headers de segurança e cache

## Troubleshooting

### Página em branco

1. Verifique se o build foi concluído com sucesso
2. Verifique o console do navegador (F12) para erros
3. Certifique-se de que o `publish directory` está como `build/web`
4. Verifique se os arquivos `flutter_bootstrap.js` e `main.dart.js` estão presentes

### Erro de build

1. Verifique se o Flutter está instalado no Netlify
2. Adicione a variável de ambiente `FLUTTER_VERSION` se necessário
3. Verifique os logs de build no Netlify

### Assets não carregam

1. Verifique se o `base href` está correto no `index.html`
2. Certifique-se de que os caminhos dos assets estão relativos
3. Verifique o `manifest.json` e os ícones

## Estrutura de Arquivos

Após o build, a pasta `build/web/` deve conter:
- `index.html`
- `flutter_bootstrap.js`
- `main.dart.js`
- `assets/` (se houver)
- `icons/`
- `manifest.json`
- `favicon.png`
- `_redirects`

