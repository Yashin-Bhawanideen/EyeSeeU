import 'package:flutter/material.dart';
import 'package:eye_see_u/models/vehicle_model.dart';
import 'package:eye_see_u/models/vehicle_usage_model.dart';
import 'package:eye_see_u/services/firebase_service.dart';

class VehicleService extends ChangeNotifier {
  final List<VehicleModel> _vehicles = [];
  final List<VehicleUsageModel> _usages = [];
  bool _isLoading = false;

  List<VehicleModel> get vehicles => _vehicles;
  List<VehicleUsageModel> get usages => _usages;
  bool get isLoading => _isLoading;

  // Stream for real-time vehicle updates
  Stream<List<VehicleModel>> get vehiclesStream {
    if (FirebaseService.currentUserId == null) {
      return Stream.value([]);
    }
    
    return FirebaseService.vehicles
        .where('userId', isEqualTo: FirebaseService.currentUserId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
                if (data != null) {
                  return VehicleModel.fromMap(doc.id, data);
                }
                throw Exception('Vehicle data is null for document ${doc.id}');
              })
              .toList();
        });
  }

  // Stream for vehicle usages - FIXED VERSION
  Stream<List<VehicleUsageModel>> getUsagesStream(String vehicleId) {
    if (vehicleId.isEmpty || FirebaseService.currentUserId == null) {
      return Stream.value([]);
    }
    
    // Return a stream that always emits data
    return FirebaseService.vehicleUsages
        .where('vehicleId', isEqualTo: vehicleId)
        .orderBy('usageDate', descending: true)
        .snapshots()
        .map((snapshot) {
          final List<VehicleUsageModel> usageList = [];
          for (var doc in snapshot.docs) {
            try {
              final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
              if (data != null) {
                final usage = VehicleUsageModel.fromMap(doc.id, data);
                usageList.add(usage);
              }
            } catch (e) {
              print('Error parsing usage: $e');
            }
          }
          print('Found ${usageList.length} usage records for vehicle $vehicleId');
          return usageList;
        });
  }

  Future<bool> addVehicle(VehicleModel vehicle) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = FirebaseService.vehicles.doc();
      final vehicleWithId = VehicleModel(
        id: docRef.id,
        userId: vehicle.userId,
        licensePlate: vehicle.licensePlate,
        brand: vehicle.brand,
        model: vehicle.model,
        year: vehicle.year,
        color: vehicle.color,
        fuelEfficiency: vehicle.fuelEfficiency,
        registrationDate: vehicle.registrationDate,
        insuranceNumber: vehicle.insuranceNumber,
        insuranceExpiry: vehicle.insuranceExpiry,
        imageUrl: vehicle.imageUrl,
        isActive: vehicle.isActive,
      );
      
      await docRef.set(vehicleWithId.toMap());
      
      _vehicles.add(vehicleWithId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error adding vehicle: $e');
      return false;
    }
  }

  Future<bool> updateVehicle(VehicleModel vehicle) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseService.vehicles.doc(vehicle.id).update(vehicle.toMap());
      
      final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        _vehicles[index] = vehicle;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error updating vehicle: $e');
      return false;
    }
  }

  Future<bool> deleteVehicle(String vehicleId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // First delete all usage records for this vehicle
      final usageSnapshot = await FirebaseService.vehicleUsages
          .where('vehicleId', isEqualTo: vehicleId)
          .get();
      
      for (final doc in usageSnapshot.docs) {
        await FirebaseService.vehicleUsages.doc(doc.id).delete();
      }
      
      // Then delete the vehicle
      await FirebaseService.vehicles.doc(vehicleId).delete();
      
      _vehicles.removeWhere((v) => v.id == vehicleId);
      _usages.removeWhere((u) => u.vehicleId == vehicleId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error deleting vehicle: $e');
      return false;
    }
  }

  Future<bool> addUsage(VehicleUsageModel usage) async {
    _isLoading = true;
    notifyListeners();

    try {
      final docRef = FirebaseService.vehicleUsages.doc();
      final usageWithId = VehicleUsageModel(
        id: docRef.id,
        vehicleId: usage.vehicleId,
        userId: usage.userId,
        usageDate: usage.usageDate,
        odometer: usage.odometer,
        fuelUsed: usage.fuelUsed,
        purpose: usage.purpose,
        driverName: usage.driverName,
        notes: usage.notes,
        createdAt: usage.createdAt,
      );
      
      await docRef.set(usageWithId.toMap());
      
      _usages.add(usageWithId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error adding usage: $e');
      return false;
    }
  }

  void clearData() {
    _vehicles.clear();
    _usages.clear();
    notifyListeners();
  }
}