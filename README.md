# WishBox - Presentes Ideais com IA

WishBox é uma aplicação web para encontrar o presente ideal usando Inteligência Artificial e links de afiliados.

## 🚀 Tecnologias

- **Next.js 14** - Framework React com App Router
- **TypeScript** - Tipagem estática
- **Tailwind CSS** - Estilização
- **PWA** - Progressive Web App (funciona offline)
- **Node.js/Express** - Backend para scraping

## 📁 Estrutura do Projeto

```
wishbox/
├── app/                    # Páginas Next.js (App Router)
│   ├── page.tsx            # Home
│   ├── loading-profile/    # Tela de carregamento
│   ├── suggestions/        # Lista de sugestões
│   └── product/[id]/       # Detalhes do produto
├── lib/                    # Código compartilhado
│   ├── services/          # Serviços (API, Storage, Store)
│   ├── types/             # Tipos TypeScript
│   ├── constants/         # Constantes
│   └── components/        # Componentes React
├── public/                # Arquivos estáticos
├── backend/               # Backend Node.js (scraping)
└── OLD/                   # Código Flutter antigo (referência)
```

## 🛠️ Instalação

### Pré-requisitos

- Node.js 18+ 
- npm ou yarn

### Passos

1. **Instalar dependências:**
```bash
npm install
```

2. **Iniciar backend (em outro terminal):**
```bash
cd backend
npm install
npm start
```

3. **Iniciar aplicação Next.js:**
```bash
npm run dev
```

4. **Acessar:**
- Frontend: http://localhost:3000
- Backend: http://localhost:3000 (porta configurável via env)

## 🌐 Variáveis de Ambiente

Crie um arquivo `.env.local`:

```env
NEXT_PUBLIC_BACKEND_URL=http://localhost:3000
```

## 📦 Build para Produção

```bash
npm run build
npm start
```

## 🚢 Deploy no Netlify

1. Conecte o repositório GitHub ao Netlify
2. Configure:
   - **Build command:** `npm run build`
   - **Publish directory:** `.next`
3. Adicione variável de ambiente:
   - `NEXT_PUBLIC_BACKEND_URL` = URL do seu backend deployado

O Netlify detectará automaticamente o `netlify.toml`.

## 📱 PWA

A aplicação funciona como PWA:
- Instalável no celular
- Funciona offline (com cache)
- Interface nativa

## 🔧 Desenvolvimento

### Estrutura de Páginas

- `/` - Home (busca)
- `/loading-profile` - Carregamento
- `/suggestions` - Lista de produtos
- `/product/[id]` - Detalhes do produto

### Serviços

- `ApiService` - Comunicação com backend
- `StoreService` - Gerenciamento de lojas afiliadas
- `StorageService` - Armazenamento local (localStorage)

## 📝 Notas

- O código Flutter antigo está em `OLD/` para referência
- Backend Node.js está em `backend/`
- PWA configurado com `next-pwa`

## 🐛 Troubleshooting

### Backend não conecta
- Verifique se o backend está rodando
- Confirme a variável `NEXT_PUBLIC_BACKEND_URL`

### Build falha
- Limpe cache: `rm -rf .next node_modules`
- Reinstale: `npm install`

## 📄 Licença

ISC
