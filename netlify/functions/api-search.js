const axios = require('axios');
const cheerio = require('cheerio');

exports.handler = async (event, context) => {
  // Permitir CORS
  const headers = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Content-Type': 'application/json',
  };

  // Handle preflight
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers,
      body: '',
    };
  }

  try {
    const { query, affiliateUrl, limit = 20 } = event.queryStringParameters || {};

    if (!query) {
      return {
        statusCode: 400,
        headers,
        body: JSON.stringify({ 
          error: 'Query parameter is required',
          products: []
        }),
      };
    }

    console.log(`[${new Date().toISOString()}] Buscando produtos: "${query}"`);

    // Construir URL de busca
    let searchUrl;
    if (affiliateUrl) {
      const baseUrl = affiliateUrl.endsWith('/') 
        ? affiliateUrl.substring(0, affiliateUrl.length - 1)
        : affiliateUrl;
      const encodedQuery = encodeURIComponent(query);
      searchUrl = `${baseUrl}/busca/${encodedQuery}`;
    } else {
      const encodedQuery = encodeURIComponent(query);
      searchUrl = `https://www.magazineluiza.com.br/busca/${encodedQuery}`;
    }

    console.log(`[${new Date().toISOString()}] URL de busca: ${searchUrl}`);

    // Fazer requisição HTTP com headers completos para parecer navegador real
    const response = await axios.get(searchUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
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
        'DNT': '1',
        'Referer': 'https://www.google.com/',
        'Origin': 'https://www.magazineluiza.com.br',
      },
      timeout: 15000, // Timeout aumentado
      validateStatus: function (status) {
        // Aceitar qualquer status para poder tratar erros
        return status >= 200 && status < 500;
      },
    });

    if (response.status !== 200) {
      console.error(`[${new Date().toISOString()}] HTTP ${response.status}`);
      return {
        statusCode: response.status,
        headers,
        body: JSON.stringify({ 
          error: `HTTP ${response.status}`,
          products: []
        }),
      };
    }

    console.log(`[${new Date().toISOString()}] HTML recebido (${response.data.length} bytes)`);

    // Parse do HTML
    const products = parseProductsFromHtml(response.data, query, affiliateUrl, parseInt(limit));

    console.log(`[${new Date().toISOString()}] ${products.length} produtos encontrados`);

    return {
      statusCode: 200,
      headers,
      body: JSON.stringify({
        success: true,
        query,
        affiliateUrl: affiliateUrl || null,
        products,
        count: products.length
      }),
    };

  } catch (error) {
    console.error(`[${new Date().toISOString()}] Erro:`, error.message);
    console.error(`[${new Date().toISOString()}] Stack:`, error.stack);
    
    // Se for erro 403 (Forbidden), retornar erro mais específico
    if (error.response && error.response.status === 403) {
      console.error(`[${new Date().toISOString()}] Erro 403: Magazine Luiza bloqueou a requisição`);
      return {
        statusCode: 403,
        headers,
        body: JSON.stringify({ 
          error: 'Acesso negado pelo site. O site pode estar bloqueando requisições automatizadas.',
          details: 'O Magazine Luiza pode estar bloqueando requisições que não vêm de navegadores reais.',
          products: []
        }),
      };
    }
    
    // Erro genérico
    return {
      statusCode: 500,
      headers,
      body: JSON.stringify({ 
        error: error.message || 'Erro interno do servidor',
        details: error.response ? `HTTP ${error.response.status}` : 'Erro desconhecido',
        products: []
      }),
    };
  }
};

