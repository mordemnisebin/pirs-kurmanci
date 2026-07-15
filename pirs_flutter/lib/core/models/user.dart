/// Reprezanteya bikarhênerê di navê appê de.
class UserProfile {
  const UserProfile({
    required this.id,
    required this.nickname,
    required this.email,
    this.avatarUrl,
    this.isGuest = false,
  });

  final String id;
  final String nickname;
  final String email;
  final String? avatarUrl;
  final bool isGuest;

  factory UserProfile.guest() => const UserProfile(
        id: 'guest',
        nickname: 'Mêvan',
        email: 'guest@pirs.app',
        isGuest: true,
      );

  UserProfile copyWith({
    String? id,
    String? nickname,
    String? email,
    String? avatarUrl,
    bool? isGuest,
  }) {
    return UserProfile(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isGuest: isGuest ?? this.isGuest,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'email': email,
        'avatarUrl': avatarUrl,
        'isGuest': isGuest,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      isGuest: json['isGuest'] as bool? ?? false,
    );
  }

}
