export interface Product {
  id: string;
  externalId: string;
  affiliateSource: string;
  name: string;
  description: string;
  price: number;
  currency: string;
  category: string;
  imageUrl: string;
  productUrlBase: string;
  affiliateUrl?: string;
  rating?: number;
  reviewCount?: number;
  tags: string[];
}

export interface GiftSuggestion {
  id: string;
  giftSearchSessionId: string;
  product: Product;
  relevanceScore: number;
  reasonText: string;
  position: number;
}
