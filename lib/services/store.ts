import { AffiliateStore } from '@/lib/types/store';
import { StorageService } from './storage';

const STORAGE_KEY = 'affiliate_stores';
const ADMIN_PASSWORD = 'admin123'; // Senha simples para demo

export class StoreService {
  /**
   * Verifica se a senha do admin está correta
   */
  static verifyAdminPassword(password: string): boolean {
    return password === ADMIN_PASSWORD;
  }

  /**
   * Obtém todas as lojas afiliadas
   */
  static getStores(): AffiliateStore[] {
    const stores = StorageService.getItem<AffiliateStore[]>(STORAGE_KEY);
    return stores || this.getDefaultStores();
  }

  /**
   * Obtém apenas lojas ativas
   */
  static getActiveStores(): AffiliateStore[] {
    return this.getStores().filter((store) => store.isActive);
  }

  /**
   * Obtém uma loja por ID
   */
  static getStoreById(id: string): AffiliateStore | null {
    const stores = this.getStores();
    return stores.find((s) => s.id === id) || null;
  }

  /**
   * Obtém uma loja por nome
   */
  static getStoreByName(name: string): AffiliateStore | null {
    const stores = this.getStores();
    return stores.find((s) => s.name.toLowerCase() === name.toLowerCase()) || null;
  }

  /**
   * Adiciona uma nova loja
   */
  static addStore(store: AffiliateStore): boolean {
    const stores = this.getStores();
    
    // Verificar se já existe
    if (stores.some((s) => s.id === store.id || s.name === store.name)) {
      return false;
    }

    stores.push(store);
    return this.saveStores(stores);
  }

  /**
   * Atualiza uma loja
   */
  static updateStore(updatedStore: AffiliateStore): boolean {
    const stores = this.getStores();
    const index = stores.findIndex((s) => s.id === updatedStore.id);
    
    if (index === -1) {
      return false;
    }

    stores[index] = {
      ...updatedStore,
      updatedAt: new Date().toISOString(),
    };
    return this.saveStores(stores);
  }

  /**
   * Remove uma loja
   */
  static removeStore(id: string): boolean {
    const stores = this.getStores();
    const filtered = stores.filter((s) => s.id !== id);
    return this.saveStores(filtered);
  }

  /**
   * Ativa/desativa uma loja
   */
  static toggleStoreStatus(id: string): boolean {
    const stores = this.getStores();
    const index = stores.findIndex((s) => s.id === id);
    
    if (index === -1) return false;

    stores[index] = {
      ...stores[index],
      isActive: !stores[index].isActive,
      updatedAt: new Date().toISOString(),
    };
    return this.saveStores(stores);
  }

  /**
   * Salva lista de lojas
   */
  static saveStores(stores: AffiliateStore[]): boolean {
    return StorageService.setItem(STORAGE_KEY, stores);
  }

