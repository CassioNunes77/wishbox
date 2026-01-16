import { Product } from '@/lib/types/product';
import { StorageService } from './storage';

const STORAGE_KEY = 'favorite_products';

export class FavoritesService {
  /**
   * Adiciona um produto aos favoritos
   */
  static addFavorite(product: Product): boolean {
    try {
      const favorites = this.getFavorites();
      
      // Verificar se já está nos favoritos
      if (favorites.some((p) => p.id === product.id)) {
        return false; // Já está nos favoritos
      }

      favorites.push(product);
      return StorageService.setItem(STORAGE_KEY, favorites);
    } catch (error) {
      console.error('FavoritesService: Error adding favorite:', error);
      return false;
    }
  }

  /**
   * Remove um produto dos favoritos
   */
  static removeFavorite(productId: string): boolean {
    try {
      const favorites = this.getFavorites();
      const filtered = favorites.filter((p) => p.id !== productId);
      return StorageService.setItem(STORAGE_KEY, filtered);
    } catch (error) {
      console.error('FavoritesService: Error removing favorite:', error);
      return false;
    }
  }

  /**
   * Verifica se um produto está nos favoritos
   */
  static isFavorite(productId: string): boolean {
    try {
      const favorites = this.getFavorites();
      return favorites.some((p) => p.id === productId);
    } catch (error) {
      console.error('FavoritesService: Error checking favorite:', error);
      return false;
    }
  }

  /**
   * Obtém todos os produtos favoritos
   */
  static getFavorites(): Product[] {
    try {
      const favorites = StorageService.getItem<Product[]>(STORAGE_KEY);
      return favorites || [];
    } catch (error) {
      console.error('FavoritesService: Error getting favorites:', error);
      return [];
    }
  }

  /**
   * Limpa todos os favoritos
   */
  static clearFavorites(): boolean {
    return StorageService.removeItem(STORAGE_KEY);
  }
}
