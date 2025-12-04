# Como Corrigir o Erro "Command PhaseScriptExecution failed"

## ⚠️ IMPORTANTE: Use o Workspace Correto!

O erro acontece quando você abre o **arquivo errado** no Xcode ou há problemas com os scripts de build.

## ✅ Solução Rápida:

### 1. Feche o Xcode completamente
- Se o Xcode estiver aberto, feche completamente (Cmd + Q)

### 2. Limpe tudo e reinstale

Execute no terminal:
```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter clean
flutter pub get
cd ios
rm -rf Pods Podfile.lock .symlinks
pod install
cd ..
```

### 3. Abra o Workspace correto

**IMPORTANTE:** Abra o arquivo `.xcworkspace`, NÃO o `.xcodeproj`!

**Opção A - Pelo Terminal:**
```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
open ios/Runner.xcworkspace
```

**Opção B - Pelo Finder:**
1. Navegue até: `/Users/Cassio/Documents/Xcode Projects/WishBox/ios/`
2. Abra o arquivo: **Runner.xcworkspace** (NÃO o .xcodeproj)

### 4. No Xcode, limpe o build:
- **Product → Clean Build Folder** (Shift + Cmd + K)

### 5. Compile novamente:
- **Product → Build** (Cmd + B)
- Ou **Product → Run** (Cmd + R)

## 🔍 Verificação:

No Xcode, verifique:
- No topo deve aparecer **"Runner"** (não "WishBox")
- No painel esquerdo, você deve ver:
  - ✅ Runner (projeto)
  - ✅ Pods (projeto dos CocoaPods)

Se você **NÃO** ver "Pods" no painel esquerdo, você abriu o arquivo errado! ❌

## 🛠️ Se ainda não funcionar:

### Verificar scripts de build:

1. No Xcode, selecione o projeto "Runner" no painel esquerdo
2. Selecione o target "Runner"
3. Vá na aba "Build Phases"
4. Verifique se há um script "Run Script" com:
   ```
   /bin/sh "$FLUTTER_ROOT/packages/flutter_tools/bin/xcode_backend.sh" build
   ```
5. Se não houver, o Flutter precisa regenerar os arquivos iOS

### Regenerar arquivos iOS:

```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter create --platforms=ios .
cd ios
pod install
```

Depois abra novamente o `ios/Runner.xcworkspace`.

## 📱 Alternativa: Usar Flutter Run

Se o Xcode continuar dando erro, use o Flutter diretamente:

```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter run
```

Isso vai compilar e rodar o app sem precisar do Xcode.


