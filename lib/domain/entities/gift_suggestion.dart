import 'product.dart';

class GiftSuggestion {
  final String id;
  final String giftSearchSessionId;
  final Product product;
  final double relevanceScore;
  final String reasonText;
  final int position;

  GiftSuggestion({
    required this.id,
    required this.giftSearchSessionId,
    required this.product,
    required this.relevanceScore,
    required this.reasonText,
    required this.position,
  });
}



