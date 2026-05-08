enum UserRole { buyer, seller }

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final UserRole role;
  final bool emailVerified;
  final DateTime createdAt;

  // Seller-only fields
  final String? storeName;
  final String? storeDescription;
  final String? profileImageUrl;
  final String? contactInfo;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.emailVerified,
    required this.createdAt,
    this.storeName,
    this.storeDescription,
    this.profileImageUrl,
    this.contactInfo,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'role': role.name,
        'emailVerified': emailVerified,
        'createdAt': createdAt.toIso8601String(),
        'storeName': storeName,
        'storeDescription': storeDescription,
        'profileImageUrl': profileImageUrl,
        'contactInfo': contactInfo,
      };

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) => UserModel(
        uid: uid,
        email: map['email'] as String,
        displayName: map['displayName'] as String,
        role: UserRole.values.firstWhere((r) => r.name == map['role']),
        emailVerified: map['emailVerified'] as bool,
        createdAt: DateTime.parse(map['createdAt'] as String),
        storeName: map['storeName'] as String?,
        storeDescription: map['storeDescription'] as String?,
        profileImageUrl: map['profileImageUrl'] as String?,
        contactInfo: map['contactInfo'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      other is UserModel &&
      uid == other.uid &&
      email == other.email &&
      displayName == other.displayName &&
      role == other.role &&
      emailVerified == other.emailVerified &&
      createdAt == other.createdAt &&
      storeName == other.storeName &&
      storeDescription == other.storeDescription &&
      profileImageUrl == other.profileImageUrl &&
      contactInfo == other.contactInfo;

  @override
  int get hashCode => Object.hash(uid, email, displayName, role, emailVerified,
      createdAt, storeName, storeDescription, profileImageUrl, contactInfo);
}
