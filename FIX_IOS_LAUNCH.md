# Correção: App não abre após ser fechado no iOS

## Problema
O app abre quando compilado via Xcode, mas não abre quando clica no ícone após ser fechado.

## Causa
Geralmente é um problema de **Code Signing** (assinatura de código). O Xcode faz a assinatura automaticamente durante o build, mas pode faltar configuração para execução no dispositivo.

## Solução

### 1. Verificar Code Signing no Xcode

1. Abra `ios/Runner.xcworkspace` no Xcode
2. Selecione o projeto **Runner** no navegador
3. Selecione o target **Runner**
4. Vá para a aba **Signing & Capabilities**
5. **Marque** "Automatically manage signing"
6. Selecione seu **Team** (sua conta da Apple Developer)
7. Verifique se o **Bundle Identifier** está correto: `com.example.presenteIdealIa`

### 2. Verificar Provisioning Profile

Se "Automatically manage signing" não resolver:

1. Vá para **Apple Developer Portal** (https://developer.apple.com)
2. Certifique-se de que seu dispositivo está registrado
3. Crie um **Development Provisioning Profile** se necessário
4. No Xcode, selecione o perfil manualmente em **Signing & Capabilities**

### 3. Limpar e Rebuild

No terminal:
```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter clean
cd ios
pod install
cd ..
flutter pub get
```

### 4. Compilar e Instalar Novamente

No Xcode:
1. Certifique-se de que o dispositivo está conectado e selecionado
2. Pressione **⌘R** (Run) ou clique no botão Play
3. Aguarde a instalação completa

### 5. Verificar Logs de Crash

Se ainda não abrir:

1. No Xcode, vá para **Window > Devices and Simulators**
2. Selecione seu dispositivo
3. Clique em **View Device Logs**
4. Procure por crashes recentes do app **WishBox**

### 6. Verificar Console do Dispositivo

Para ver logs em tempo real:

1. Conecte o dispositivo via cabo USB
2. No terminal:
```bash
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "Runner"' --level debug
```

Ou para dispositivo físico:
```bash
idevicesyslog | grep -i wishbox
```

## Comandos Rápidos

```bash
# Limpar tudo e reconstruir
flutter clean
cd ios && pod install && cd ..
flutter pub get
flutter build ios --release
```

## Se ainda não funcionar

1. **Deletar o app do dispositivo** completamente
2. **Reinstalar** via Xcode
3. Verificar se há **erros de inicialização** nos logs
4. Verificar se o **AppDelegate** está sendo chamado (já adicionamos logs)

## Nota
O problema geralmente é resolvido configurando corretamente o **Code Signing** no Xcode. Certifique-se de que:
- ✅ "Automatically manage signing" está marcado
- ✅ Um Team válido está selecionado
- ✅ O Bundle Identifier está correto
- ✅ O dispositivo está registrado no Apple Developer
