class UserModel {
  final String name;
  final String email;
  final String role;
  final double balance;

  UserModel({
    required this.name,
    required this.email,
    required this.role,
    required this.balance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? 'No Name',
      email: json['email'] ?? 'No Email',
      role: json['role'] ?? 'user',
      balance: (json['balance'] as num? ?? 0).toDouble(),
    );
  }
}