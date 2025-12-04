# PresenteIdeal IA

Aplicativo Flutter para recomendação de presentes usando Inteligência Artificial e links de afiliados.

## 📱 Sobre o Projeto

O **PresenteIdeal IA** ajuda usuários a encontrar o presente ideal para outra pessoa ou para si mesmos, utilizando IA para analisar perfis e sugerir produtos de lojas parceiras através de programas de afiliados.

### Funcionalidades Principais

- ✅ Busca de presentes com IA
- ✅ Opção "Presente para mim" (self-gift)
- ✅ Histórico de buscas e sugestões
- ✅ Filtros e ordenação de resultados
- ✅ Feedback do usuário (gostei/não gostei)
- ✅ Salvamento de favoritos
- ✅ Modo mock para desenvolvimento sem backend

## 🏗️ Arquitetura

O projeto segue os princípios de **Clean Architecture** com separação clara de responsabilidades:

```
lib/
├── core/                    # Configurações e utilitários globais
│   ├── constants/           # Constantes da aplicação
│   ├── router/              # Configuração de rotas (GoRouter)
│   └── theme/               # Tema e estilos
│
├── domain/                  # Camada de domínio (regras de negócio)
│   └── entities/            # Entidades do domínio
│       ├── user.dart
│       ├── recipient_profile.dart
│       ├── product.dart
│       ├── gift_suggestion.dart
│       └── gift_search_session.dart
│
├── data/                    # Camada de dados
│   ├── mock/                # Serviços mock para desenvolvimento
│   │   └── mock_data_service.dart
│   ├── models/              # DTOs e modelos de dados (futuro)
│   ├── repositories/        # Implementação de repositórios (futuro)
│   └── datasources/         # Fontes de dados (API, local, etc.) (futuro)
│
└── presentation/            # Camada de apresentação
    ├── pages/               # Telas da aplicação
    │   ├── onboarding_page.dart
    │   ├── home_page.dart
    │   ├── recipient_form_page.dart
    │   ├── preferences_page.dart
    │   ├── loading_profile_page.dart
    │   ├── suggestions_page.dart
    │   ├── history_page.dart
    │   └── product_details_page.dart
    └── widgets/             # Widgets reutilizáveis
        ├── product_card.dart
        ├── tag_chip.dart
        ├── price_range_selector.dart
        └── loading_indicator.dart
```

## 🚀 Como Executar

### Pré-requisitos

- Flutter SDK 3.0.0 ou superior
- Dart SDK 3.0.0 ou superior
- Xcode 14.3.1+ (para iOS)
- Android Studio / VS Code com extensões Flutter

### Instalação

1. **Clone o repositório** (ou navegue até a pasta do projeto)

2. **Instale as dependências:**
   ```bash
   flutter pub get
   ```

3. **Execute o app:**
   ```bash
   flutter run
   ```

   Ou escolha um dispositivo específico:
   ```bash
   flutter devices                    # Lista dispositivos disponíveis
   flutter run -d <device-id>         # Executa no dispositivo escolhido
   ```

## 🌐 Versão Web

O WishBox também está disponível como aplicativo web! O código Flutter é **100% compartilhado** entre mobile e web.

### Executar Web Localmente

```bash
# Modo desenvolvimento
flutter run -d chrome

# Build para produção
flutter build web --release
```

### Deploy no GitHub Pages

O projeto está configurado para deploy automático via GitHub Actions:

1. **Deploy Automático:**
   - Faça push para a branch `main` ou `master`
   - O GitHub Actions automaticamente builda e faz deploy
   - Configure GitHub Pages em: Settings > Pages > Deploy from branch `gh-pages`

2. **Deploy Manual:**
   ```bash
   ./build_web.sh
   # Ou
   flutter build web --release --base-href /WishBox/
   ```

3. **Acessar:**
   - O `index.html` na raiz redireciona automaticamente para a versão web
   - Acesse: `https://seu-usuario.github.io/WishBox/`

### Estrutura Web

