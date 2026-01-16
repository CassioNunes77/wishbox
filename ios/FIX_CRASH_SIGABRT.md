# 🔧 Fix: Crash SIGABRT no iOS

## ❌ Erro

```
Thread 1: signal SIGABRT
dyld`__abort_with_payload
```

## 🔍 Causa

O crash SIGABRT geralmente ocorre quando:
1. **Múltiplos entry points** (@main em vários arquivos)
2. **Referências a arquivos inexistentes** no `project.pbxproj`
3. **Falta configuração no Info.plist** (UIApplicationSceneManifest)
4. **Frameworks faltando ou quebrados**

## ✅ Soluções Aplicadas

### 1. Removidas Referências Flutter

✅ Removido `AppDelegate.swift` dos Sources  
✅ Removido `AppFrameworkInfo.plist` dos Resources  
✅ Removidos scripts Flutter do build

### 2. Configurado Info.plist para SwiftUI

✅ Adicionado `UIApplicationSceneManifest` (necessário para SwiftUI)

### 3. Verificado Entry Point

✅ Apenas `WishBoxApp.swift` tem `@main`  
✅ Não há conflitos de entry points

## 🔧 Se o Crash Persistir

### 1. Limpar Build Completamente

```bash
# No terminal:
cd ios
rm -rf build/
rm -rf Runner.xcodeproj/xcuserdata/
rm -rf ~/Library/Developer/Xcode/DerivedData/
```

No Xcode:
1. **Product → Clean Build Folder** (Shift+Cmd+K)
2. **Quit Xcode**
3. **Abra Xcode novamente**
4. **Compile:** Cmd+B

### 2. Verificar Logs do Console

No Xcode, veja o console para ver a mensagem de erro exata:
- **View → Debug Area → Show Debug Area** (Shift+Cmd+Y)
- Veja a mensagem de erro completa

### 3. Verificar se Todos os Arquivos Estão no Target

1. **Selecione cada arquivo Swift** no Navigator
2. **File Inspector** (painel direito)
3. **Target Membership:** Marque "Runner"

### 4. Verificar Swift Version

1. **Target "Runner" → Build Settings**
2. **Swift Language Version:** Deve ser `Swift 5` ou `Swift 5.9`
3. **Swift Compiler - Language:**
   - **Swift Language Version:** `Swift 5.9`

### 5. Verificar Importações

Certifique-se que todos os arquivos Swift têm:
```swift
import SwiftUI  // Para Views
import Foundation  // Para Services/Types
```

## ✅ Checklist de Verificação

- [ ] Apenas `WishBoxApp.swift` tem `@main`
- [ ] `Info.plist` tem `UIApplicationSceneManifest`
- [ ] Não há referências a `AppDelegate.swift` no `project.pbxproj`
- [ ] Não há referências a `AppFrameworkInfo.plist` no `project.pbxproj`
- [ ] Todos os arquivos Swift estão no Target "Runner"
- [ ] Swift Version: 5.9
- [ ] iOS Deployment Target: 16.0+
- [ ] Build limpo (Shift+Cmd+K)
- [ ] Compila sem erros (Cmd+B)

## 📝 Logs de Debug

Para ver logs detalhados no console:

1. **No Xcode:** Product → Scheme → Edit Scheme
2. **Run → Arguments**
3. **Environment Variables:**
   - Adicione: `OS_ACTIVITY_MODE` = `disable` (para menos logs)
   - Ou remova para ver todos os logs

## 🎯 Próximos Passos

1. **Limpar build completamente**
2. **Compilar novamente** (Cmd+B)
3. **Ver logs do console** se ainda crashar
4. **Verificar se todos os arquivos estão no Target**
