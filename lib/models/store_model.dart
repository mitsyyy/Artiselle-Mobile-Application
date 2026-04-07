class StoreModel {
  final String uid;
  final String storeName;
  final String description;
  final String? profileImageUrl;
  final String? contactInfo;

  const StoreModel({
    required this.uid,
    required this.storeName,
    required this.description,
    this.profileImageUrl,
    this.contactInfo,
  });
}