  /**
   * Gera URL de afiliado para um produto
   */
  static generateAffiliateUrl(store: AffiliateStore, productUrl: string): string {
    console.log('🔧 StoreService.generateAffiliateUrl INICIANDO');
    console.log('   Template:', store.affiliateUrlTemplate);
    console.log('   ProductUrl input:', productUrl);

    // Se o template contém {productUrl}, substitui
    if (store.affiliateUrlTemplate.includes('{productUrl}')) {
      return store.affiliateUrlTemplate.replace('{productUrl}', productUrl);
    }

    // Remover duplicações do template no início do productUrl
    let cleanProductUrl = productUrl;
    const templateNormalized = store.affiliateUrlTemplate.trim();

    // Remover TODAS as ocorrências do template do início
    let removals = 0;
    while (cleanProductUrl.startsWith(templateNormalized)) {
      cleanProductUrl = cleanProductUrl.substring(templateNormalized.length);
      removals++;
    }
    if (removals > 0) {
      console.log('   ✅ Removido template', removals, 'vez(es):', cleanProductUrl);
    }

    // Se ainda é URL completa, extrair apenas o caminho
    if (cleanProductUrl.startsWith('http://') || cleanProductUrl.startsWith('https://')) {
      console.log('   🔍 É URL completa, extraindo caminho...');
      try {
        const url = new URL(cleanProductUrl);
        cleanProductUrl = url.pathname + (url.search || '');
        console.log('   ✅ Caminho extraído:', cleanProductUrl);
      } catch (e) {
        const match = cleanProductUrl.match(/https?:\/\/[^/]+(\/.*)/);
        if (match && match[1]) {
          cleanProductUrl = match[1];
          console.log('   ✅ Fallback caminho extraído:', cleanProductUrl);
        }
      }
    }

    // Remover duplicações do caminho do template
    try {
      const templateUrl = new URL(templateNormalized);
      const templatePath = templateUrl.pathname;
      console.log('   📂 Template path:', templatePath);

      if (templatePath && cleanProductUrl.startsWith(templatePath)) {
        cleanProductUrl = cleanProductUrl.substring(templatePath.length);
        console.log('   ✅ Removido template path:', cleanProductUrl);
      }

      // Remover segmentos duplicados
      const templateSegments = templatePath.split('/').filter((s) => s);
      if (templateSegments.length > 0) {
        const lastSegment = templateSegments[templateSegments.length - 1];
        console.log('   🔍 Último segmento do template:', lastSegment);
        let segmentRemovals = 0;
        const segmentRegex = new RegExp(`^/?${lastSegment}/`);
        while (segmentRegex.test(cleanProductUrl)) {
          cleanProductUrl = cleanProductUrl.replace(segmentRegex, '/');
          segmentRemovals++;
        }
        if (segmentRemovals > 0) {
          console.log('   ✅ Removido segmento', lastSegment, segmentRemovals, 'vez(es):', cleanProductUrl);
        }
      }
    } catch (e) {
      console.log('   ⚠️ Erro ao processar template path:', e);
    }

    // Limpar barras duplicadas e garantir que comece com /
    cleanProductUrl = cleanProductUrl.replace(/\/+/g, '/');
    if (cleanProductUrl.startsWith('//')) {
      cleanProductUrl = cleanProductUrl.substring(1);
    }
    if (!cleanProductUrl.startsWith('/')) {
      cleanProductUrl = '/' + cleanProductUrl;
    }

    // Preparar base URL
    let baseUrl = templateNormalized;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    // Se é um prefixo com query, adiciona o productUrl
    if (store.affiliateUrlTemplate.endsWith('?') || store.affiliateUrlTemplate.endsWith('&')) {
      return store.affiliateUrlTemplate + cleanProductUrl;
    }

    // Caso padrão: concatena base + caminho limpo
    const finalUrl = baseUrl + cleanProductUrl;
    console.log('   🎯 URL FINAL:', finalUrl);
    console.log('🔧 StoreService.generateAffiliateUrl FINALIZADO\n');
    return finalUrl;
  }

  // TODO: REMOVER TESTE - Link de afiliado temporário para teste
  // Para remover: delete esta constante TEST_AFFILIATE_URL e use string vazia
  private static readonly TEST_AFFILIATE_URL = 'https://www.magazinevoce.com.br/elislecio/';

  /**
   * Lojas padrão (para inicialização)
   */
  private static getDefaultStores(): AffiliateStore[] {
    const now = new Date().toISOString();
    return [
      {
        id: 'magazine_luiza',
        name: 'magazine_luiza',
        displayName: 'Magazine Luiza',
        affiliateUrlTemplate: this.TEST_AFFILIATE_URL, // TODO: REMOVER TESTE - Usar string vazia quando não precisar mais
        isActive: true,
        createdAt: now,
      },
      {
        id: 'amazon',
        name: 'amazon',
        displayName: 'Amazon',
        affiliateUrlTemplate: 'https://amazon.com.br/dp/{productId}?tag=wishbox-20',
        isActive: false,
        createdAt: now,
      },
      {
        id: 'mercado_livre',
        name: 'mercado_livre',
        displayName: 'Mercado Livre',
        affiliateUrlTemplate: 'https://produto.mercadolivre.com.br/{productId}?matt_tool=wishbox',
        isActive: false,
        createdAt: now,
      },
    ];
  }
}
