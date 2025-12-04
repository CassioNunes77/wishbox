import 'recipient_profile.dart';

class GiftSearchSession {
  final String id;
  final String userId;
  final RecipientProfile recipientProfile;
  final double priceMin;
  final double priceMax;
  final List<String> preferredStores;
  final DateTime createdAt;

  GiftSearchSession({
    required this.id,
    required this.userId,
    required this.recipientProfile,
    required this.priceMin,
    required this.priceMax,
    required this.preferredStores,
    required this.createdAt,
  });
}



