'use client';

import { useEffect, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';

function LoadingContent() {
  const router = useRouter();
  const searchParams = useSearchParams();

  useEffect(() => {
    // Simular carregamento
    const timer = setTimeout(() => {
      const params = new URLSearchParams();
      const query = searchParams.get('query');
      const isSelfGift = searchParams.get('isSelfGift');
      const minPrice = searchParams.get('minPrice');
      const maxPrice = searchParams.get('maxPrice');
      const giftTypes = searchParams.get('giftTypes');

      if (query) params.append('query', query);
      if (isSelfGift) params.append('isSelfGift', isSelfGift);
      if (minPrice) params.append('minPrice', minPrice);
      if (maxPrice) params.append('maxPrice', maxPrice);
      if (giftTypes) params.append('giftTypes', giftTypes);

      router.push(`/suggestions?${params.toString()}`);
    }, 1500);

    return () => clearTimeout(timer);
  }, [router, searchParams]);

  return (
    <div className="min-h-screen bg-background flex items-center justify-center">
      <div className="text-center">
        <div className="inline-block animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-primary mb-4"></div>
        <p className="text-lg text-text-secondary">Analisando perfil...</p>
      </div>
    </div>
  );
}

export default function LoadingProfilePage() {
  return (
    <Suspense fallback={
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-primary mb-4"></div>
          <p className="text-lg text-text-secondary">Carregando...</p>
        </div>
      </div>
    }>
      <LoadingContent />
    </Suspense>
  );
}
