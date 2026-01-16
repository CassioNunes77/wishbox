# 🔧 Correção: App não abre no iPhone após ser fechado

## Problema
O app abre quando compilado pelo Xcode, mas não abre quando você clica no ícone após fechar.

## Causas Mais Comuns

### 1. **App não é confiável (Trust Developer) - MAIS COMUM**
O iPhone bloqueia apps de desenvolvedores não verificados por segurança.

#### Solução:
1. No iPhone, vá em **Configurações > Geral > VPN e Gerenciamento de Dispositivo** (ou **Configurações > Geral > Gerenciamento de Dispositivo e Perfis**)
2. Procure pela seção **"APPS DO DESENVOLVEDOR"** ou **"APPS NÃO VERIFICADOS"**
3. Clique no nome do desenvolvedor (sua conta Apple)
4. Toque em **"Confiar em [Nome do Desenvolvedor]"**
5. Confirme na janela popup
6. Tente abrir o app novamente

### 2. **Problema de Code Signing**
O app não está assinado corretamente para execução no dispositivo.

#### Solução no Xcode:
1. Abra `ios/Runner.xcworkspace` no Xcode
2. Selecione o projeto **Runner** no navegador
3. Selecione o target **Runner**
4. Vá na aba **Signing & Capabilities**
5. **Marque** "Automatically manage signing"
6. Selecione seu **Team** (sua conta da Apple Developer)
7. Certifique-se de que o **Bundle Identifier** está correto: `com.example.presenteIdealIa`
8. Se aparecer algum erro de provisioning, clique em **"Try Again"** ou **"Download Manual Profiles"**

### 3. **Provisão de Perfil Expirado ou Inválido**
O perfil de provisionamento pode ter expirado.

#### Solução:
1. No Xcode, vá em **Xcode > Preferences > Accounts**
2. Selecione sua conta Apple
3. Clique em **"Download Manual Profiles"**
4. Volte para **Signing & Capabilities**
5. Selecione o perfil manualmente ou marque novamente "Automatically manage signing"

### 4. **Dispositivo não está registrado no Apple Developer**
O dispositivo precisa estar registrado no seu perfil de desenvolvedor.

#### Solução:
1. Conecte o iPhone ao Mac via cabo USB
2. No Xcode, vá em **Window > Devices and Simulators**
3. Selecione seu iPhone na lista
4. Se aparecer um botão **"Use for Development"**, clique nele
5. Aguarde o registro

### 5. **Bundle Identifier não está registrado**
O Bundle Identifier pode não estar disponível ou não estar registrado na sua conta.

#### Solução:
1. No Xcode, em **Signing & Capabilities**, verifique se há um erro relacionado ao Bundle Identifier
2. Se houver, mude o Bundle Identifier para algo único, como: `com.seunome.wishbox` (substitua "seunome" pelo seu nome/empresa)
3. Certifique-se de que é único e não está sendo usado por outro app

## Passo a Passo Completo

### 1. Verificar se o app é confiável (PRIMEIRO PASSO)
```
Configurações > Geral > VPN e Gerenciamento de Dispositivo > [Seu Desenvolvedor] > Confiar
```

### 2. Reinstalar o app corretamente
No Xcode:
1. **Deletar o app do iPhone** (mantenha pressionado o ícone > Remover App)
2. **Limpar o build**: Product > Clean Build Folder (⇧⌘K)
3. **Conectar o iPhone** via cabo USB
4. **Selecionar o iPhone** como destino no Xcode
5. **Executar** o app (⌘R)
6. **Aguardar a instalação completa** (não desconecte até aparecer "Build Succeeded")

### 3. Verificar logs de crash
Se ainda não abrir:
1. No Xcode, vá em **Window > Devices and Simulators**
2. Selecione seu iPhone
3. Clique em **"Open Console"** ou **"View Device Logs"**
4. Procure por crashes recentes do app **WishBox**
5. Verifique os erros mostrados

### 4. Verificar código de assinatura
No terminal:
```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter clean
cd ios
pod install
cd ..
flutter pub get
```

Depois, no Xcode:
- Limpar build (⇧⌘K)
- Recompilar e instalar (⌘R)

## Comandos Úteis

### Verificar certificados instalados
```bash
security find-identity -v -p codesigning
```

### Verificar perfis de provisionamento
```bash
ls ~/Library/MobileDevice/Provisioning\ Profiles/
```

### Limpar tudo e reconstruir
```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter clean
rm -rf ios/Pods ios/Podfile.lock
cd ios && pod install && cd ..
flutter pub get
flutter build ios --release --no-codesign
```

## Debug em Tempo Real

### Ver logs do dispositivo
Com o iPhone conectado:
```bash
# Via Xcode Console (Window > Devices > View Device Logs)
# Ou via terminal:
idevicesyslog | grep -i wishbox
```

### Ver logs do simulador
```bash
xcrun simctl spawn booted log stream --predicate 'processImagePath contains "Runner"' --level debug
```

## Checklist de Verificação

- [ ] App está marcado como "Confiar" no iPhone
- [ ] Code Signing configurado corretamente no Xcode
- [ ] Team selecionado e válido
- [ ] Bundle Identifier é único e válido
- [ ] Dispositivo está registrado no Apple Developer
- [ ] Provisioning Profile está válido (não expirado)
- [ ] App foi instalado via Xcode (não manualmente)
- [ ] iPhone está conectado via cabo USB durante instalação
- [ ] Não há erros no console do Xcode
- [ ] Info.plist tem todas as permissões necessárias

## Se Nada Funcionar

1. **Criar um novo Bundle Identifier:**
   - No Xcode, mude para: `com.seunome.wishbox` (substitua "seunome")
   - Limpe e recompile

2. **Usar um dispositivo diferente:**
   - Teste em outro iPhone/iPad para isolar o problema

3. **Verificar conta Apple Developer:**
   - Certifique-se de que sua conta está ativa
   - Verifique se não está em modo de restrição

4. **Reinstalar Xcode:**
   - Em casos extremos, reinstale o Xcode

## Notas Importantes

- ⚠️ **Sempre confie no desenvolvedor** no iPhone antes de tentar abrir o app
- ⚠️ **Mantenha o cabo USB conectado** durante a primeira instalação
- ⚠️ **Não instale via TestFlight ou distribuição** se for desenvolvimento - use Xcode diretamente
- ⚠️ **Provisioning Profiles expiram** após 1 ano - renove se necessário

## Logs Adicionados

O AppDelegate agora tem logs detalhados que aparecerão no console do Xcode quando você executar o app. Procure por:
- `=== AppDelegate: didFinishLaunchingWithOptions ===`
- `=== AppDelegate: applicationDidBecomeActive ===`
- `=== AppDelegate: applicationWillEnterForeground ===`

Se esses logs não aparecerem, o app não está chegando ao AppDelegate, indicando um problema mais profundo de inicialização.
