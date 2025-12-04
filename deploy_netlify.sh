#!/bin/bash

echo "🚀 Deploying WishBox to Netlify..."

# Build Flutter Web
echo "📦 Building Flutter Web..."
flutter build web --release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

# Verificar se Netlify CLI está instalado
if ! command -v netlify &> /dev/null; then
    echo "📥 Netlify CLI not found. Installing..."
    npm install -g netlify-cli
fi

# Deploy para Netlify
echo "🌐 Deploying to Netlify..."
netlify deploy --prod --dir=build/web

echo "✅ Deploy completed!"

