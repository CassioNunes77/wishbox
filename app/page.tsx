'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { APP_CONSTANTS } from '@/lib/constants/app';

export default function HomePage() {
  const router = useRouter();
  const [query, setQuery] = useState('');
  const [isSelfGift, setIsSelfGift] = useState(false);
  const [showFilters, setShowFilters] = useState(false);
  const [minPrice, setMinPrice] = useState(50);
  const [maxPrice, setMaxPrice] = useState(500);
  const [selectedGiftTypes, setSelectedGiftTypes] = useState<Set<string>>(new Set());

  const handleSearch = () => {
    if (!query.trim()) {
      alert('Descreva a pessoa ou o que você procura');
      return;
    }

    // Construir URL com parâmetros
    const params = new URLSearchParams({
      query: query.trim(),
      isSelfGift: isSelfGift.toString(),
      minPrice: minPrice.toString(),
      maxPrice: maxPrice.toString(),
    });

    if (selectedGiftTypes.size > 0) {
      params.append('giftTypes', Array.from(selectedGiftTypes).join(','));
    }

    router.push(`/loading-profile?${params.toString()}`);
  };

  const toggleGiftType = (type: string) => {
    setSelectedGiftTypes((prev) => {
      const next = new Set(prev);
      if (next.has(type)) {
        next.delete(type);
      } else {
        next.add(type);
      }
      return next;
    });
  };

  return (
    <div className="min-h-screen bg-white">
      {/* Header */}
      <header className="bg-white border-b border-border">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <h1 className="text-2xl font-semibold text-text-primary">WishBox</h1>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
        <div className="text-center mb-8">
          <h2 className="text-3xl sm:text-4xl font-bold text-text-primary mb-4">
            Encontre o presente ideal
          </h2>
          <p className="text-lg text-text-secondary">
            Descreva a pessoa ou o que você procura
          </p>
        </div>

        {/* Search Box */}
        <div className="bg-surface rounded-lg shadow-card p-6 mb-6">
          <div className="flex flex-col sm:flex-row gap-4 mb-4">
            <input
              type="text"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
              placeholder="Ex: presente para mãe, café, eletrônicos..."
              className="flex-1 px-4 py-3 border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
            />
            <button
              onClick={handleSearch}
              className="px-8 py-3 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark transition-colors"
            >
              Buscar
            </button>
          </div>

          {/* Self Gift Toggle */}
          <label className="flex items-center gap-2 cursor-pointer mb-4">
            <input
              type="checkbox"
              checked={isSelfGift}
              onChange={(e) => setIsSelfGift(e.target.checked)}
              className="w-4 h-4 text-primary border-border rounded focus:ring-primary"
            />
            <span className="text-sm text-text-secondary">
              É um presente para mim mesmo
            </span>
          </label>

          {/* Filters Toggle */}
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="text-sm text-primary hover:underline mb-4"
          >
            {showFilters ? 'Ocultar' : 'Mostrar'} filtros
          </button>

          {/* Filters */}
          {showFilters && (
            <div className="border-t border-divider pt-4 space-y-4">
              {/* Price Range */}
              <div>
                <label className="block text-sm font-medium text-text-primary mb-2">
                  Faixa de preço: R$ {minPrice} - R$ {maxPrice}
                </label>
                <div className="flex gap-4">
                  <input
                    type="range"
                    min="0"
                    max="1000"
                    value={minPrice}
                    onChange={(e) => setMinPrice(Number(e.target.value))}
                    className="flex-1"
                  />
                  <input
                    type="range"
                    min="0"
                    max="1000"
                    value={maxPrice}
                    onChange={(e) => setMaxPrice(Number(e.target.value))}
                    className="flex-1"
                  />
                </div>
              </div>

              {/* Gift Types */}
              <div>
                <label className="block text-sm font-medium text-text-primary mb-2">
                  Tipos de presente
                </label>
                <div className="flex flex-wrap gap-2">
                  {APP_CONSTANTS.giftTypes.map((type) => (
                    <button
                      key={type}
                      onClick={() => toggleGiftType(type)}
                      className={`px-4 py-2 rounded-lg text-sm transition-colors ${
                        selectedGiftTypes.has(type)
                          ? 'bg-primary text-white'
                          : 'bg-background text-text-secondary border border-border hover:border-primary'
                      }`}
                    >
                      {type}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Info Section */}
        <div className="text-center text-sm text-text-light">
          <p>Use nossa IA para encontrar os melhores presentes</p>
        </div>
      </main>
    </div>
  );
}
