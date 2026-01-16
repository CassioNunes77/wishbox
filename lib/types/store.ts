export interface AffiliateStore {
  id: string;
  name: string;
  displayName: string;
  affiliateUrlTemplate: string;
  apiEndpoint?: string;
  isActive: boolean;
  createdAt: string;
  updatedAt?: string;
}
