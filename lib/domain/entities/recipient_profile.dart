class RecipientProfile {
  final String id;
  final String userId;
  final bool isSelfGift;
  final String? relationType;
  final String? ageRange;
  final String? gender;
  final String? occasion;
  final String descriptionRaw;
  final List<String> interests;
  final List<String> personalityTags;
  final String giftStylePriority;
  final List<String> constraints;
  final DateTime createdAt;

  RecipientProfile({
    required this.id,
    required this.userId,
    required this.isSelfGift,
    this.relationType,
    this.ageRange,
    this.gender,
    this.occasion,
    required this.descriptionRaw,
    required this.interests,
    required this.personalityTags,
    required this.giftStylePriority,
    required this.constraints,
    required this.createdAt,
  });
}



