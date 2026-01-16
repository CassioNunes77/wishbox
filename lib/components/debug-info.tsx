'use client';

import { APP_CONSTANTS } from '@/lib/constants/app';
import { StoreService } from '@/lib/services/store';

export function DebugInfo() {
  if (process.env.NODE_ENV === 'production') {
    return null; // Não mostrar em produção
  }

  const backendUrl = APP_CONSTANTS.backendBaseUrl;
  const activeStores = StoreService.getActiveStores();

  return (
    <div className="fixed bottom-4 right-4 bg-surface border border-border rounded-lg shadow-elevated p-4 text-xs max-w-sm z-50">
      <h3 className="font-semibold text-text-primary mb-2">Debug Info</h3>
      <div className="space-y-1 text-text-secondary">
        <div>
          <strong>Backend URL:</strong> {backendUrl}
        </div>
        <div>
          <strong>Active Stores:</strong> {activeStores.length}
          {activeStores.length > 0 && (
            <ul className="ml-4 mt-1">
              {activeStores.map((store) => (
                <li key={store.id}>- {store.displayName}</li>
              ))}
            </ul>
          )}
        </div>
        {activeStores.length === 0 && (
          <div className="text-error text-xs mt-2">
            ⚠️ Nenhuma loja ativa configurada!
          </div>
        )}
      </div>
    </div>
  );
}
