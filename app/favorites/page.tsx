'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import { FavoritesService } from '@/lib/services/favorites';
import { StoreService } from '@/lib/services/store';
import { Product } from '@/lib/types/product';

export default function FavoritesPage() {
  const router = useRouter();
  const [favorites, setFavorites] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    loadFavorites();
  }, []);

  const loadFavorites = () => {
    setIsLoading(true);
    try {
      const favs = FavoritesService.getFavorites();
      setFavorites(favs);
    } catch (error) {
      console.error('Error loading favorites:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const handleRemoveFavorite = (productId: string) => {
    if (FavoritesService.removeFavorite(productId)) {
      loadFavorites(); // Recarregar lista
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
          <p className="text-lg text-text-secondary">Carregando favoritos...</p>
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
              onClick={() => router.push('/')}
              className="text-text-secondary hover:text-text-primary"
            >
              ← Voltar
            </button>
            <h1 className="text-xl font-semibold text-text-primary">Meus Favoritos</h1>
            <div className="w-12"></div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {favorites.length === 0 ? (
          <div className="text-center py-16">
            <div className="text-6xl mb-4">💝</div>
            <h2 className="text-2xl font-bold text-text-primary mb-2">
              Nenhum favorito ainda
            </h2>
            <p className="text-text-secondary mb-6">
              Adicione produtos aos seus favoritos para encontrá-los facilmente depois
            </p>
            <button
              onClick={() => router.push('/')}
              className="px-6 py-3 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark transition-colors"
            >
              Buscar Presentes
            </button>
          </div>
        ) : (
          <>
            <p className="text-sm text-text-secondary mb-6">
              {favorites.length} {favorites.length === 1 ? 'produto favorito' : 'produtos favoritos'}
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
              {favorites.map((product) => (
                <div
                  key={product.id}
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
                        className="flex-1 px-4 py-2 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark transition-colors text-sm"
                      >
                        Ver na loja
                      </button>
                      <button
                        onClick={() => handleRemoveFavorite(product.id)}
                        className="px-4 py-2 bg-error/20 text-error rounded-lg hover:bg-error/30 transition-colors"
                        title="Remover dos favoritos"
                      >
                        ❤️
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </>
        )}
      </main>
    </div>
  );
}
