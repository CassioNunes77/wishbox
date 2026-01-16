const express = require('express');
const cors = require('cors');
const axios = require('axios');
const cheerio = require('cheerio');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors()); // Permite requisições de qualquer origem
app.use(express.json());

// Endpoint de busca de produtos
app.get('/api/search', async (req, res) => {
  try {
    const { query, affiliateUrl, limit = 20 } = req.query;

    if (!query) {
      return res.status(400).json({ 
        error: 'Query parameter is required' 
      });
    }

    console.log(`[${new Date().toISOString()}] Buscando produtos: "${query}"`);

    // Construir URL de busca
    let searchUrl;
    if (affiliateUrl) {
      const baseUrl = affiliateUrl.endsWith('/') 
        ? affiliateUrl.substring(0, affiliateUrl.length - 1)
        : affiliateUrl;
      const encodedQuery = encodeURIComponent(query);
      // Tentar diferentes formatos de URL
      searchUrl = `${baseUrl}/busca/${encodedQuery}`;
    } else {
      const encodedQuery = encodeURIComponent(query);
      searchUrl = `https://www.magazineluiza.com.br/busca/${encodedQuery}`;
    }

    console.log(`[${new Date().toISOString()}] URL de busca: ${searchUrl}`);
    
    // Adicionar delay aleatório para parecer mais humano (2-5 segundos)
    const randomDelay = Math.floor(Math.random() * 3000) + 2000;
    console.log(`[${new Date().toISOString()}] Aguardando ${randomDelay}ms antes da requisição...`);
    await new Promise(resolve => setTimeout(resolve, randomDelay));

    // Rotacionar User-Agents para parecer mais diverso
    const userAgents = [
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Safari/537.36',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15',
    ];
    const randomUserAgent = userAgents[Math.floor(Math.random() * userAgents.length)];

    // Fazer requisição HTTP com headers mais completos para evitar bloqueio
    let response;
    try {
      response = await axios.get(searchUrl, {
        headers: {
          'User-Agent': randomUserAgent,
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          'Accept-Language': 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
          'Accept-Encoding': 'gzip, deflate, br',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
          'Sec-Fetch-Dest': 'document',
          'Sec-Fetch-Mode': 'navigate',
          'Sec-Fetch-Site': 'none',
          'Sec-Fetch-User': '?1',
          'Cache-Control': 'max-age=0',
          'Referer': 'https://www.google.com/',
          'DNT': '1',
          'sec-ch-ua': '"Not_A Brand";v="8", "Chromium";v="120", "Google Chrome";v="120"',
          'sec-ch-ua-mobile': '?0',
          'sec-ch-ua-platform': '"Windows"',
        },
        timeout: 25000,
        maxRedirects: 5,
        validateStatus: function (status) {
          return status >= 200 && status < 500; // Aceitar até 499 para ver o erro
        },
      });
    } catch (axiosError) {
      // Se axios lançar erro (não response), tratar aqui
      if (axiosError.response) {
        response = axiosError.response;
      } else {
        throw axiosError;
      }
    }

    if (response.status !== 200) {
      console.error(`[${new Date().toISOString()}] HTTP ${response.status}`);
      console.error(`[${new Date().toISOString()}] Response headers:`, response.headers);
      
      if (response.status === 403) {
        return res.status(403).json({ 
          error: 'Acesso negado pelo Magazine Luiza. O site pode estar bloqueando requisições automatizadas.',
          details: 'Tente novamente em alguns minutos ou verifique se o site está acessível.',
          products: []
        });
      }
      
      return res.status(response.status).json({ 
        error: `HTTP ${response.status}`,
        details: response.status === 403 ? 'Acesso negado - possível bloqueio anti-bot' : 'Erro ao acessar o site',
        products: []
      });
    }

    console.log(`[${new Date().toISOString()}] HTML recebido (${response.data.length} bytes)`);

    // Parse do HTML
    const products = parseProductsFromHtml(response.data, query, affiliateUrl, parseInt(limit));

    console.log(`[${new Date().toISOString()}] ${products.length} produtos encontrados`);

    res.json({
      success: true,
      query,
      affiliateUrl: affiliateUrl || null,
      products,
      count: products.length
    });

  } catch (error) {
    console.error(`[${new Date().toISOString()}] Erro:`, error.message);
    console.error(`[${new Date().toISOString()}] Stack:`, error.stack);
    
    // Se for erro 403 (Forbidden), retornar erro mais específico
    if (error.response && error.response.status === 403) {
      console.error(`[${new Date().toISOString()}] Erro 403: Magazine Luiza bloqueou a requisição`);
      return res.status(403).json({ 
        error: 'Acesso negado pelo site. O site pode estar bloqueando requisições automatizadas.',
        details: 'O Magazine Luiza pode estar bloqueando requisições que não vêm de navegadores reais.',
        products: []
      });
    }
    
    // Erro genérico
    res.status(500).json({ 
      error: error.message || 'Erro interno do servidor',
      details: error.response ? `HTTP ${error.response.status}` : 'Erro desconhecido',
      products: []
    });
  }
});

