import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String userId;
  final String licensePlate;
  final String brand;
  final String model;
  final int year;
  final String color;
  final double fuelEfficiency;
  final DateTime registrationDate;
  final String insuranceNumber;
  final DateTime insuranceExpiry;
  final String? imageUrl;
  final bool isActive;

  VehicleModel({
    required this.id,
    required this.userId,
    required this.licensePlate,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.fuelEfficiency,
    required this.registrationDate,
    required this.insuranceNumber,
    required this.insuranceExpiry,
    this.imageUrl,
    this.isActive = true,
  });

  factory VehicleModel.fromMap(String id, Map<String, dynamic> data) {
    return VehicleModel(
      id: id,
      userId: data['userId'] as String? ?? '',
      licensePlate: data['licensePlate'] as String? ?? '',
      brand: data['brand'] as String? ?? '',
      model: data['model'] as String? ?? '',
      year: (data['year'] as int?) ?? 2020,
      color: data['color'] as String? ?? '',
      fuelEfficiency: (data['fuelEfficiency'] as num?)?.toDouble() ?? 0.0,
      registrationDate: (data['registrationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      insuranceNumber: data['insuranceNumber'] as String? ?? '',
      insuranceExpiry: (data['insuranceExpiry'] as Timestamp?)?.toDate() ?? DateTime.now(),
      imageUrl: data['imageUrl'] as String?,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'licensePlate': licensePlate,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'fuelEfficiency': fuelEfficiency,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'insuranceNumber': insuranceNumber,
      'insuranceExpiry': Timestamp.fromDate(insuranceExpiry),
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }

  String get fullName => '$brand $model ($year)';
}