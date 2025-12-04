# Debug de Crash no iOS

Se o app está abrindo e fechando automaticamente, siga estes passos:

## 1. Verificar logs no Xcode

1. Abra o Xcode
2. Vá em **Window > Devices and Simulators**
3. Selecione seu iPhone
4. Clique em **View Device Logs**
5. Procure por erros recentes relacionados ao app

## 2. Verificar logs via Terminal

Execute no terminal:
```bash
cd "/Users/Cassio/Documents/Xcode Projects/WishBox"
flutter run --verbose
```

Isso mostrará os logs detalhados do app.

## 3. Verificar Console do macOS

1. Abra o **Console.app** no Mac
2. Conecte o iPhone
3. Filtre por "Runner" ou "PresenteIdeal"
4. Procure por erros quando o app crashar

## 4. Problemas Comuns

### Problema: Permissões
- Verifique se o app tem permissões necessárias no Info.plist

### Problema: Dependências
- Execute: `cd ios && pod install`

### Problema: Build limpo
- Execute: `flutter clean && flutter pub get && cd ios && pod install`

## 5. Testar em Simulador

Tente rodar no simulador primeiro:
```bash
flutter run
```
E escolha um simulador iOS.

## 6. Verificar se o problema é específico do dispositivo

- Tente em outro dispositivo ou simulador
- Verifique a versão do iOS (deve ser 13.0+)



