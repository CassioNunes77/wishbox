#!/bin/bash

# Script para buildar a versão web do WishBox

echo "🚀 Building WishBox Web Version..."
echo ""

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter não encontrado. Por favor, instale o Flutter primeiro."
    exit 1
fi

# Instalar dependências
echo "📦 Instalando dependências..."
flutter pub get

# Build para web
echo ""
echo "🔨 Building para web (release mode)..."
flutter build web --release --base-href /WishBox/

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build concluído com sucesso!"
    echo ""
    echo "📁 Arquivos compilados estão em: build/web/"
    echo ""
    echo "🌐 Para testar localmente, execute:"
    echo "   cd build/web"
    echo "   python3 -m http.server 8000"
    echo "   # Ou use qualquer servidor HTTP local"
    echo ""
    echo "📤 Para fazer deploy no GitHub Pages:"
    echo "   1. Faça commit e push dos arquivos"
    echo "   2. O GitHub Actions fará o deploy automaticamente"
    echo "   3. Ou copie build/web/* para a pasta docs/ e faça commit"
else
    echo ""
    echo "❌ Erro no build. Verifique os logs acima."
    exit 1
fi



