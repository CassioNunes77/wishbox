import axios from 'axios';
import { Product } from '@/lib/types/product';
import { APP_CONSTANTS } from '@/lib/constants/app';

export class ApiService {
  /**
   * Busca produtos via backend/Netlify Function
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
      console.log('=== ApiService: Searching for:', params.query);

      // Determinar qual URL usar
      let apiUrl: string;
      
      // Se houver variável de ambiente configurada, usar backend separado
      if (envBackendUrl && envBackendUrl.trim() !== '') {
        let baseUrl = envBackendUrl.trim();
        if (baseUrl.endsWith('/')) {
          baseUrl = baseUrl.slice(0, -1);
        }
        // Se não começar com http, adicionar https://
        if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
          baseUrl = `https://${baseUrl}`;
        }
        apiUrl = `${baseUrl}/api/search`;
        console.log('=== ApiService: Using external backend:', apiUrl);
      } else {
        // Usar /api/search sempre (Next.js API route em dev, Netlify Function em prod)
        // Em desenvolvimento: app/api/search/route.ts faz proxy para backend local (porta 3001)
        // Em produção: netlify.toml redireciona para Netlify Function
        apiUrl = '/api/search';
        if (typeof window !== 'undefined' && process.env.NODE_ENV !== 'production') {
          console.log('=== ApiService: Using Next.js API route (dev - proxy to localhost:3001):', apiUrl);
        } else {
          console.log('=== ApiService: Using Netlify Function (production):', apiUrl);
        }
      }
      
      // Fazer a requisição
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
        // URL relativa - manter como está (será resolvida pelo servidor de origem)
        // Se necessário, adicionar base URL do produto aqui
      }
    }

    return {
      id: json.id || '',
      externalId: json.externalId || json.id || '',
      affiliateSource: json.affiliateSource || 'mercado_livre',
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
