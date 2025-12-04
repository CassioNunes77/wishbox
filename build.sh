#!/bin/bash
set -e

echo "🚀 Starting Flutter Web Build for Netlify..."

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "📥 Flutter not found, installing..."
    # Instalar Flutter (ajuste para sua arquitetura)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [[ $(uname -m) == "arm64" ]]; then
            FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.24.0-stable.tar.xz"
        else
            FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.0-stable.tar.xz"
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz"
    else
        echo "❌ Unsupported OS: $OSTYPE"
        exit 1
    fi
    
    curl -L "$FLUTTER_URL" | tar xj
    export PATH="$PWD/flutter/bin:$PATH"
fi

# Verificar versão do Flutter
flutter --version

# Obter dependências
echo "📦 Getting dependencies..."
flutter pub get

# Build para web
echo "🔨 Building for web..."
flutter build web --release

echo "✅ Build completed successfully!"
echo "📁 Output directory: build/web/"