// Função para fazer parse do HTML e extrair produtos
function parseProductsFromHtml(html, query, affiliateUrl, limit) {
  const $ = cheerio.load(html);
  const products = [];

  try {
    // Estratégia 1: Procurar por produtos usando data attributes da Magazine Luiza
    // A Magazine Luiza usa diferentes estruturas, vamos tentar várias

    // Procurar por elementos com data-product-id ou data-product
    $('[data-product-id], [data-product], [data-product-name]').each((index, element) => {
      if (products.length >= limit) return false;

      const $el = $(element);
      
      // Tentar extrair informações do produto
      const productId = $el.attr('data-product-id') || 
                       $el.attr('data-product') || 
                       $el.find('[data-product-id]').attr('data-product-id') ||
                       `ml_${Date.now()}_${index}`;

      // Nome do produto
      const name = $el.find('h2, h3, .product-title, [data-product-name]').first().text().trim() ||
                   $el.attr('data-product-name') ||
                   $el.find('a').first().attr('title') ||
                   `Produto ${index + 1}`;

      // Preço
      const priceText = $el.find('.price, .price-value, [data-price]').first().text().trim() ||
                       $el.attr('data-price') ||
                       $el.find('[class*="price"]').first().text().trim();
      
      const price = parsePrice(priceText);

      // URL do produto
      const productUrl = $el.find('a').first().attr('href') ||
                        $el.attr('href') ||
                        `https://www.magazineluiza.com.br/produto/${productId}`;

      // URL completa
      const fullProductUrl = productUrl.startsWith('http') 
        ? productUrl 
        : `https://www.magazineluiza.com.br${productUrl}`;

      // URL de afiliado - CORRIGIDO para evitar duplicações
      let affiliateProductUrl = fullProductUrl;
      if (affiliateUrl) {
        const baseUrl = affiliateUrl.endsWith('/') 
          ? affiliateUrl.substring(0, affiliateUrl.length - 1)
          : affiliateUrl;
        
        // Extrair caminho relativo da URL completa
        let relativePath = fullProductUrl;
        if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
          try {
            const url = new URL(relativePath);
            relativePath = url.pathname + url.search;
          } catch (e) {
            const match = relativePath.match(/https?:\/\/[^\/]+(\/.+)/);
            if (match && match[1]) {
              relativePath = match[1];
            }
          }
        }
        
        // REMOVER o segmento do afiliado do caminho
        try {
          const affiliateUrlObj = new URL(affiliateUrl);
          const affiliatePath = affiliateUrlObj.pathname; // Ex: /elislecio/
          const cleanAffiliatePath = affiliatePath.endsWith('/') 
            ? affiliatePath.substring(0, affiliatePath.length - 1)
            : affiliatePath; // Ex: /elislecio
          
          console.log('🔧 DEBUG REMOÇÃO:');
          console.log('   affiliatePath:', affiliatePath);
          console.log('   cleanAffiliatePath:', cleanAffiliatePath);
          console.log('   relativePath ANTES:', relativePath);
          
          // Remover o caminho do afiliado do início do relativePath
          if (cleanAffiliatePath && cleanAffiliatePath !== '/') {
            // Primeiro: remover /elislecio/ do início (com barra)
            const pathWithSlash = cleanAffiliatePath + '/';
            console.log('   Tentando remover:', pathWithSlash);
            while (relativePath.startsWith(pathWithSlash)) {
              relativePath = relativePath.substring(pathWithSlash.length);
              console.log('   ✅ Removido (com barra), restante:', relativePath);
            }
            
            // Segundo: remover /elislecio do início (sem barra final)
            if (relativePath.startsWith(cleanAffiliatePath)) {
              relativePath = relativePath.substring(cleanAffiliatePath.length);
              console.log('   ✅ Removido (sem barra), restante:', relativePath);
              // Se começar com /, remover também
              if (relativePath.startsWith('/')) {
                relativePath = relativePath.substring(1);
                console.log('   ✅ Removido barra inicial, restante:', relativePath);
              }
            }
            
            // Terceiro: remover segmento duplicado (ex: elislecio/elislecio/)
            const lastSegment = cleanAffiliatePath.split('/').filter(s => s).pop(); // Ex: elislecio
            console.log('   Último segmento:', lastSegment);
            if (lastSegment) {
              // Remover elislecio/ do início
              while (relativePath.startsWith(lastSegment + '/')) {
                relativePath = relativePath.substring((lastSegment + '/').length);
                console.log('   ✅ Removido segmento (sem barra inicial), restante:', relativePath);
              }
              // Remover /elislecio/ do início
              while (relativePath.startsWith('/' + lastSegment + '/')) {
                relativePath = relativePath.substring(('/' + lastSegment + '/').length);
                console.log('   ✅ Removido segmento (com barra inicial), restante:', relativePath);
              }
            }
          }
          
          console.log('   relativePath DEPOIS:', relativePath);
        } catch (e) {
          console.log('   ⚠️ Erro:', e.message);
        }
        
        // Garantir que comece com /
        if (!relativePath.startsWith('/')) {
          relativePath = '/' + relativePath;
        }
        
        // Concatenar: baseUrl + relativePath
        affiliateProductUrl = `${baseUrl}${relativePath}`;
      }

      // Imagem - múltiplas estratégias para garantir que sempre haja uma imagem
      let imageUrl = null;
      
      // Estratégia 1: data-src (lazy loading)
      imageUrl = $el.find('img').first().attr('data-src') || 
                 $el.find('img[data-src]').first().attr('data-src');
      
      // Estratégia 2: src direto
      if (!imageUrl || imageUrl === '') {
        imageUrl = $el.find('img').first().attr('src');
      }
      
      // Estratégia 3: procurar em elementos filhos
      if (!imageUrl || imageUrl === '') {
        imageUrl = $el.find('img').eq(0).attr('data-src') || 
                   $el.find('img').eq(0).attr('src') ||
                   $el.find('picture img').first().attr('src') ||
                   $el.find('picture source').first().attr('srcset')?.split(' ')[0];
      }
      
      // Estratégia 4: procurar por background-image em style
      if (!imageUrl || imageUrl === '') {
        const style = $el.find('[style*="background-image"]').first().attr('style');
        if (style) {
          const match = style.match(/url\(['"]?([^'"]+)['"]?\)/);
          if (match && match[1]) {
            imageUrl = match[1];
          }
        }
      }
      
      // Estratégia 5: procurar em qualquer elemento img próximo
      if (!imageUrl || imageUrl === '') {
        imageUrl = $el.closest('div, li, article').find('img').first().attr('data-src') ||
                   $el.closest('div, li, article').find('img').first().attr('src');
      }
      
      // Garantir URL completa se for relativa
      if (imageUrl && imageUrl !== '' && !imageUrl.startsWith('http')) {
        if (imageUrl.startsWith('//')) {
          imageUrl = 'https:' + imageUrl;
        } else if (imageUrl.startsWith('/')) {
          imageUrl = 'https://www.magazineluiza.com.br' + imageUrl;
        } else {
          imageUrl = 'https://www.magazineluiza.com.br/' + imageUrl;
        }
      }
      
      // Garantir que sempre haja uma imagem válida
      imageUrl = ensureValidImageUrl(imageUrl, name);

      // Descrição
      const description = $el.find('.product-description, .description, p').first().text().trim() ||
                         `Produto ${name} da Magazine Luiza. Perfeito para presentes especiais.`;

      // Rating (tentar extrair se disponível)
      const ratingText = $el.find('[data-rating], .rating, .stars').first().text().trim() ||
                        $el.attr('data-rating');
      const rating = ratingText ? parseFloat(ratingText.replace(',', '.')) : (4.0 + Math.random() * 1.0);

      // Review count
      const reviewText = $el.find('.reviews, [data-reviews]').first().text().trim() ||
                        $el.attr('data-reviews');
      const reviewCount = reviewText ? parseInt(reviewText.replace(/\D/g, '')) : Math.floor(Math.random() * 500) + 50;

      // Categoria
      const category = $el.find('[data-category], .category').first().text().trim() ||
                      'Geral';

      // Tags baseadas na query
      const tags = generateTagsFromQuery(query);

      if (name && name !== `Produto ${index + 1}` && price > 0) {
        products.push({
          id: productId,
          externalId: productId,
          affiliateSource: 'magazine_luiza',
          name: name.substring(0, 200), // Limitar tamanho
          description: description.substring(0, 500),
          price: price,
          currency: 'BRL',
          category: category,
          imageUrl: imageUrl,
          productUrlBase: fullProductUrl,
          affiliateUrl: affiliateProductUrl,
          rating: Math.round(rating * 10) / 10,
          reviewCount: reviewCount,
          tags: tags
        });
      }
    });

    // Estratégia 2: Se não encontrou produtos, procurar por estrutura JSON-LD
    if (products.length === 0) {
      $('script[type="application/ld+json"]').each((index, element) => {
        try {
          const jsonData = JSON.parse($(element).html());
          if (jsonData['@type'] === 'Product' || (Array.isArray(jsonData) && jsonData[0] && jsonData[0]['@type'] === 'Product')) {
            const productData = Array.isArray(jsonData) ? jsonData[0] : jsonData;
            
            const productId = productData.sku || productData.productID || `ml_${Date.now()}_${index}`;
            const name = productData.name || `Produto ${index + 1}`;
            const price = productData.offers?.price || productData.price || 0;
            // Garantir que sempre haja uma imagem válida
            let imageUrl = null;
            if (productData.image) {
              if (Array.isArray(productData.image)) {
                imageUrl = productData.image[0] || productData.image.find(img => img && img.startsWith('http'));
              } else if (typeof productData.image === 'string') {
                imageUrl = productData.image;
              }
            }
            
            // Garantir URL completa
            if (imageUrl && !imageUrl.startsWith('http')) {
              if (imageUrl.startsWith('//')) {
                imageUrl = 'https:' + imageUrl;
              } else if (imageUrl.startsWith('/')) {
                imageUrl = 'https://www.magazineluiza.com.br' + imageUrl;
              }
            }
            
            // Garantir que sempre haja uma imagem válida
            imageUrl = ensureValidImageUrl(imageUrl, name);
            const description = productData.description || `Produto ${name}`;
            const rating = productData.aggregateRating?.ratingValue || 4.0;
            const reviewCount = productData.aggregateRating?.reviewCount || 100;

            let affiliateProductUrl = productData.url || `https://www.magazineluiza.com.br/produto/${productId}`;
            if (affiliateUrl) {
              const baseUrl = affiliateUrl.endsWith('/') 
                ? affiliateUrl.substring(0, affiliateUrl.length - 1)
                : affiliateUrl;
              
              // Extrair caminho relativo
              let relativePath = productData.url || `/produto/${productId}`;
              if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
                try {
                  const url = new URL(relativePath);
                  relativePath = url.pathname + url.search;
                } catch (e) {
                  const match = relativePath.match(/https?:\/\/[^\/]+(\/.+)/);
                  if (match && match[1]) relativePath = match[1];
                }
              }
              if (!relativePath.startsWith('/')) relativePath = '/' + relativePath;
              
              affiliateProductUrl = `${baseUrl}${relativePath}`;
            }

            products.push({
              id: productId,
              externalId: productId,
              affiliateSource: 'magazine_luiza',
              name: name.substring(0, 200),
              description: description.substring(0, 500),
              price: parseFloat(price),
              currency: 'BRL',
              category: productData.category || 'Geral',
              imageUrl: imageUrl,
              productUrlBase: productData.url || `https://www.magazineluiza.com.br/produto/${productId}`,
              affiliateUrl: affiliateProductUrl,
              rating: Math.round(rating * 10) / 10,
              reviewCount: reviewCount,
              tags: generateTagsFromQuery(query)
            });
          }
        } catch (e) {
          // Ignorar erros de parse JSON
        }
      });
    }

    // Estratégia 3: Procurar por links de produtos
    if (products.length === 0) {
      $('a[href*="/produto/"], a[href*="/p/"]').each((index, element) => {
        if (products.length >= limit) return false;

        const $el = $(element);
        const href = $el.attr('href');
        const name = $el.find('img').attr('alt') || 
                    $el.text().trim() || 
                    `Produto ${index + 1}`;
        
        if (href && name && name !== `Produto ${index + 1}`) {
          const productId = href.match(/\/produto\/([^\/]+)/)?.[1] || 
                          href.match(/\/p\/([^\/]+)/)?.[1] || 
                          `ml_${Date.now()}_${index}`;
          
          const fullUrl = href.startsWith('http') ? href : `https://www.magazineluiza.com.br${href}`;
          
          let affiliateProductUrl = fullUrl;
          if (affiliateUrl) {
            const baseUrl = affiliateUrl.endsWith('/') 
              ? affiliateUrl.substring(0, affiliateUrl.length - 1)
              : affiliateUrl;
            
            // Extrair caminho relativo
            let relativePath = href;
            if (relativePath.startsWith('http://') || relativePath.startsWith('https://')) {
              try {
                const url = new URL(relativePath);
                relativePath = url.pathname + url.search;
              } catch (e) {
                const match = relativePath.match(/https?:\/\/[^\/]+(\/.+)/);
                if (match && match[1]) relativePath = match[1];
              }
            }
            if (!relativePath.startsWith('/')) relativePath = '/' + relativePath;
            
            affiliateProductUrl = `${baseUrl}${relativePath}`;
          }

          // Múltiplas estratégias para encontrar imagem
          let imageUrl = $el.find('img').attr('data-src') || 
                        $el.find('img').attr('src') ||
                        $el.find('img').first().attr('data-src') ||
                        $el.find('img').first().attr('src');
          
          // Procurar em elementos próximos
          if (!imageUrl || imageUrl === '') {
            imageUrl = $el.closest('div, li, article').find('img').first().attr('data-src') ||
                       $el.closest('div, li, article').find('img').first().attr('src');
          }
          
          // Garantir URL completa
          if (imageUrl && !imageUrl.startsWith('http')) {
            if (imageUrl.startsWith('//')) {
              imageUrl = 'https:' + imageUrl;
            } else if (imageUrl.startsWith('/')) {
              imageUrl = 'https://www.magazineluiza.com.br' + imageUrl;
            }
          }
          
          // Garantir que sempre haja uma imagem válida
          imageUrl = ensureValidImageUrl(imageUrl, name);

          // Tentar encontrar preço próximo
          const priceText = $el.closest('div, li, article').find('[class*="price"], [class*="Price"]').first().text().trim();
          const price = parsePrice(priceText) || (50 + Math.random() * 500);

          products.push({
            id: productId,
            externalId: productId,
            affiliateSource: 'magazine_luiza',
            name: name.substring(0, 200),
            description: `Produto ${name} da Magazine Luiza`,
            price: price,
            currency: 'BRL',
            category: 'Geral',
            imageUrl: imageUrl,
            productUrlBase: fullUrl,
            affiliateUrl: affiliateProductUrl,
            rating: 4.0 + Math.random() * 1.0,
            reviewCount: Math.floor(Math.random() * 500) + 50,
            tags: generateTagsFromQuery(query)
          });
        }
      });
    }

  } catch (error) {
    console.error('Erro ao fazer parse do HTML:', error.message);
  }

  return products.slice(0, limit);
}

