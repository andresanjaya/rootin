import 'package:flutter/foundation.dart';

/// Represents an authenticated user in Rootin Mobile
@immutable
class AuthUser {
  const AuthUser({required this.id, this.email, this.createdAt});

  final String id;
  final String? email;
  final DateTime? createdAt;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          createdAt == other.createdAt;

  @override
  int get hashCode => Object.hash(id, email, createdAt);

  @override
  String toString() =>
      'AuthUser(id: $id, email: $email, createdAt: $createdAt)';
}
