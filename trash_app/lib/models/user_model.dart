class UserModel {
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? 'No Name',
      email: json['email'] ?? 'No Email',
      role: json['role'] ?? 'user',
    );
  }
}