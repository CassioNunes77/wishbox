import axios from 'axios';
import { Product } from '@/lib/types/product';
import { APP_CONSTANTS } from '@/lib/constants/app';

const API_BASE_URL = APP_CONSTANTS.backendBaseUrl;

export class ApiService {
  /**
   * Busca produtos da Magazine Luiza via backend
   */
  static async searchProducts(params: {
    query: string;
    limit?: number;
    affiliateUrl?: string;
  }): Promise<Product[]> {
    try {
      console.log('=== ApiService: Searching for:', params.query);
      console.log('=== ApiService: Using backend:', API_BASE_URL);

      const response = await axios.get(`${API_BASE_URL}/api/search`, {
        params: {
          query: params.query,
          limit: params.limit || 20,
          ...(params.affiliateUrl && { affiliateUrl: params.affiliateUrl }),
        },
        timeout: 30000,
      });

      console.log('=== ApiService: Response status:', response.status);

      if (response.data.success && response.data.products) {
        const products = response.data.products.map((p: any) => this.parseProduct(p));
        console.log('=== ApiService: Found', products.length, 'products');
        return products;
      }

      console.log('=== ApiService: Backend returned error:', response.data.error);
      return [];
    } catch (error: any) {
      console.error('=== ApiService: Error:', error);
      console.error('=== ApiService: Error type:', error.constructor.name);
      console.log('=== ApiService: Backend não disponível - verifique se está rodando');
      return [];
    }
  }

  /**
   * Converte JSON do backend para objeto Product
   */
  private static parseProduct(json: any): Product {
    let imageUrl = json.imageUrl || '';

    // Validar e limpar URL da imagem
    if (imageUrl) {
      imageUrl = imageUrl.trim();

      // Garantir URL completa
      if (imageUrl.startsWith('//')) {
        imageUrl = `https:${imageUrl}`;
      } else if (imageUrl.startsWith('/')) {
        imageUrl = `https://www.magazineluiza.com.br${imageUrl}`;
      }
    }

    return {
      id: json.id || '',
      externalId: json.externalId || json.id || '',
      affiliateSource: json.affiliateSource || 'magazine_luiza',
      name: json.name || 'Produto sem nome',
      description: json.description || '',
      price: json.price || 0,
      currency: json.currency || 'BRL',
      category: json.category || 'Geral',
      imageUrl,
      productUrlBase: json.productUrlBase || '',
      affiliateUrl: json.affiliateUrl,
      rating: json.rating,
      reviewCount: json.reviewCount,
      tags: json.tags || [],
    };
  }

  /**
   * Busca produtos populares
   */
  static async getPopularProducts(params?: {
    limit?: number;
    affiliateUrl?: string;
  }): Promise<Product[]> {
    return this.searchProducts({
      query: 'presentes',
      limit: params?.limit || 20,
      affiliateUrl: params?.affiliateUrl,
    });
  }
}
