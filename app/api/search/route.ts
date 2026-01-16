/**
 * API Route Handler para /api/search
 * 
 * Em desenvolvimento local: chama o backend separado (backend/server.js)
 * Em produção no Netlify: redireciona para Netlify Function via netlify.toml
 */

import { NextRequest, NextResponse } from 'next/server';

export async function GET(request: NextRequest) {
  // Apenas em desenvolvimento local - fazer proxy para backend separado
  if (process.env.NODE_ENV === 'development') {
    const searchParams = request.nextUrl.searchParams;
    const query = searchParams.get('query');
    const limit = searchParams.get('limit') || '20';
    const affiliateUrl = searchParams.get('affiliateUrl');

    // URL do backend local (backend/server.js rodando na porta 3001)
    const backendPort = process.env.NEXT_PUBLIC_DEV_PORT || '3001';
    const backendUrl = `http://localhost:${backendPort}/api/search?query=${encodeURIComponent(query || '')}&limit=${limit}${affiliateUrl ? `&affiliateUrl=${encodeURIComponent(affiliateUrl)}` : ''}`;

    try {
      const response = await fetch(backendUrl, {
        method: 'GET',
        headers: {
          'Accept': 'application/json',
        },
      });

      if (!response.ok) {
        return NextResponse.json(
          {
            success: false,
            error: `Backend returned ${response.status}`,
            products: [],
          },
          { status: response.status }
        );
      }

      const data = await response.json();
      return NextResponse.json(data);
    } catch (error: any) {
      console.error('=== API Route: Error proxying to backend:', error);
      return NextResponse.json(
        {
          success: false,
          error: `Erro ao conectar ao backend: ${error.message}`,
          details: 'Verifique se o backend está rodando em http://localhost:3001',
          products: [],
        },
        { status: 500 }
      );
    }
  }

  // Em produção, esta rota não deve ser chamada (usa Netlify Function via redirect)
  return NextResponse.json(
    {
      success: false,
      error: 'Esta rota não está disponível em produção',
      products: [],
    },
    { status: 404 }
  );
}
