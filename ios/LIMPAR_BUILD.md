# 🧹 Limpar Build iOS Completamente

## ⚠️ Erro Atual

```
Thread 1: signal SIGABRT
dyld`__abort_with_payload
path_provider_foundation.framework (no such file)
```

## 🔍 Causa

O erro ocorre porque o app compilado ainda contém referências a frameworks Flutter antigos que não existem mais. O bundle do app foi compilado com frameworks Flutter e precisa ser limpo completamente.

## ✅ Solução

### 1. Limpar Builds no Terminal

```bash
cd ios
rm -rf build/
rm -rf ~/Library/Developer/Xcode/DerivedData/Runner-*
```

### 2. Limpar no Xcode

1. **Feche o Xcode completamente**
2. **Abra o Xcode novamente**
3. **Product → Clean Build Folder** (Shift+Cmd+K)
4. **Quit Xcode** novamente

### 3. Limpar Device/Simulator (Se necessário)

Se o app ainda estiver instalado no dispositivo/simulador:

**Simulator:**
```bash
# Listar simulators
xcrun simctl list devices

# Remover app do simulator
xcrun simctl uninstall booted com.example.presenteIdealIa
```

**Device Físico:**
- Remova o app manualmente do iPhone

### 4. Recompilar Limpamente

1. **Abra o Xcode**
2. **Selecione o Scheme:** Runner
3. **Selecione o Device:** iPhone Simulator ou seu iPhone
4. **Product → Clean Build Folder** (Shift+Cmd+K)
5. **Product → Build** (Cmd+B)
6. **Product → Run** (Cmd+R)

## ✅ Verificações Finais

- [ ] Build folder foi removido (`ios/build/`)
- [ ] DerivedData foi limpo (`~/Library/Developer/Xcode/DerivedData/`)
- [ ] Xcode foi fechado e reaberto
- [ ] Clean Build Folder foi executado (Shift+Cmd+K)
- [ ] App foi removido do device/simulator
- [ ] Compilação nova foi feita (Cmd+B)

## 🎯 Se Ainda Crashar

### Verificar Logs do Console

No Xcode, veja o console para ver a mensagem de erro exata:
- **View → Debug Area → Show Debug Area** (Shift+Cmd+Y)
- Veja a mensagem de erro completa

### Verificar Frameworks Linkados

No Xcode:
1. **Target "Runner" → Build Phases → Link Binary With Libraries**
2. **Verifique se NÃO há frameworks Flutter listados**
3. **Remova qualquer framework Flutter se existir**

### Verificar Embed Frameworks

No Xcode:
1. **Target "Runner" → Build Phases → Embed Frameworks**
2. **Verifique se está vazio ou remova a fase se não for necessária**

## 📝 Notas

- Um app SwiftUI puro **não precisa** de frameworks externos para funcionar
- O **Embed Frameworks** phase pode estar vazio, mas não deve causar problemas
- Se o erro persistir, pode ser necessário **limpar completamente o Xcode DerivedData**:
  ```bash
  rm -rf ~/Library/Developer/Xcode/DerivedData/*
  ```