```
WishBox/
├── lib/                    # Código Flutter compartilhado (mobile + web)
├── web/                     # Arquivos web específicos
│   ├── index.html          # HTML principal
│   ├── manifest.json       # PWA manifest
│   └── icons/              # Ícones do app
├── index.html              # Redirecionamento para GitHub Pages
└── build/web/              # Arquivos compilados (gerado)
```

**Nota:** Todo o código em `lib/` funciona tanto em mobile quanto em web sem modificações!

Para mais detalhes, veja [BUILD_WEB.md](./BUILD_WEB.md).

### Modo Mock

O aplicativo está configurado para rodar em **modo mock** por padrão, ou seja, utiliza dados fictícios sem necessidade de backend ou APIs reais.

Os dados mockados estão em:
- `lib/data/mock/mock_data_service.dart`

Este serviço fornece:
- Lista de produtos fictícios
- Sugestões de presentes simuladas
- Histórico de buscas de exemplo

## 📱 Fluxo do Usuário

### 1. Onboarding
Tela inicial apresentando o app com opções para:
- Começar uma nova busca
- Ver histórico de buscas
- Ver ideias salvas

### 2. Formulário do Presenteado
- Escolha: "Presente para mim" ou "Presente para outra pessoa"
- Se for para outra pessoa:
  - Tipo de relação
  - Faixa de idade
  - Gênero (opcional)
  - Ocasião
- Descrição livre da pessoa

### 3. Preferências
- Faixa de preço (mínimo e máximo)
- Tipos de presente desejados (múltipla escolha)
- O que evitar (campo opcional)
- Lojas preferidas (opcional)

### 4. Geração do Perfil (IA)
Tela de loading mostrando o processo de análise:
- Analisando o perfil
- Identificando interesses
- Buscando produtos
- Calculando compatibilidade

### 5. Sugestões de Presentes
Lista de produtos sugeridos com:
- Imagem do produto
- Nome e preço
- Tags (Romântico, Tecnológico, etc.)
- Explicação do porquê combina
- Botões de ação (Gostei, Não, Salvar)
- Link para a loja

### 6. Filtros e Ordenação
- Ordenar por relevância, preço (menor/maior)
- Filtrar por tipo de presente

### 7. Histórico
Visualização de buscas anteriores com:
- Para quem foi o presente
- Ocasião
- Faixa de preço
- Data da busca

## 🔌 Integração com Backend (Futuro)

### Endpoints da API

A arquitetura está preparada para integração com backend REST. Os endpoints planejados são:

#### 1. Criar perfil e obter sugestões
```
POST /api/v1/gifts/profile-and-suggestions
Body: {
  "isSelfGift": boolean,
  "relationType": string | null,
  "ageRange": string | null,
  "gender": string | null,
  "occasion": string | null,
  "descriptionRaw": string,
  "priceMin": number,
  "priceMax": number,
  "giftTypes": string[],
  "preferredStores": string[],
  "constraints": string[]
}
Response: {
  "recipientProfile": RecipientProfile,
  "suggestions": GiftSuggestion[]
}
```

#### 2. Obter histórico
```
GET /api/v1/users/{userId}/history
Response: {
  "sessions": GiftSearchSession[]
}
```

#### 3. Registrar clique
```
POST /api/v1/gifts/{sessionId}/product/{productId}/click
```

#### 4. Registrar compra
```
POST /api/v1/purchases
Body: {
  "userId": string,
  "productId": string,
  "purchaseValue": number,
  "purchaseDate": string,
  "notes": string
}
```

### Onde Integrar

1. **Serviços de API:**
   - Criar em `lib/data/datasources/`:
     - `api_client.dart` (usando Dio)
     - `gift_api_datasource.dart`
     - `user_api_datasource.dart`

2. **Repositórios:**
   - Criar em `lib/data/repositories/`:
     - `gift_repository_impl.dart`
     - `user_repository_impl.dart`

3. **Providers/Controllers:**
   - Atualizar providers em `lib/presentation/` para usar repositórios reais ao invés de mocks