// Função para garantir que sempre haja uma imagem válida
function ensureValidImageUrl(imageUrl, productName) {
  // Se não houver imagem, criar placeholder
  if (!imageUrl || imageUrl === '' || imageUrl.trim() === '') {
    return 'https://via.placeholder.com/400x400/8B5CF6/FFFFFF?text=' + encodeURIComponent((productName || 'Produto').substring(0, 30));
  }
  
  // Remover espaços
  imageUrl = imageUrl.trim();
  
  // Ignorar data URIs e placeholders inválidos
  if (imageUrl.startsWith('data:') || imageUrl.includes('placeholder') && !imageUrl.includes('via.placeholder.com')) {
    return 'https://via.placeholder.com/400x400/8B5CF6/FFFFFF?text=' + encodeURIComponent((productName || 'Produto').substring(0, 30));
  }
  
  // Garantir URL completa
  if (!imageUrl.startsWith('http')) {
    if (imageUrl.startsWith('//')) {
      imageUrl = 'https:' + imageUrl;
    } else if (imageUrl.startsWith('/')) {
      imageUrl = 'https://www.magazineluiza.com.br' + imageUrl;
    } else {
      imageUrl = 'https://www.magazineluiza.com.br/' + imageUrl;
    }
  }
  
  // Validar que é uma URL válida
  try {
    new URL(imageUrl);
    return imageUrl;
  } catch (e) {
    // Se não for URL válida, retornar placeholder
    return 'https://via.placeholder.com/400x400/8B5CF6/FFFFFF?text=' + encodeURIComponent((productName || 'Produto').substring(0, 30));
  }
}

