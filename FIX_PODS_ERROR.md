# Como Corrigir o Erro "Framework 'Pods_Runner' not found"

## ⚠️ IMPORTANTE: Use o Workspace, não o Projeto!

O erro acontece quando você abre o **arquivo errado** no Xcode.

### ❌ ERRADO:
- Abrir: `WishBox.xcodeproj` 
- Abrir: `ios/Runner.xcodeproj`

### ✅ CORRETO:
- Abrir: `ios/Runner.xcworkspace`

## Passos para Corrigir:

### 1. Feche o Xcode completamente
- Se o Xcode estiver aberto, feche completamente (Cmd + Q)

### 2. Abra o Workspace correto

**Opção A - Pelo Terminal:**
```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
open ios/Runner.xcworkspace
```

**Opção B - Pelo Finder:**
1. Navegue até: `/Users/Cassio/Documents/Xcode Projects/WishBox/ios/`
2. Abra o arquivo: **Runner.xcworkspace** (NÃO o .xcodeproj)

### 3. No Xcode, verifique:
- No topo deve aparecer **"Runner"** (não "WishBox")
- No painel esquerdo, você deve ver:
  - Runner (projeto)
  - Pods (projeto dos CocoaPods)

### 4. Limpe o build:
- No Xcode: **Product → Clean Build Folder** (Shift + Cmd + K)

### 5. Compile novamente:
- **Product → Build** (Cmd + B)
- Ou **Product → Run** (Cmd + R)

## Se ainda não funcionar:

Execute estes comandos no terminal:

```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter clean
flutter pub get
cd ios
rm -rf Pods Podfile.lock .symlinks
pod install
cd ..
flutter build ios --no-codesign
```

Depois abra novamente o `ios/Runner.xcworkspace` no Xcode.

## Diferença entre os arquivos:

- **`.xcodeproj`** = Projeto nativo Swift/Objective-C (NÃO use para Flutter)
- **`.xcworkspace`** = Workspace que inclui o projeto + CocoaPods (USE ESTE!)

## Verificação Rápida:

Se você ver "Pods" no painel esquerdo do Xcode, está correto! ✅
Se não ver "Pods", você abriu o arquivo errado. ❌

