#!/bin/bash

echo "🧹 Limpando arquivos de build antigos..."

# Limpar diretório de build do iOS
rm -rf build/ios/Debug-iphoneos
echo "✅ Diretório build/ios/Debug-iphoneos removido"

# Limpar Flutter
flutter clean
echo "✅ Flutter clean executado"

# Limpar Pods
cd ios
rm -rf Pods Podfile.lock .symlinks
echo "✅ Pods removidos"

# Reinstalar dependências
cd ..
flutter pub get
echo "✅ Dependências Flutter reinstaladas"

# Reinstalar Pods
cd ios
pod install --repo-update
echo "✅ Pods reinstalados"

cd ..
echo ""
echo "✨ Limpeza concluída! Agora você pode compilar no Xcode."
echo ""
echo "📱 Para compilar:"
echo "   1. Abra ios/Runner.xcworkspace no Xcode"
echo "   2. Selecione seu dispositivo ou simulador"
echo "   3. Pressione Cmd+R para compilar e executar"


