#!/bin/bash

# Script para criar estrutura de projeto Xcode
# Execute este script APÓS criar o projeto no Xcode manualmente

echo "📱 Preparando projeto iOS WishBox..."
echo ""
echo "Este script ajuda a organizar os arquivos."
echo "PRIMEIRO: Crie o projeto no Xcode (File → New → Project)"
echo ""
read -p "Pressione Enter quando tiver criado o projeto no Xcode..."

# Verificar se estamos no diretório correto
if [ ! -d "WishBox" ]; then
    echo "❌ Erro: Diretório WishBox não encontrado"
    echo "Execute este script do diretório: ios/WishBox/"
    exit 1
fi

echo "✅ Estrutura de arquivos pronta!"
echo ""
echo "📋 PRÓXIMOS PASSOS:"
echo ""
echo "1. No Xcode:"
echo "   - File → Add Files to 'WishBox'..."
echo "   - Selecione a pasta 'WishBox' (dentro de ios/WishBox/)"
echo "   - Marque 'Create groups' (NÃO 'Create folder references')"
echo "   - Marque 'Copy items if needed'"
echo "   - Marque Target 'WishBox'"
echo "   - Clique 'Add'"
echo ""
echo "2. Configure WishBoxApp.swift como entry point"
echo ""
echo "3. Configure Info.plist (NSAppTransportSecurity)"
echo ""
echo "4. Compile: Cmd+B"
echo ""
echo "5. Execute: Cmd+R"
echo ""
