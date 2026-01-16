import axios from 'axios';
import { Product } from '@/lib/types/product';
import { APP_CONSTANTS } from '@/lib/constants/app';

// Em produção no Netlify, usa a função serverless (relativa)
// Em desenvolvimento, usa backend separado ou Netlify Dev
const API_BASE_URL = typeof window !== 'undefined' && !APP_CONSTANTS.backendBaseUrl
  ? '/api/search' // Usa função Netlify (relativa)
  : APP_CONSTANTS.backendBaseUrl;

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
      // Debug: verificar variável de ambiente
      const envBackendUrl = process.env.NEXT_PUBLIC_BACKEND_URL;
      console.log('=== ApiService: ENV NEXT_PUBLIC_BACKEND_URL:', envBackendUrl);
      console.log('=== ApiService: APP_CONSTANTS.backendBaseUrl:', API_BASE_URL);
      console.log('=== ApiService: Searching for:', params.query);

      // Se a variável de ambiente não estiver definida, usar fallback
      const backendUrl = envBackendUrl || API_BASE_URL;
      console.log('=== ApiService: Using backend URL:', backendUrl);

      // Se não houver backendBaseUrl ou for string vazia (produção Netlify), usar função serverless
      if (!backendUrl || backendUrl === '' || backendUrl === 'undefined') {
        const apiUrl = '/api/search';
        
        console.log('=== ApiService: Using Netlify Function:', apiUrl);
        
        const response = await axios.get(apiUrl, {
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
      }
      
      // URL absoluta (backend separado ou desenvolvimento)
      let baseUrl = backendUrl.trim();
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.slice(0, -1);
      }
      // Se não começar com http, adicionar https://
      if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
        baseUrl = `https://${baseUrl}`;
      }
      
      const apiUrl = `${baseUrl}/api/search`;
      
      console.log('=== ApiService: Final baseUrl:', baseUrl);
      console.log('=== ApiService: Full API URL:', apiUrl);
      
      const response = await axios.get(apiUrl, {
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
      console.error('=== ApiService: Error message:', error.message);
      console.error('=== ApiService: Response data:', error.response?.data);
      console.error('=== ApiService: Response status:', error.response?.status);
      console.error('=== ApiService: Request URL:', `${API_BASE_URL}/api/search`);
      console.error('=== ApiService: Request params:', {
        query: params.query,
        limit: params.limit,
        affiliateUrl: params.affiliateUrl,
      });
      
      // Relançar o erro para que o componente possa tratá-lo
      throw error;
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
