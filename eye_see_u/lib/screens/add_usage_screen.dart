import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eye_see_u/models/vehicle_model.dart';
import 'package:eye_see_u/models/vehicle_usage_model.dart';
// import 'package:eye_see_u/services/auth_service.dart';
import 'package:eye_see_u/services/firebase_service.dart';
import 'package:eye_see_u/services/vehicle_service.dart';
import 'package:eye_see_u/widgets/custom_button.dart';
import 'package:eye_see_u/widgets/custom_text_field.dart';

class AddUsageScreen extends StatefulWidget {
  final VehicleModel vehicle;

  const AddUsageScreen({super.key, required this.vehicle});

  @override
  State<AddUsageScreen> createState() => _AddUsageScreenState();
}

class _AddUsageScreenState extends State<AddUsageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _fuelUsedController = TextEditingController();
  final _purposeController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _usageDate = DateTime.now();

  @override
  void dispose() {
    _odometerController.dispose();
    _fuelUsedController.dispose();
    _purposeController.dispose();
    _driverNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _usageDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (picked != null) {
      setState(() {
        _usageDate = picked;
      });
    }
  }

  Future<void> _saveUsage() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Get User ID directly from Firebase Auth
    final String? userId = FirebaseService.currentUserId;
    
    print('Current User ID from Firebase: $userId'); // Debug print
    
    if (userId == null || userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Parse odometer
    double odometer;
    try {
      odometer = double.parse(_odometerController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid odometer reading'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Parse fuel used
    double fuelUsed;
    try {
      fuelUsed = double.parse(_fuelUsedController.text);
      if (fuelUsed <= 0) {
        throw Exception('Fuel must be greater than 0');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid fuel amount (greater than 0)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get vehicle service
    final vehicleService = Provider.of<VehicleService>(context, listen: false);

    // Create usage object
    final usage = VehicleUsageModel(
      id: '',
      vehicleId: widget.vehicle.id,
      userId: userId, // Now using Firebase UID directly
      usageDate: _usageDate,
      odometer: odometer,
      fuelUsed: fuelUsed,
      purpose: _purposeController.text.trim(),
      driverName: _driverNameController.text.trim().isEmpty
          ? null
          : _driverNameController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving trip record...'),
        duration: Duration(seconds: 1),
      ),
    );

    // Save to database
    final success = await vehicleService.addUsage(usage);
    
    if (mounted) {
      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Trip record added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Navigate back to vehicle details screen
        Navigator.pop(context, true);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add trip record. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // Back Button
                        IconButton(
                          icon: const Icon(Icons.arrow_back, size: 28),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(width: 12),
                        // Logo
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 55,
                                  height: 55,
                                  color: Colors.blue.shade100,
                                  child: Icon(
                                    Icons.directions_car,
                                    size: 30,
                                    color: Colors.blue.shade700,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Add Trip Record',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              Text(
                                widget.vehicle.fullName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Form Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Title Section
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.trip_origin,
                                        size: 60,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Record Trip',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Enter trip details for ${widget.vehicle.fullName}',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Purpose Field
                              CustomTextField(
                                controller: _purposeController,
                                label: 'Purpose of Trip',
                                prefixIcon: Icons.assignment,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter purpose';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Driver Name Field
                              CustomTextField(
                                controller: _driverNameController,
                                label: 'Driver Name (Optional)',
                                prefixIcon: Icons.person,
                              ),
                              const SizedBox(height: 16),
                              
                              // Date Picker
                              GestureDetector(
                                onTap: () => _selectDate(context),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.blue.shade700),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Trip Date: ${_usageDate.toString().split(' ')[0]}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Odometer Field
                              CustomTextField(
                                controller: _odometerController,
                                label: 'Odometer Reading (km)',
                                prefixIcon: Icons.speed,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter odometer reading';
                                  }
                                  final odometer = double.tryParse(value);
                                  if (odometer == null || odometer < 0) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Fuel Used Field
                              CustomTextField(
                                controller: _fuelUsedController,
                                label: 'Fuel Used (liters)',
                                prefixIcon: Icons.local_gas_station,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter fuel used';
                                  }
                                  final fuel = double.tryParse(value);
                                  if (fuel == null || fuel <= 0) {
                                    return 'Please enter a valid amount';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              
                              // Notes Field
                              CustomTextField(
                                controller: _notesController,
                                label: 'Notes (Optional)',
                                prefixIcon: Icons.note,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 32),
                              
                              // Save Button
                              CustomButton(
                                text: 'SAVE TRIP RECORD',
                                onPressed: _saveUsage,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}