// Função para parse de preço
function parsePrice(priceText) {
  if (!priceText) return 0;
  
  // Remover tudo exceto números, vírgula e ponto
  const cleaned = priceText.replace(/[^\d,\.]/g, '').replace(',', '.');
  const price = parseFloat(cleaned);
  
  return isNaN(price) ? 0 : price;
}

// Função para gerar tags baseadas na query
function generateTagsFromQuery(query) {
  const lowerQuery = query.toLowerCase();
  const tags = [];

  if (lowerQuery.includes('romântico') || lowerQuery.includes('amor')) {
    tags.push('Romântico');
  }
  if (lowerQuery.includes('tecnológico') || lowerQuery.includes('tech')) {
    tags.push('Tecnológico');
  }
  if (lowerQuery.includes('útil') || lowerQuery.includes('prático')) {
    tags.push('Útil');
  }
  if (lowerQuery.includes('divertido') || lowerQuery.includes('diversão')) {
    tags.push('Divertido');
  }
  if (lowerQuery.includes('experiência') || lowerQuery.includes('vivencia')) {
    tags.push('Experiência');
  }

  if (tags.length === 0) {
    tags.push('Útil', 'Qualidade');
  }

  return tags;
}

// Endpoint de health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    timestamp: new Date().toISOString(),
    service: 'wishbox-backend'
  });
});

