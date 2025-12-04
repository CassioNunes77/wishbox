#!/bin/bash

echo "🔧 Corrigindo configuração do projeto Flutter..."

cd "$(dirname "$0")"

echo "📦 Limpando projeto..."
flutter clean

echo "📥 Obtendo dependências..."
flutter pub get

echo "🍎 Limpando pods iOS..."
cd ios
rm -rf Pods Podfile.lock .symlinks

echo "📦 Reinstalando pods..."
pod install

cd ..

echo "✅ Configuração concluída!"
echo ""
echo "📱 Agora abra o workspace no Xcode:"
echo "   open ios/Runner.xcworkspace"
echo ""
echo "⚠️  IMPORTANTE: Use o arquivo .xcworkspace, NÃO o .xcodeproj!"


