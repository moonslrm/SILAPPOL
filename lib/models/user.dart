class User {
  const User({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.nim,
    this.roleId,
    this.roleName,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
    this.role = 'penyewa',
  });

  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? nim;
  final int? roleId;
  final String? roleName;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String role;

  bool get isAdmin => role.toLowerCase() == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    final roleValue = (json['role_name'] ?? json['role'] ?? 'penyewa')
        .toString();

    return User(
      id: json['id'] as int?,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: json['phone'] as String?,
      nim: json['nim'] as String?,
      roleId: json['role_id'] as int?,
      roleName: json['role_name'] as String?,
      emailVerifiedAt: json['email_verified_at'] == null
          ? null
          : DateTime.tryParse(json['email_verified_at'].toString()),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.tryParse(json['updated_at'].toString()),
      role: roleValue,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'nim': nim,
      'role_id': roleId,
      'role_name': roleName,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'role': role,
    };
  }
}
