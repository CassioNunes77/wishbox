export interface SearchParams {
  query: string;
  isSelfGift?: boolean;
  minPrice?: number;
  maxPrice?: number;
  giftTypes?: string[];
}

export interface GiftProfile {
  relationType?: string;
  ageRange?: string;
  gender?: string;
  occasion?: string;
  interests?: string[];
  budget?: {
    min: number;
    max: number;
  };
}
