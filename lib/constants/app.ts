export const APP_CONSTANTS = {
  // Relation Types
  relationTypes: [
    'Namorado(a)',
    'Marido/Esposa',
    'Amigo(a)',
    'Filho(a)',
    'Mãe/Pai',
    'Chefe',
    'Colega de Trabalho',
    'Outro',
  ],

  // Age Ranges
  ageRanges: [
    '0-5 anos',
    '6-12 anos',
    '13-17 anos',
    '18-25 anos',
    '26-40 anos',
    '40+ anos',
  ],

  // Genders
  genders: [
    'Masculino',
    'Feminino',
    'Outro',
    'Prefiro não informar',
  ],

  // Occasions
  occasions: [
    'Aniversário',
    'Formatura',
    'Casamento',
    'Dia das Mães',
    'Dia dos Pais',
    'Natal',
    'Amigo Secreto',
    'Dia dos Namorados',
    'Outro',
  ],

  // Gift Types
  giftTypes: [
    'Útil no dia a dia',
    'Romântico',
    'Divertido',
    'Tecnológico',
    'Experiência',
  ],

  // Currency
  defaultCurrency: 'BRL',
  currencySymbol: 'R$',

  // Backend API
  // Em produção, NEXT_PUBLIC_BACKEND_URL deve estar configurada no Netlify
  backendBaseUrl: typeof window !== 'undefined' 
    ? (process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:3000')
    : (process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:3000'),
} as const;
