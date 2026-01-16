# 📱 Atualizar Projeto Xcode - Nova Versão SwiftUI

## ✅ O Que Foi Feito

1. ✅ **Removidos arquivos Flutter:**
   - `AppDelegate.swift` (Flutter)
   - `GeneratedPluginRegistrant.h/m` (Flutter)
   - `Runner-Bridging-Header.h` (Flutter)
   - `Main.storyboard` (não necessário com SwiftUI)

2. ✅ **Criados arquivos SwiftUI:**
   - `WishBoxApp.swift` (entry point SwiftUI)
   - Estrutura completa em `Runner/Core/` e `Runner/Presentation/`

3. ✅ **Atualizado Info.plist:**
   - Removidas referências Flutter
   - Mantido `NSAppTransportSecurity`

## 🔧 Próximos Passos no Xcode

### 1. Remover Referências Flutter do Projeto

1. **Abra `Runner.xcodeproj` no Xcode**
2. **No Navigator (esquerda):**
   - Delete `GeneratedPluginRegistrant.h` (se aparecer)
   - Delete `GeneratedPluginRegistrant.m` (se aparecer)
   - Delete `Runner-Bridging-Header.h` (se aparecer)
   - Delete `Main.storyboard` (se aparecer)
   - **MANTENHA:** `LaunchScreen.storyboard`

### 2. Adicionar Novos Arquivos Swift

1. **Clique com botão direito** em `Runner` (no Navigator)
2. **Add Files to "Runner"...**
3. **Selecione:**
   - `Runner/WishBoxApp.swift`
   - `Runner/Core/` (pasta inteira)
   - `Runner/Presentation/` (pasta inteira)
4. **IMPORTANTE:**
   - ✅ Marque **"Create groups"**
   - ✅ Marque **Target "Runner"**
   - ❌ NÃO marque "Copy items if needed" (já estão no lugar)
5. Clique **Add**

### 3. Configurar Entry Point

1. **Selecione o projeto** (topo do Navigator)
2. **Target:** Runner
3. **General → Deployment Info:**
   - **iOS:** 16.0 ou superior
4. **Build Settings → Swift Compiler - General:**
   - **Main Interface:** (deixe vazio ou delete)
5. **Build Settings → Info.plist Values:**
   - Verifique que `Info.plist` está configurado

### 4. Atualizar Scheme/Target

1. **Target:** Runner → **General**
2. **Deployment Info:** iOS 16.0+
3. **Info → Custom iOS Target Properties:**
   - Verifique que `Info.plist` aponta para `Runner/Info.plist`

### 5. Remover Referências Flutter do project.pbxproj

O Xcode pode mostrar erros relacionados a Flutter. Para limpar:

1. **Build Settings → Other Swift Flags:**
   - Remova flags relacionadas a Flutter
2. **Build Phases:**
   - Remova scripts relacionados a Flutter
   - Remova frameworks do Flutter (se aparecerem)

### 6. Compilar e Testar

1. **Limpar Build Folder:** Product → Clean Build Folder (Shift+Cmd+K)
2. **Compilar:** Cmd+B
3. **Se der erro:** Verifique que todos os arquivos Swift estão no Target "Runner"
4. **Executar:** Cmd+R

## 📁 Estrutura Final

```
Runner/
├── WishBoxApp.swift          ← Entry point SwiftUI
├── Info.plist                ← Configurado
├── Assets.xcassets/          ← Mantido
├── Base.lproj/
│   └── LaunchScreen.storyboard  ← Mantido
├── Core/
│   ├── Constants/
│   │   └── AppConstants.swift
│   ├── Services/
│   │   ├── ApiService.swift
│   │   ├── StoreService.swift
│   │   └── FavoritesService.swift
│   └── Types/
│       ├── Product.swift
│       └── AffiliateStore.swift
└── Presentation/
    ├── Views/
    │   ├── SplashView.swift
    │   ├── HomeView.swift
    │   ├── SuggestionsView.swift
    │   ├── ProductDetailView.swift
    │   ├── FavoritesView.swift
    │   └── AdminView.swift
    └── Components/
        ├── ProductCard.swift
        ├── ErrorView.swift
        └── EmptyStateView.swift
```

## ⚠️ Se Der Erro no Build

### Erro: "Cannot find 'SplashView'"
- Verifique que `SplashView.swift` está no Target "Runner"
- Verifique que não há erros de compilação em `SplashView.swift`

### Erro: Referências Flutter
- Delete `Flutter/` do projeto (pasta física)
- Delete `Pods/` se não usar CocoaPods
- Limpe: Product → Clean Build Folder

### Erro: Main.storyboard not found
- Remova `UIMainStoryboardFile` do `Info.plist` (já removido)

## ✅ Checklist

- [ ] Arquivos Flutter removidos do projeto Xcode
- [ ] Novos arquivos Swift adicionados ao Target "Runner"
- [ ] `WishBoxApp.swift` configurado como entry point
- [ ] Info.plist atualizado (sem referências Flutter)
- [ ] Deployment Target: iOS 16.0+
- [ ] Build Settings limpos (sem flags Flutter)
- [ ] Compila sem erros (Cmd+B)
- [ ] Executa no simulador (Cmd+R)
