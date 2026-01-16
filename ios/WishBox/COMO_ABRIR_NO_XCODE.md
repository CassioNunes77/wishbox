# 📱 Como Abrir e Compilar no Xcode

## 🎯 Opção 1: Criar Novo Projeto Xcode (Recomendado)

### Passo 1: Criar Projeto no Xcode

1. **Abra o Xcode**
2. **File → New → Project**
3. **Selecione:**
   - Platform: **iOS**
   - Template: **App**
   - Clique em **Next**

4. **Configure o projeto:**
   - **Product Name:** `WishBox`
   - **Team:** Seu time (ou None)
   - **Organization Identifier:** `com.wishbox` (ou o que preferir)
   - **Interface:** **SwiftUI**
   - **Language:** **Swift**
   - **Storage:** **None** (usaremos UserDefaults)
   - **Include Tests:** ✅ (opcional)
   - Clique em **Next**

5. **Escolha o local:**
   - Navegue até: `/Users/Cassio/Documents/Xcode Projects/WishBox/ios/`
   - **NÃO** marque "Create Git repository" (já temos)
   - Clique em **Create**

### Passo 2: Adicionar Arquivos Swift

1. **Delete arquivos gerados:**
   - Delete `ContentView.swift` (gerado automaticamente)
   - Mantenha `WishBoxApp.swift` e substitua pelo nosso

2. **Adicionar nossos arquivos:**
   - No Xcode, clique com botão direito na pasta do projeto
   - **Add Files to "WishBox"...**
   - Navegue até: `ios/WishBox/WishBox/`
   - Selecione TODA a pasta `WishBox`
   - **IMPORTANTE:** Marque **"Create groups"** (NÃO "Create folder references")
   - ✅ Marque **"Copy items if needed"**
   - ✅ Marque o target **"WishBox"**
   - Clique em **Add**

### Passo 3: Configurar Entry Point

1. **Abra `WishBoxApp.swift`** (o gerado pelo Xcode)
2. **Substitua** o conteúdo por:
   ```swift
   import SwiftUI
   
   @main
   struct WishBoxApp: App {
       var body: some Scene {
           WindowGroup {
               SplashView()
           }
       }
   }
   ```
3. **Delete** o `WishBoxApp.swift` que está em `WishBox/App/` (se duplicado)

### Passo 4: Configurar Info.plist

1. **Selecione `Info.plist`** no projeto
2. **Adicione** (se não existir):
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```
3. **Para desenvolvimento local** (opcional):
   ```xml
   <key>BACKEND_URL</key>
   <string>http://localhost:3000</string>
   ```

### Passo 5: Configurar Build Settings

1. **Selecione o projeto** (topo do Navigator)
2. **Target:** WishBox
3. **Build Settings:**
   - **iOS Deployment Target:** `16.0` ou superior
   - **Swift Language Version:** `Swift 5`

### Passo 6: Compilar e Executar

1. **Selecione um simulador** (iPhone 15 Pro, etc.)
2. **Compile:** `Cmd + B`
3. **Execute:** `Cmd + R`

---

## 🎯 Opção 2: Usar Projeto Existente (OLD/WishBox.xcodeproj)

Se você já tem um projeto Xcode:

1. **Abra:** `OLD/WishBox.xcodeproj` (ou o projeto existente)
2. **Adicione os arquivos:**
   - Clique com botão direito → **Add Files to "WishBox"...**
   - Selecione `ios/WishBox/WishBox/`
   - Marque **"Create groups"**
   - Clique em **Add**

3. **Configure o Target:**
   - Selecione os arquivos Swift
   - Verifique que estão no Target **WishBox**

4. **Atualize Info.plist** conforme Opção 1, Passo 4

---

## ✅ Checklist de Verificação

- [ ] Projeto Xcode criado/aberto
- [ ] Todos os arquivos Swift adicionados ao projeto
- [ ] `WishBoxApp.swift` configurado como entry point
- [ ] `Info.plist` configurado (NSAppTransportSecurity)
- [ ] Build Settings: iOS 16.0+
- [ ] Projeto compila sem erros (Cmd+B)
- [ ] App executa no simulador (Cmd+R)

---

## 🐛 Problemas Comuns

### Erro: "Cannot find 'SplashView' in scope"
**Solução:** Certifique-se que todos os arquivos Swift estão no Target "WishBox"

### Erro: Network/CORS
**Solução:** Verifique que `NSAllowsArbitraryLoads` está no `Info.plist`

### Erro: URL do backend não funciona
**Solução:** 
- Em produção: Use `https://wish2box.netlify.app/api/search`
- Em desenvolvimento: Configure `BACKEND_URL` no `Info.plist`

---

## 📝 Estrutura Final no Xcode

```
WishBox (Project)
├── WishBox (Target)
│   ├── App
│   │   └── WishBoxApp.swift
│   ├── Core
│   │   ├── Constants
│   │   ├── Services
│   │   └── Types
│   └── Presentation
│       ├── Views
│       └── Components
└── WishBoxTests (Target)
```

---

## 🚀 Próximos Passos Após Compilar

1. **Teste a busca** de produtos
2. **Verifique favoritos**
3. **Teste área admin** (senha: `admin123`)
4. **Verifique links** de afiliado
