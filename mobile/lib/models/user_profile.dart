class UserProfile {
  final int id;
  final String fullName;
  final String email;
  final bool isActive;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
