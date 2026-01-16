#!/bin/bash

echo "🔍 Verificando configuração iOS..."
echo ""

# Verificar Flutter
echo "📱 Flutter:"
flutter --version | head -1

# Verificar Xcode
echo ""
echo "📱 Xcode:"
xcodebuild -version 2>/dev/null | head -1

# Verificar code signing
echo ""
echo "🔐 Code Signing:"
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -showBuildSettings 2>/dev/null | grep -E "CODE_SIGN|DEVELOPMENT_TEAM|PRODUCT_BUNDLE_IDENTIFIER" | head -5

# Verificar provisioning profiles
echo ""
echo "📄 Provisioning Profiles:"
ls -la ~/Library/MobileDevice/Provisioning\ Profiles/ 2>/dev/null | wc -l | xargs -I {} echo "{} perfis encontrados"

# Verificar certificados
echo ""
echo "🔑 Certificados de Code Signing:"
security find-identity -v -p codesigning 2>/dev/null | grep -i "iphone developer" | head -3

echo ""
echo "✅ Verificação concluída!"
echo ""
echo "📋 Próximos passos:"
echo "1. Verifique se o app está marcado como 'Confiar' no iPhone"
echo "2. No Xcode: Product > Clean Build Folder (⇧⌘K)"
echo "3. Conecte o iPhone e execute o app (⌘R)"
