class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? companyName;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.companyName,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String? _str(dynamic v) => v is String ? v : null;
    return UserModel(
      id: json['id'] ?? 0,
      name: _str(json['name']) ?? '',
      email: _str(json['email']) ?? _str(json['login']) ?? '',
      phone: _str(json['phone']),
      companyName: _str(json['company_name']),
      avatarUrl: _str(json['avatar_128']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'company_name': companyName,
      };
}
