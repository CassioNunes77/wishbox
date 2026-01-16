# 🔧 Correção: Crash na Inicialização do iOS

## Problema
O app está crashando na inicialização no iOS.

## Correções Aplicadas

### 1. **Melhorias no AppDelegate.swift**
- ✅ Tratamento de exceções melhorado
- ✅ Logs de crash salvos em arquivo para debug
- ✅ Tratamento de erro ao registrar plugins
- ✅ Garantia de que a window está configurada antes de plugins

### 2. **Melhorias no AppPreferencesService**
- ✅ Timeout reduzido para evitar travamentos
- ✅ Tratamento de erro melhorado para não bloquear o app
- ✅ Logs detalhados para debug

### 3. **Melhorias no SplashPage**
- ✅ Timeout na navegação
- ✅ Tratamento de erro melhorado
- ✅ Retry automático se router não estiver disponível

## Como Verificar o Crash

### 1. Ver Logs no Xcode
1. Conecte o iPhone via cabo USB
2. No Xcode, vá em **Window > Devices and Simulators**
3. Selecione seu iPhone
4. Clique em **"Open Console"** ou **"View Device Logs"**
5. Procure por:
   - `=== AppDelegate: didFinishLaunchingWithOptions ===`
   - `=== Uncaught Exception ===`
   - `=== Flutter Error ===`

### 2. Ver Logs de Crash Salvos
Se o app crashar, os logs serão salvos em:
- **iPhone**: `/Documents/crash_log.txt`
- Para ver via Xcode: **Window > Devices > [Seu iPhone] > Installed Apps > WishBox > Download Container**

### 3. Ver Console do Flutter
No terminal:
```bash
# Conecte o iPhone e execute:
flutter run --verbose
```

### 4. Ver Console do Dispositivo
```bash
# Para simulador:
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "Runner"' --level debug

# Para dispositivo físico:
idevicesyslog | grep -i wishbox
```

## Principais Causas de Crash na Inicialização

### 1. **SharedPreferences não inicializado**
**Sintoma**: Crash ao tentar ler/escrever preferências
**Solução**: Já corrigido com timeouts e tratamento de erro

### 2. **Plugin não registrado**
**Sintoma**: Crash ao tentar usar um plugin
**Solução**: Já corrigido com tratamento de erro no AppDelegate

### 3. **Router não disponível**
**Sintoma**: Crash ao tentar navegar
**Solução**: Já corrigido com retry e verificação de disponibilidade

### 4. **Problema de permissões**
**Sintoma**: Crash ao tentar acessar recursos do sistema
**Solução**: Verificar `Info.plist` - já adicionadas permissões de rede

### 5. **Problema de código de assinatura**
**Sintoma**: App não abre ou crasha imediatamente
**Solução**: Verificar **Signing & Capabilities** no Xcode

## Passos para Debug

### 1. Limpar e Recompilar
```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter clean
cd ios
pod install
cd ..
flutter pub get
```

### 2. No Xcode
1. **Product > Clean Build Folder** (⇧⌘K)
2. Conecte o iPhone
3. Execute o app (⌘R)
4. **Mantenha o console aberto** para ver os logs

### 3. Verificar Logs
Procure por estas mensagens no console:
- `=== App Starting ===` - App começou
- `=== App Started Successfully ===` - App iniciou com sucesso
- `=== AppDelegate: didFinishLaunchingWithOptions ===` - iOS iniciou
- `=== Flutter Error ===` - Erro no Flutter
- `=== Uncaught Exception ===` - Exception não capturada

## Se o Crash Persistir

### 1. Verificar Stack Trace
Nos logs, procure pela stack trace completa que mostra exatamente onde o crash ocorreu.

### 2. Desabilitar Temporariamente Funcionalidades
Comente temporariamente código que pode estar causando o crash:
- Chamadas a `SharedPreferences` na inicialização
- Navegação automática
- Carregamento de dados assíncronos

### 3. Testar em Modo Debug
```bash
flutter run --debug
```

### 4. Testar em Modo Release
```bash
flutter run --release
```

### 5. Verificar Dependências
```bash
flutter pub outdated
flutter pub upgrade
```

## Checklist de Verificação

- [ ] AppDelegate está configurado corretamente
- [ ] Info.plist tem todas as permissões necessárias
- [ ] SharedPreferences tem timeouts
- [ ] Router tem tratamento de erro
- [ ] Logs estão sendo salvos
- [ ] Code signing está configurado
- [ ] Plugins estão registrados corretamente
- [ ] Não há operações síncronas bloqueantes na inicialização

## Logs Importantes

O app agora registra logs detalhados em:
1. **Console do Xcode** - Todos os logs
2. **Console do Flutter** - Logs do Dart
3. **crash_log.txt** - Logs de crash salvos no dispositivo

Procure por essas mensagens para identificar onde o crash está acontecendo:
- `=== App Starting ===`
- `=== AppDelegate: didFinishLaunchingWithOptions ===`
- `=== Plugins registered successfully ===`
- `=== Flutter Error ===`
- `=== Uncaught Exception ===`

## Próximos Passos

1. Execute o app no iPhone
2. Verifique o console do Xcode
3. Procure pela última mensagem de log antes do crash
4. Isso indicará exatamente onde o problema está ocorrendo
