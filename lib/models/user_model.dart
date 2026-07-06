/// Tipos de usuário do aplicativo
enum UserType { cliente, afiliado }

class UserModel {
  final String id;
  final String name;
  final String email;
  final bool isEmailVerified;
  final bool isAffiliate;
  final UserType userType;
  final DateTime createdAt;
  final String? bio;
  final String? avatarColor; // hex color for avatar

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isEmailVerified = false,
    this.isAffiliate = false,
    this.userType = UserType.cliente,
    required this.createdAt,
    this.bio,
    this.avatarColor,
  });

  bool get isAffiliateUser =>
      isAffiliate || userType == UserType.afiliado;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'isEmailVerified': isEmailVerified,
        'isAffiliate': isAffiliate,
        'userType': userType.name,
        'createdAt': createdAt.toIso8601String(),
        'bio': bio,
        'avatarColor': avatarColor,
      };

  factory UserModel.fromJson(Map<String, dynamic> map) => UserModel(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        isEmailVerified: map['isEmailVerified'] == true,
        isAffiliate: map['isAffiliate'] == true,
        userType: map['userType'] == 'afiliado'
            ? UserType.afiliado
            : UserType.cliente,
        createdAt:
            DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
                DateTime.now(),
        bio: map['bio']?.toString(),
        avatarColor: map['avatarColor']?.toString(),
      );

  UserModel copyWith({
    String? name,
    String? email,
    bool? isEmailVerified,
    bool? isAffiliate,
    UserType? userType,
    String? bio,
    String? avatarColor,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email ?? this.email,
        isEmailVerified: isEmailVerified ?? this.isEmailVerified,
        isAffiliate: isAffiliate ?? this.isAffiliate,
        userType: userType ?? this.userType,
        createdAt: createdAt,
        bio: bio ?? this.bio,
        avatarColor: avatarColor ?? this.avatarColor,
      );
}
