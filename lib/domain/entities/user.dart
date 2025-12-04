class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final List<String> preferredGiftTypes;
  final List<String> favoriteStores;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.preferredGiftTypes,
    required this.favoriteStores,
  });
}



