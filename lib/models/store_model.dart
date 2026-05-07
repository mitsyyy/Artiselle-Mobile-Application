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

  Map<String, dynamic> toMap() => {
        'storeName': storeName,
        'description': description,
        'profileImageUrl': profileImageUrl,
        'contactInfo': contactInfo,
      };

  factory StoreModel.fromMap(String uid, Map<String, dynamic> map) =>
      StoreModel(
        uid: uid,
        storeName: map['storeName'] as String? ?? '',
        description: map['description'] as String? ?? '',
        profileImageUrl: map['profileImageUrl'] as String?,
        contactInfo: map['contactInfo'] as String?,
      );
}
