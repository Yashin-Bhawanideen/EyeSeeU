import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleUsageModel {
  final String id;
  final String vehicleId;
  final String userId;
  final DateTime usageDate; // Single date instead of start/end
  final double odometer; // Just one odometer reading
  final double fuelUsed;
  final String purpose;
  final String? driverName;
  final String? notes;
  final DateTime createdAt;

  VehicleUsageModel({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.usageDate,
    required this.odometer,
    required this.fuelUsed,
    required this.purpose,
    this.driverName,
    this.notes,
    required this.createdAt,
  });

  factory VehicleUsageModel.fromMap(String id, Map<String, dynamic> data) {
    return VehicleUsageModel(
      id: id,
      vehicleId: data['vehicleId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      usageDate: (data['usageDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      odometer: (data['odometer'] as num?)?.toDouble() ?? 0.0,
      fuelUsed: (data['fuelUsed'] as num?)?.toDouble() ?? 0.0,
      purpose: data['purpose'] as String? ?? '',
      driverName: data['driverName'] as String?,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'userId': userId,
      'usageDate': Timestamp.fromDate(usageDate),
      'odometer': odometer,
      'fuelUsed': fuelUsed,
      'purpose': purpose,
      'driverName': driverName,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}