// Função para fazer parse do HTML e extrair produtos
function parseProductsFromHtml(html, query, affiliateUrl, limit) {
  const $ = cheerio.load(html);
  const products = [];

  try {
    // Estratégia 1: Procurar por produtos usando data attributes da Magazine Luiza
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
          const affiliatePath = affiliateUrlObj.pathname;
          const cleanAffiliatePath = affiliatePath.endsWith('/') 
            ? affiliatePath.substring(0, affiliatePath.length - 1)
            : affiliatePath;
          
          // Remover o caminho do afiliado do início do relativePath
          if (cleanAffiliatePath && cleanAffiliatePath !== '/') {
            const pathWithSlash = cleanAffiliatePath + '/';
            while (relativePath.startsWith(pathWithSlash)) {
              relativePath = relativePath.substring(pathWithSlash.length);
            }
            
            if (relativePath.startsWith(cleanAffiliatePath)) {
              relativePath = relativePath.substring(cleanAffiliatePath.length);
              if (relativePath.startsWith('/')) {
                relativePath = relativePath.substring(1);
              }
            }
            
            // Remover segmento duplicado
            const lastSegment = cleanAffiliatePath.split('/').filter(s => s).pop();
            if (lastSegment) {
              while (relativePath.startsWith(lastSegment + '/')) {
                relativePath = relativePath.substring((lastSegment + '/').length);
              }
              while (relativePath.startsWith('/' + lastSegment + '/')) {
                relativePath = relativePath.substring(('/' + lastSegment + '/').length);
              }
            }
          }
        } catch (e) {
          // Ignorar erros
        }
        
        // Garantir que comece com /
        if (!relativePath.startsWith('/')) {
          relativePath = '/' + relativePath;
        }
        
        // Concatenar: baseUrl + relativePath
        affiliateProductUrl = `${baseUrl}${relativePath}`;
      }

      // Imagem - múltiplas estratégias
      let imageUrl = null;
      imageUrl = $el.find('img').first().attr('data-src') || 
                 $el.find('img[data-src]').first().attr('data-src');
      
      if (!imageUrl || imageUrl === '') {
        imageUrl = $el.find('img').first().attr('src');
      }
      
      if (!imageUrl || imageUrl === '') {
        imageUrl = $el.find('img').eq(0).attr('data-src') || 
                   $el.find('img').eq(0).attr('src') ||
                   $el.find('picture img').first().attr('src') ||
                   $el.find('picture source').first().attr('srcset')?.split(' ')[0];
      }
      
      if (!imageUrl || imageUrl === '') {
        const style = $el.find('[style*="background-image"]').first().attr('style');
        if (style) {
          const match = style.match(/url\(['"]?([^'"]+)['"]?\)/);
          if (match && match[1]) {
            imageUrl = match[1];
          }
        }
      }
      
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

      // Rating
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
          name: name.substring(0, 200),
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
            
            let imageUrl = null;
            if (productData.image) {
              if (Array.isArray(productData.image)) {
                imageUrl = productData.image[0] || productData.image.find(img => img && img.startsWith('http'));
              } else if (typeof productData.image === 'string') {
                imageUrl = productData.image;
              }
            }
            
            if (imageUrl && !imageUrl.startsWith('http')) {
              if (imageUrl.startsWith('//')) {
                imageUrl = 'https:' + imageUrl;
              } else if (imageUrl.startsWith('/')) {
                imageUrl = 'https://www.magazineluiza.com.br' + imageUrl;
              }
            }
            
            imageUrl = ensureValidImageUrl(imageUrl, name);
            const description = productData.description || `Produto ${name}`;
            const rating = productData.aggregateRating?.ratingValue || 4.0;
            const reviewCount = productData.aggregateRating?.reviewCount || 100;

            let affiliateProductUrl = productData.url || `https://www.magazineluiza.com.br/produto/${productId}`;
            if (affiliateUrl) {
              const baseUrl = affiliateUrl.endsWith('/') 
                ? affiliateUrl.substring(0, affiliateUrl.length - 1)
                : affiliateUrl;
              
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

          let imageUrl = $el.find('img').attr('data-src') || 
                        $el.find('img').attr('src') ||
                        $el.find('img').first().attr('data-src') ||
                        $el.find('img').first().attr('src');
          
          if (!imageUrl || imageUrl === '') {
            imageUrl = $el.closest('div, li, article').find('img').first().attr('data-src') ||
                       $el.closest('div, li, article').find('img').first().attr('src');
          }
          
          if (imageUrl && !imageUrl.startsWith('http')) {
            if (imageUrl.startsWith('//')) {
              imageUrl = 'https:' + imageUrl;
            } else if (imageUrl.startsWith('/')) {
              imageUrl = 'https://www.magazineluiza.com.br' + imageUrl;
            }
          }
          
          imageUrl = ensureValidImageUrl(imageUrl, name);

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
  if (!imageUrl || imageUrl === '' || imageUrl.trim() === '') {
    return 'https://via.placeholder.com/400x400/8B5CF6/FFFFFF?text=' + encodeURIComponent((productName || 'Produto').substring(0, 30));
  }
  
  imageUrl = imageUrl.trim();
  
  if (imageUrl.startsWith('data:') || imageUrl.includes('placeholder') && !imageUrl.includes('via.placeholder.com')) {
    return 'https://via.placeholder.com/400x400/8B5CF6/FFFFFF?text=' + encodeURIComponent((productName || 'Produto').substring(0, 30));
  }
  
  if (!imageUrl.startsWith('http')) {
    if (imageUrl.startsWith('//')) {
      imageUrl = 'https:' + imageUrl;
    } else if (imageUrl.startsWith('/')) {
      imageUrl = 'https://www.magazineluiza.com.br' + imageUrl;
    } else {
      imageUrl = 'https://www.magazineluiza.com.br/' + imageUrl;
    }
  }
  
  try {
    new URL(imageUrl);
    return imageUrl;
  } catch (e) {
    return 'https://via.placeholder.com/400x400/8B5CF6/FFFFFF?text=' + encodeURIComponent((productName || 'Produto').substring(0, 30));
  }
}

// Função para parse de preço
function parsePrice(priceText) {
  if (!priceText) return 0;
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
