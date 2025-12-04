#!/bin/bash

echo "🚀 DEPLOY SIMPLES PARA NETLIFY"
echo "================================"
echo ""

# Build
echo "📦 Fazendo build..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ Erro no build!"
    exit 1
fi

echo ""
echo "✅ Build concluído!"
echo ""
echo "📁 Pasta pronta: build/web/"
echo ""
echo "🌐 AGORA NO NETLIFY:"
echo "1. Acesse: https://app.netlify.com/sites/corevowishbox/deploys"
echo "2. Arraste a pasta 'build/web' para a área de deploy"
echo "3. Aguarde o upload"
echo "4. Pronto!"
echo ""
echo "OU use o Netlify CLI (se tiver instalado):"
echo "   netlify deploy --prod --dir=build/web"

