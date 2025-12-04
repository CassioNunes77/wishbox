class Product {
  final String id;
  final String externalId;
  final String affiliateSource;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String category;
  final String imageUrl;
  final String productUrlBase;
  final String? affiliateUrl;
  final double? rating;
  final int? reviewCount;
  final List<String> tags;

  Product({
    required this.id,
    required this.externalId,
    required this.affiliateSource,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.category,
    required this.imageUrl,
    required this.productUrlBase,
    this.affiliateUrl,
    this.rating,
    this.reviewCount,
    required this.tags,
  });
}



