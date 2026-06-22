import 'package:cloud_firestore/cloud_firestore.dart';
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final DateTime createdAt;
  final String companyName;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.createdAt,
    required this.companyName,
  });

  // Factory method to create UserModel from Firestore data
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      companyName: data['companyName'] as String? ?? '',
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'companyName': companyName,
    };
  }

  // Copy with method for updating
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    DateTime? createdAt,
    String? companyName,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      companyName: companyName ?? this.companyName,
    );
  }
}