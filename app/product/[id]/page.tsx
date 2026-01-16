'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Image from 'next/image';
import { ApiService } from '@/lib/services/api';
import { StoreService } from '@/lib/services/store';
import { Product } from '@/lib/types/product';

export default function ProductDetailsPage() {
  const params = useParams();
  const router = useRouter();
  const productId = params.id as string;
  const [product, setProduct] = useState<Product | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [affiliateUrl, setAffiliateUrl] = useState<string | null>(null);

  useEffect(() => {
    loadProduct();
  }, [productId]);

  const loadProduct = async () => {
    setIsLoading(true);
    setError(null);

    try {
      // Buscar produtos e encontrar o produto específico
      const products = await ApiService.searchProducts({
        query: 'presentes',
        limit: 100,
      });

      const foundProduct = products.find((p) => p.id === productId);

      if (!foundProduct) {
        setError('Produto não encontrado');
        setIsLoading(false);
        return;
      }

      setProduct(foundProduct);

      // Gerar URL de afiliado
      const store = StoreService.getStoreByName(foundProduct.affiliateSource);
      if (store && foundProduct.productUrlBase) {
        const url = StoreService.generateAffiliateUrl(store, foundProduct.productUrlBase);
        setAffiliateUrl(url);
      } else {
        setAffiliateUrl(foundProduct.affiliateUrl || foundProduct.productUrlBase || null);
      }
    } catch (err: any) {
      console.error('Error loading product:', err);
      setError('Erro ao carregar produto');
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

  const handleOpenInStore = () => {
    if (affiliateUrl) {
      window.open(affiliateUrl, '_blank');
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-primary mb-4"></div>
          <p className="text-lg text-text-secondary">Carregando produto...</p>
        </div>
      </div>
    );
  }

  if (error || !product) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center max-w-md mx-auto px-4">
          <div className="text-6xl mb-4">😕</div>
          <h2 className="text-2xl font-bold text-text-primary mb-2">Produto não encontrado</h2>
          <p className="text-text-secondary mb-6">{error || 'O produto que você procura não existe.'}</p>
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
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <button
            onClick={() => router.back()}
            className="text-text-secondary hover:text-text-primary"
          >
            ← Voltar
          </button>
        </div>
      </header>

      {/* Product Details */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div className="bg-surface rounded-lg shadow-card overflow-hidden">
          {/* Image */}
          <div className="relative w-full h-96 bg-background">
            {product.imageUrl ? (
              <Image
                src={product.imageUrl}
                alt={product.name}
                fill
                className="object-cover"
                sizes="100vw"
                unoptimized
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center text-text-light">
                Sem imagem
              </div>
            )}
          </div>

          {/* Details */}
          <div className="p-6">
            <h1 className="text-3xl font-bold text-text-primary mb-4">{product.name}</h1>

            <div className="flex items-center justify-between mb-6">
              <span className="text-4xl font-bold text-primary">
                {formatPrice(product.price)}
              </span>
              {product.rating && (
                <div className="flex items-center gap-2">
                  <span className="text-2xl">⭐</span>
                  <div>
                    <div className="font-semibold">{product.rating.toFixed(1)}</div>
                    {product.reviewCount && (
                      <div className="text-sm text-text-secondary">
                        {product.reviewCount} avaliações
                      </div>
                    )}
                  </div>
                </div>
              )}
            </div>

            {product.description && (
              <div className="mb-6">
                <h2 className="text-lg font-semibold text-text-primary mb-2">Descrição</h2>
                <p className="text-text-secondary">{product.description}</p>
              </div>
            )}

            {product.tags.length > 0 && (
              <div className="mb-6">
                <h2 className="text-lg font-semibold text-text-primary mb-2">Tags</h2>
                <div className="flex flex-wrap gap-2">
                  {product.tags.map((tag) => (
                    <span
                      key={tag}
                      className="px-3 py-1 bg-background text-text-secondary rounded-full text-sm"
                    >
                      {tag}
                    </span>
                  ))}
                </div>
              </div>
            )}

            <button
              onClick={handleOpenInStore}
              className="w-full px-6 py-4 bg-primary text-white rounded-lg font-semibold text-lg hover:bg-primary-dark transition-colors"
            >
              Ver na loja
            </button>
          </div>
        </div>
      </main>
    </div>
  );
}
