#!/bin/bash

echo "🧪 Testando Backend..."
echo ""

# Verificar se o backend está rodando
echo "1. Testando health check..."
curl -s http://localhost:3000/health | jq '.' || echo "❌ Backend não está rodando. Execute: cd backend && npm start"
echo ""

# Testar busca de produtos
echo "2. Testando busca de produtos..."
curl -s "http://localhost:3000/api/search?query=presentes&limit=3" | jq '.count, .products[0].name, .products[0].price' || echo "❌ Erro na busca"
echo ""

echo "✅ Testes concluídos!"

