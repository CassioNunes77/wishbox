'use client';

import { useEffect, useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { ApiService } from '@/lib/services/api';
import { StoreService } from '@/lib/services/store';
import { FavoritesService } from '@/lib/services/favorites';
import { GiftSuggestion, Product } from '@/lib/types/product';
import { APP_CONSTANTS } from '@/lib/constants/app';

function SuggestionsContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [suggestions, setSuggestions] = useState<GiftSuggestion[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [favoriteIds, setFavoriteIds] = useState<Set<string>>(new Set());
  const query = searchParams.get('query') || '';

  useEffect(() => {
    loadSuggestions();
    // Carregar IDs dos favoritos
    const favorites = FavoritesService.getFavorites();
    setFavoriteIds(new Set(favorites.map(p => p.id)));
  }, [query]);

  const loadSuggestions = async () => {
    setIsLoading(true);
    setError(null);

    try {
      // Buscar lojas ativas da área admin
      const activeStores = StoreService.getActiveStores();
      
      // Pegar a primeira loja ativa (Magazine Luiza geralmente)
      const affiliateUrl = activeStores.length > 0 ? activeStores[0].affiliateUrlTemplate : undefined;
      
      console.log('=== SuggestionsPage: Active stores:', activeStores.map(s => s.displayName));
      console.log('=== SuggestionsPage: Using affiliateUrl:', affiliateUrl);
      console.log('=== SuggestionsPage: Query:', query);

      // Se não há query, não buscar
      if (!query || query.trim() === '') {
        setError('Digite algo para buscar');
        setIsLoading(false);
        return;
      }

      // Buscar produtos reais do backend usando a loja ativa
      const products = await ApiService.searchProducts({
        query: query.trim(),
        limit: 30,
        affiliateUrl: affiliateUrl,
      });

      console.log('=== SuggestionsPage: Products received:', products.length);

      if (products.length === 0) {
        setError(`Nenhum produto encontrado para "${query}". Tente outra busca.`);
        setIsLoading(false);
        return;
      }

      // Converter produtos em sugestões
      const newSuggestions: GiftSuggestion[] = products.map((product, index) => ({
        id: `suggestion_${product.id}`,
        giftSearchSessionId: `session_${Date.now()}`,
        product,
        relevanceScore: 0.9 - index * 0.01,
        reasonText: `Produto relacionado a "${query}"`,
        position: index + 1,
      }));

      setSuggestions(newSuggestions);
    } catch (err: any) {
      console.error('Error loading suggestions:', err);
      console.error('Error details:', {
        message: err.message,
        response: err.response?.data,
        status: err.response?.status,
        url: err.config?.url,
      });
      
      // Mensagem de erro mais específica
      if (err.code === 'ECONNREFUSED' || err.message?.includes('Network Error')) {
        setError('Não foi possível conectar ao backend. Verifique se o backend está rodando e se a URL está correta.');
      } else if (err.response?.status === 404) {
        setError('Endpoint do backend não encontrado. Verifique a configuração.');
      } else if (err.response?.status >= 500) {
        setError('Erro no servidor backend. Tente novamente mais tarde.');
      } else {
        setError(`Erro ao carregar sugestões: ${err.message || 'Erro desconhecido'}`);
      }
    } finally {
      setIsLoading(false);
    }
  };

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    }).format(price);
  };

  const handleOpenProduct = (product: Product) => {
    const store = StoreService.getStoreByName(product.affiliateSource);
    if (store && product.productUrlBase) {
      const affiliateUrl = StoreService.generateAffiliateUrl(store, product.productUrlBase);
      window.open(affiliateUrl, '_blank');
    } else if (product.affiliateUrl) {
      window.open(product.affiliateUrl, '_blank');
    } else if (product.productUrlBase) {
      window.open(product.productUrlBase, '_blank');
    }
  };

  const handleToggleFavorite = (product: Product) => {
    if (favoriteIds.has(product.id)) {
      FavoritesService.removeFavorite(product.id);
      setFavoriteIds(prev => {
        const next = new Set(prev);
        next.delete(product.id);
        return next;
      });
    } else {
      FavoritesService.addFavorite(product);
      setFavoriteIds(prev => new Set(prev).add(product.id));
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-primary mb-4"></div>
          <p className="text-lg text-text-secondary">Carregando sugestões...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center max-w-md mx-auto px-4">
          <div className="text-6xl mb-4">😕</div>
          <h2 className="text-2xl font-bold text-text-primary mb-2">Ops!</h2>
          <p className="text-text-secondary mb-6">{error}</p>
          <button
            onClick={() => router.push('/')}
            className="px-6 py-3 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark transition-colors"
          >
            Voltar para busca
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background">
      {/* Header */}
      <header className="bg-white border-b border-border sticky top-0 z-10">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <button
              onClick={() => router.back()}
              className="text-text-secondary hover:text-text-primary"
            >
              ← Voltar
            </button>
            <h1 className="text-xl font-semibold text-text-primary">
              {query ? `Resultados para "${query}"` : 'Sugestões de presentes'}
            </h1>
            <div className="w-12"></div>
          </div>
        </div>
      </header>

      {/* Results */}
      <main className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {/* Debug info em desenvolvimento */}
        {process.env.NODE_ENV === 'development' && (
          <div className="mb-4 p-4 bg-yellow-50 border border-yellow-200 rounded-lg text-sm">
            <strong>Debug:</strong> Backend: {process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:3000'}
            <br />
            Lojas ativas: {StoreService.getActiveStores().length}
          </div>
        )}
        
        <p className="text-sm text-text-secondary mb-6">
          {suggestions.length} {suggestions.length === 1 ? 'produto encontrado' : 'produtos encontrados'}
        </p>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {suggestions.map((suggestion) => {
            const product = suggestion.product;
            return (
              <div
                key={suggestion.id}
                className="bg-surface rounded-lg shadow-card overflow-hidden hover:shadow-elevated transition-shadow"
              >
                <Link href={`/product/${product.id}`}>
                  <div className="relative w-full h-48 bg-background">
                    {product.imageUrl ? (
                      <Image
                        src={product.imageUrl}
                        alt={product.name}
                        fill
                        className="object-cover"
                        sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 25vw"
                        unoptimized
                      />
                    ) : (
                      <div className="w-full h-full flex items-center justify-center text-text-light">
                        Sem imagem
                      </div>
                    )}
                  </div>
                </Link>

                <div className="p-4">
                  <Link href={`/product/${product.id}`}>
                    <h3 className="font-semibold text-text-primary mb-2 line-clamp-2 hover:text-primary transition-colors">
                      {product.name}
                    </h3>
                  </Link>

                  <div className="flex items-center justify-between mb-3">
                    <span className="text-xl font-bold text-primary">
                      {formatPrice(product.price)}
                    </span>
                    {product.rating && (
                      <div className="flex items-center gap-1 text-sm text-text-secondary">
                        <span>⭐</span>
                        <span>{product.rating.toFixed(1)}</span>
                      </div>
                    )}
                  </div>

                  <div className="flex gap-2">
                    <button
                      onClick={() => handleOpenProduct(product)}
                      className="flex-1 px-4 py-2 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark transition-colors"
                    >
                      Ver na loja
                    </button>
                    <button
                      onClick={() => handleToggleFavorite(product)}
                      className={`px-4 py-2 rounded-lg font-semibold transition-colors ${
                        favoriteIds.has(product.id)
                          ? 'bg-error/20 text-error hover:bg-error/30'
                          : 'bg-background text-text-secondary border border-border hover:bg-surface'
                      }`}
                      title={favoriteIds.has(product.id) ? 'Remover dos favoritos' : 'Adicionar aos favoritos'}
                    >
                      {favoriteIds.has(product.id) ? '❤️' : '🤍'}
                    </button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </main>
    </div>
  );
}

export default function SuggestionsPage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-primary mb-4"></div>
          <p className="text-lg text-text-secondary">Carregando...</p>
        </div>
      </div>
    }>
      <SuggestionsContent />
    </Suspense>
  );
}
