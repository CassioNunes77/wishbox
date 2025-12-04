# Como Corrigir "No such module 'Flutter'" no Xcode

## ⚠️ IMPORTANTE: Use o Workspace Correto!

O erro "No such module 'Flutter'" geralmente acontece quando:
1. Você abriu o arquivo **errado** no Xcode
2. O Xcode não está encontrando o framework Flutter
3. O build folder precisa ser limpo

## ✅ Solução Passo a Passo:

### 1. Feche o Xcode Completamente
- Se o Xcode estiver aberto, feche completamente (Cmd + Q)
- Não apenas feche a janela, saia do aplicativo

### 2. Limpe e Reinstale Tudo

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

### 3. Abra o Workspace CORRETO

**❌ NÃO ABRA:**
- `WishBox.xcodeproj`
- `ios/Runner.xcodeproj`

**✅ ABRA:**
- `ios/Runner.xcworkspace`

**Opção A - Pelo Terminal:**
```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
open ios/Runner.xcworkspace
```

**Opção B - Pelo Finder:**
1. Navegue até: `/Users/Cassio/Documents/Xcode Projects/WishBox/ios/`
2. Abra o arquivo: **Runner.xcworkspace** (NÃO o .xcodeproj)
3. O ícone deve mostrar um cubo azul com vários projetos dentro

### 4. Verifique no Xcode

No painel esquerdo do Xcode, você DEVE ver:
- ✅ **Runner** (projeto principal)
- ✅ **Pods** (projeto dos CocoaPods)

Se você **NÃO** ver "Pods", você abriu o arquivo errado! ❌

### 5. Limpe o Build Folder no Xcode

No Xcode:
- **Product → Clean Build Folder** (Shift + Cmd + K)
- Aguarde a limpeza terminar

### 6. Atualize as Configurações Recomendadas

Se o Xcode mostrar "Update to recommended settings":
1. Clique no aviso amarelo
2. Selecione **"Update to recommended settings"**
3. Revise as mudanças (geralmente são seguras)
4. Clique em **"Perform Changes"**

### 7. Compile Novamente

No Xcode:
- **Product → Build** (Cmd + B)
- Ou **Product → Run** (Cmd + R)

## 🔍 Se Ainda Não Funcionar:

### Verificar Framework Search Paths:

1. No Xcode, selecione o projeto **Runner** no painel esquerdo
2. Selecione o target **Runner**
3. Vá na aba **Build Settings**
4. Procure por **"Framework Search Paths"** (use a busca)
5. Deve conter:
   - `$(inherited)`
   - `"${PODS_CONFIGURATION_BUILD_DIR}/Flutter"`
   - `"${PODS_ROOT}/../Flutter/ephemeral"`

### Verificar Header Search Paths:

1. Na mesma aba **Build Settings**
2. Procure por **"Header Search Paths"**
3. Deve conter:
   - `$(inherited)`
   - `"${PODS_CONFIGURATION_BUILD_DIR}/Flutter/Flutter.framework/Headers"`

### Verificar Swift Compiler - Search Paths:

1. Na mesma aba **Build Settings**
2. Procure por **"Import Paths"** (Swift)
3. Deve conter os paths do Flutter

## 📱 Alternativa: Usar Flutter CLI

Se o Xcode continuar dando erro, use o Flutter diretamente:

```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter run
```

Isso compila e executa sem precisar do Xcode.

## ✅ Verificação Final:

O build pelo Flutter CLI funcionou (`flutter build ios`), então o problema é específico do Xcode.

Certifique-se de:
- ✅ Estar usando `Runner.xcworkspace` (não `.xcodeproj`)
- ✅ Ver "Pods" no painel esquerdo do Xcode
- ✅ Ter limpo o build folder
- ✅ Ter atualizado as configurações recomendadas

## 🎯 Resumo:

1. Feche Xcode
2. Execute `flutter clean && flutter pub get && cd ios && rm -rf Pods Podfile.lock && pod install`
3. Abra `ios/Runner.xcworkspace` (NÃO o .xcodeproj)
4. Limpe o build folder (Shift + Cmd + K)
5. Atualize configurações recomendadas se solicitado
6. Compile (Cmd + B)


