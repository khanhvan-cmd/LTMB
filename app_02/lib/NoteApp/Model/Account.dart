import 'dart:convert';

class Account {
  int? id;
  int userId;
  String username;
  String password;
  String status;
  String lastLogin;
  String createdAt;

  Account({
    this.id,
    required this.userId,
    required this.username,
    required this.password,
    required this.status,
    required this.lastLogin,
    required this.createdAt,
  });

  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'],
      userId: map['userId'],
      username: map['username'],
      password: map['password'],
      status: map['status'],
      lastLogin: map['lastLogin'],
      createdAt: map['createdAt'],
    );
  }

  factory Account.fromJSON(String source) {
    return Account.fromMap(jsonDecode(source));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'username': username,
      'password': password,
      'status': status,
      'lastLogin': lastLogin,
      'createdAt': createdAt,
    };
  }

  String toJSON() {
    return jsonEncode(toMap());
  }

  Account copyWith({
    int? id,
    int? userId,
    String? username,
    String? password,
    String? status,
    String? lastLogin,
    String? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      password: password ?? this.password,
      status: status ?? this.status,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Account(id: $id, userId: $userId, username: $username, status: $status, lastLogin: $lastLogin, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account &&
        other.id == id &&
        other.userId == userId &&
        other.username == username &&
        other.password == password &&
        other.status == status &&
        other.lastLogin == lastLogin &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    userId.hashCode ^
    username.hashCode ^
    password.hashCode ^
    status.hashCode ^
    lastLogin.hashCode ^
    createdAt.hashCode;
  }
}