4. **Modo Mock vs Real:**
   - Criar flag de ambiente (ex: `USE_MOCK_DATA`)
   - Alternar entre `MockDataService` e repositórios reais

## 🛒 Integração com Afiliados (Futuro)

### Arquitetura de Afiliados

O projeto está preparado para integração com múltiplos programas de afiliados através de uma interface genérica:

```dart
abstract class AffiliateProvider {
  Future<List<AffiliateProduct>> searchProducts(SearchQuery query);
  String generateAffiliateUrl(String productUrl, String userId);
}
```

### Implementações Planejadas

- `AmazonProvider` - Amazon Associates
- `MercadoLivreProvider` - Mercado Livre Affiliates
- `ShopeeProvider` - Shopee Affiliate Program
- `AliExpressProvider` - AliExpress Affiliate

### Onde Implementar

- Criar em `lib/data/datasources/affiliates/`:
  - `affiliate_provider.dart` (interface)
  - `amazon_provider.dart`
  - `mercado_livre_provider.dart`
  - `shopee_provider.dart`
  - `aliexpress_provider.dart`

## 🎨 Design System

### Cores Principais

- **Primary:** `#6366F1` (Indigo)
- **Secondary:** `#8B5CF6` (Purple)
- **Accent:** `#EC4899` (Pink)
- **Background:** `#F9FAFB` (Light Gray)
- **Surface:** `#FFFFFF` (White)

### Componentes Reutilizáveis

- `ProductCard` - Card de produto com imagem, preço, tags e ações
- `TagChip` - Chip selecionável para tags e filtros
- `PriceRangeSelector` - Seletor de faixa de preço
- `LoadingIndicator` - Indicador de carregamento com mensagem

## 📊 Banco de Dados (Backend)

### Modelo de Dados

O backend deve implementar as seguintes tabelas/entidades:

1. **users** - Usuários do app
2. **recipient_profiles** - Perfis de presenteados
3. **gift_search_sessions** - Sessões de busca
4. **products** - Cache de produtos
5. **gift_suggestions** - Sugestões geradas
6. **click_events** - Eventos de clique
7. **purchases** - Histórico de compras
8. **marketing_events** - Eventos de marketing (futuro)

Ver documentação completa do modelo em: `docs/database_schema.md` (a ser criado)

## 🤖 Lógica de IA

### Processo de Recomendação

1. **Interpretação do Perfil:**
   - Entrada: descrição + relação + ocasião + idade
   - Saída: interesses, traços de personalidade, estilo de presente

2. **Geração de Intenções:**
   - Converter perfil em intenções de presente
   - Ex: "kit café + caneca personalizada"

3. **Busca de Produtos:**
   - Consultar lojas parceiras via APIs de afiliados
   - Unificar resultados

4. **Ranking e Score:**
   - Calcular relevância baseado em:
     - Match de interesses (40%)
     - Compatibilidade de estilo (20%)
     - Aderência ao preço (20%)
     - Qualidade/rating (20%)

5. **Explicação:**
   - Gerar texto explicando por que o presente combina

6. **Aprendizado:**
   - Usar feedback (👍/👎) para melhorar sugestões futuras

## 🧪 Testes

Para executar testes:

```bash
flutter test
```

## 📝 Próximos Passos

- [ ] Implementar autenticação de usuários
- [ ] Integrar com backend real
- [ ] Integrar APIs de afiliados
- [ ] Implementar notificações push
- [ ] Adicionar testes unitários e de integração
- [ ] Implementar cache local (Hive/SharedPreferences)
- [ ] Adicionar analytics
- [ ] Melhorar tratamento de erros
- [ ] Internacionalização (i18n)

## 📄 Licença

Este projeto é privado e proprietário.

## 👥 Contribuindo

Este é um projeto em desenvolvimento. Para sugestões ou problemas, entre em contato com a equipe de desenvolvimento.

---

**Desenvolvido com Flutter 💙**



