'use client';

import { useEffect, useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { ApiService } from '@/lib/services/api';
import { StoreService } from '@/lib/services/store';
import { GiftSuggestion, Product } from '@/lib/types/product';
import { APP_CONSTANTS } from '@/lib/constants/app';

function SuggestionsContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [suggestions, setSuggestions] = useState<GiftSuggestion[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const query = searchParams.get('query') || '';

  useEffect(() => {
    loadSuggestions();
  }, [query]);

  const loadSuggestions = async () => {
    setIsLoading(true);
    setError(null);

    try {
      // Buscar produtos reais do backend
      const products = await ApiService.searchProducts({
        query: query || 'presentes',
        limit: 30,
      });

      if (products.length === 0) {
        setError('Nenhum produto encontrado. Tente outra busca.');
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
      setError('Erro ao carregar sugestões. Verifique se o backend está rodando.');
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

                  <button
                    onClick={() => handleOpenProduct(product)}
                    className="w-full px-4 py-2 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark transition-colors"
                  >
                    Ver na loja
                  </button>
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
