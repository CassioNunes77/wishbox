'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { StoreService } from '@/lib/services/store';
import { AffiliateStore } from '@/lib/types/store';

export default function AdminPage() {
  const router = useRouter();
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [stores, setStores] = useState<AffiliateStore[]>([]);
  const [editingStore, setEditingStore] = useState<AffiliateStore | null>(null);
  const [showAddForm, setShowAddForm] = useState(false);
  
  // Form fields
  const [formData, setFormData] = useState({
    name: '',
    displayName: '',
    affiliateUrlTemplate: '',
    apiEndpoint: '',
    isActive: true,
  });

  useEffect(() => {
    if (isAuthenticated) {
      loadStores();
    }
  }, [isAuthenticated]);

  const loadStores = () => {
    setIsLoading(true);
    const allStores = StoreService.getStores();
    setStores(allStores);
    setIsLoading(false);
  };

  const handleAuthenticate = (e: React.FormEvent) => {
    e.preventDefault();
    const isValid = StoreService.verifyAdminPassword(password);
    if (isValid) {
      setIsAuthenticated(true);
      setPassword('');
    } else {
      alert('Senha incorreta');
    }
  };

  const handleStartEditing = (store: AffiliateStore) => {
    setEditingStore(store);
    setFormData({
      name: store.name,
      displayName: store.displayName,
      affiliateUrlTemplate: store.affiliateUrlTemplate,
      apiEndpoint: store.apiEndpoint || '',
      isActive: store.isActive,
    });
    setShowAddForm(false);
  };

  const handleCancelEditing = () => {
    setEditingStore(null);
    setFormData({
      name: '',
      displayName: '',
      affiliateUrlTemplate: '',
      apiEndpoint: '',
      isActive: true,
    });
    setShowAddForm(false);
  };

  const handleSaveStore = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (editingStore) {
      // Update existing
      const updated: AffiliateStore = {
        ...editingStore,
        ...formData,
        updatedAt: new Date().toISOString(),
      };
      if (StoreService.updateStore(updated)) {
        loadStores();
        handleCancelEditing();
      } else {
        alert('Erro ao atualizar loja');
      }
    } else {
      // Add new
      const newStore: AffiliateStore = {
        id: `store_${Date.now()}`,
        name: formData.name,
        displayName: formData.displayName,
        affiliateUrlTemplate: formData.affiliateUrlTemplate,
        apiEndpoint: formData.apiEndpoint,
        isActive: formData.isActive,
        createdAt: new Date().toISOString(),
      };
      if (StoreService.addStore(newStore)) {
        loadStores();
        handleCancelEditing();
      } else {
        alert('Erro ao adicionar loja. Verifique se o nome já existe.');
      }
    }
  };

  const handleToggleStatus = (id: string) => {
    if (StoreService.toggleStoreStatus(id)) {
      loadStores();
    }
  };

  const handleDelete = (id: string) => {
    if (confirm('Tem certeza que deseja remover esta loja?')) {
      if (StoreService.removeStore(id)) {
        loadStores();
      }
    }
  };

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center">
        <div className="bg-surface rounded-lg shadow-card p-8 max-w-md w-full">
          <h1 className="text-2xl font-bold text-text-primary mb-6 text-center">
            Área Administrativa
          </h1>
          <form onSubmit={handleAuthenticate}>
            <div className="mb-4">
              <label className="block text-sm font-medium text-text-primary mb-2">
                Senha
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-4 py-2 border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                placeholder="Digite a senha"
                required
              />
            </div>
            <button
              type="submit"
              className="w-full px-4 py-2 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark transition-colors"
            >
              Entrar
            </button>
          </form>
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
            <h1 className="text-2xl font-bold text-text-primary">Área Administrativa</h1>
            <div className="flex gap-4">
              <button
                onClick={() => router.push('/')}
                className="px-4 py-2 text-text-secondary hover:text-text-primary"
              >
                Voltar
              </button>
              <button
                onClick={() => setIsAuthenticated(false)}
                className="px-4 py-2 text-error hover:bg-error/10 rounded-lg"
              >
                Sair
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {/* Add/Edit Form */}
        {(showAddForm || editingStore) && (
          <div className="bg-surface rounded-lg shadow-card p-6 mb-6">
            <h2 className="text-xl font-semibold text-text-primary mb-4">
              {editingStore ? 'Editar Loja' : 'Adicionar Nova Loja'}
            </h2>
            <form onSubmit={handleSaveStore} className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-text-primary mb-2">
                  Nome (ID interno)
                </label>
                <input
                  type="text"
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  className="w-full px-4 py-2 border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="ex: magazine_luiza"
                  required
                  disabled={!!editingStore}
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-text-primary mb-2">
                  Nome de Exibição
                </label>
                <input
                  type="text"
                  value={formData.displayName}
                  onChange={(e) => setFormData({ ...formData, displayName: e.target.value })}
                  className="w-full px-4 py-2 border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="ex: Magazine Luiza"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-text-primary mb-2">
                  Template de URL de Afiliado
                </label>
                <input
                  type="text"
                  value={formData.affiliateUrlTemplate}
                  onChange={(e) => setFormData({ ...formData, affiliateUrlTemplate: e.target.value })}
                  className="w-full px-4 py-2 border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="ex: https://www.magazinevoce.com.br/elislecio"
                  required
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-text-primary mb-2">
                  API Endpoint (opcional)
                </label>
                <input
                  type="text"
                  value={formData.apiEndpoint}
                  onChange={(e) => setFormData({ ...formData, apiEndpoint: e.target.value })}
                  className="w-full px-4 py-2 border border-border rounded-lg focus:outline-none focus:ring-2 focus:ring-primary"
                  placeholder="ex: https://api.loja.com/products"
                />
              </div>
              <div className="flex items-center gap-2">
                <input
                  type="checkbox"
                  checked={formData.isActive}
                  onChange={(e) => setFormData({ ...formData, isActive: e.target.checked })}
                  className="w-4 h-4 text-primary border-border rounded focus:ring-primary"
                />
                <label className="text-sm text-text-secondary">Loja ativa</label>
              </div>
              <div className="flex gap-4">
                <button
                  type="submit"
                  className="px-6 py-2 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark transition-colors"
                >
                  {editingStore ? 'Salvar' : 'Adicionar'}
                </button>
                <button
                  type="button"
                  onClick={handleCancelEditing}
                  className="px-6 py-2 bg-background text-text-secondary rounded-lg border border-border hover:bg-surface transition-colors"
                >
                  Cancelar
                </button>
              </div>
            </form>
          </div>
        )}

        {/* Stores List */}
        <div className="bg-surface rounded-lg shadow-card p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold text-text-primary">Lojas Afiliadas</h2>
            {!showAddForm && !editingStore && (
              <button
                onClick={() => {
                  setShowAddForm(true);
                  setEditingStore(null);
                  setFormData({
                    name: '',
                    displayName: '',
                    affiliateUrlTemplate: '',
                    apiEndpoint: '',
                    isActive: true,
                  });
                }}
                className="px-4 py-2 bg-primary text-white rounded-lg font-semibold hover:bg-primary-dark transition-colors"
              >
                + Adicionar Loja
              </button>
            )}
          </div>

          {isLoading ? (
            <div className="text-center py-8">
              <div className="inline-block animate-spin rounded-full h-8 w-8 border-t-4 border-b-4 border-primary"></div>
            </div>
          ) : stores.length === 0 ? (
            <p className="text-text-secondary text-center py-8">Nenhuma loja cadastrada</p>
          ) : (
            <div className="space-y-4">
              {stores.map((store) => (
                <div
                  key={store.id}
                  className="border border-border rounded-lg p-4 hover:bg-background transition-colors"
                >
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <div className="flex items-center gap-3 mb-2">
                        <h3 className="text-lg font-semibold text-text-primary">
                          {store.displayName}
                        </h3>
                        <span
                          className={`px-2 py-1 rounded text-xs font-medium ${
                            store.isActive
                              ? 'bg-success/20 text-success'
                              : 'bg-text-light/20 text-text-light'
                          }`}
                        >
                          {store.isActive ? 'Ativa' : 'Inativa'}
                        </span>
                      </div>
                      <p className="text-sm text-text-secondary mb-1">
                        <strong>ID:</strong> {store.name}
                      </p>
                      <p className="text-sm text-text-secondary mb-1">
                        <strong>Template:</strong> {store.affiliateUrlTemplate}
                      </p>
                      {store.apiEndpoint && (
                        <p className="text-sm text-text-secondary mb-1">
                          <strong>API:</strong> {store.apiEndpoint}
                        </p>
                      )}
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => handleToggleStatus(store.id)}
                        className={`px-3 py-1 rounded text-sm ${
                          store.isActive
                            ? 'bg-warning/20 text-warning'
                            : 'bg-success/20 text-success'
                        } hover:opacity-80 transition-opacity`}
                      >
                        {store.isActive ? 'Desativar' : 'Ativar'}
                      </button>
                      <button
                        onClick={() => handleStartEditing(store)}
                        className="px-3 py-1 bg-primary/20 text-primary rounded text-sm hover:bg-primary/30 transition-colors"
                      >
                        Editar
                      </button>
                      <button
                        onClick={() => handleDelete(store.id)}
                        className="px-3 py-1 bg-error/20 text-error rounded text-sm hover:bg-error/30 transition-colors"
                      >
                        Remover
                      </button>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