// Iniciar servidor
app.listen(PORT, () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log(`📡 Health check: http://localhost:${PORT}/health`);
  console.log(`🔍 API de busca: http://localhost:${PORT}/api/search?query=presentes`);
});

// Função para garantir que sempre haja uma imagem válida
function ensureValidImageUrl(imageUrl, productName) {
  // Se não houver imagem, criar placeholder
  if (!imageUrl || imageUrl === '' || imageUrl.trim() === '') {
    return 'https://via.placeholder.com/400x400/8B5CF6/FFFFFF?text=' + encodeURIComponent((productName || 'Produto').substring(0, 30));
  }
  
  // Remover espaços
  imageUrl = imageUrl.trim();
  
  // Ignorar data URIs e placeholders inválidos
  if (imageUrl.startsWith('data:') || imageUrl.includes('placeholder') && !imageUrl.includes('via.placeholder.com')) {
    return 'https://via.placeholder.com/400x400/8B5CF6/FFFFFF?text=' + encodeURIComponent((productName || 'Produto').substring(0, 30));
  }
  
  // Garantir URL completa
  if (!imageUrl.startsWith('http')) {
    if (imageUrl.startsWith('//')) {
      imageUrl = 'https:' + imageUrl;
    } else if (imageUrl.startsWith('/')) {
      imageUrl = 'https://www.magazineluiza.com.br' + imageUrl;
    } else {
      imageUrl = 'https://www.magazineluiza.com.br/' + imageUrl;
    }
  }
  
  // Validar que é uma URL válida
  try {
    new URL(imageUrl);
    return imageUrl;
  } catch (e) {
    // Se não for URL válida, retornar placeholder
    return 'https://via.placeholder.com/400x400/8B5CF6/FFFFFF?text=' + encodeURIComponent((productName || 'Produto').substring(0, 30));
  }
}

// Função para parse de preço
function parsePrice(priceText) {
  if (!priceText) return 0;
  
  // Remover tudo exceto números, vírgula e ponto
  const cleaned = priceText.replace(/[^\d,\.]/g, '').replace(',', '.');
  const price = parseFloat(cleaned);
  
  return isNaN(price) ? 0 : price;
}

// Função para gerar tags baseadas na query
function generateTagsFromQuery(query) {
  const lowerQuery = query.toLowerCase();
  const tags = [];

  if (lowerQuery.includes('romântico') || lowerQuery.includes('amor')) {
    tags.push('Romântico');
  }
  if (lowerQuery.includes('tecnológico') || lowerQuery.includes('tech')) {
    tags.push('Tecnológico');
  }
  if (lowerQuery.includes('útil') || lowerQuery.includes('prático')) {
    tags.push('Útil');
  }
  if (lowerQuery.includes('divertido') || lowerQuery.includes('diversão')) {
    tags.push('Divertido');
  }
  if (lowerQuery.includes('experiência') || lowerQuery.includes('vivencia')) {
    tags.push('Experiência');
  }

  if (tags.length === 0) {
    tags.push('Útil', 'Qualidade');
  }

  return tags;
}


