import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eye_see_u/models/vehicle_model.dart';
import 'package:eye_see_u/services/auth_service.dart';
import 'package:eye_see_u/services/firebase_service.dart';
import 'package:eye_see_u/services/vehicle_service.dart';
import 'package:eye_see_u/widgets/custom_button.dart';
import 'package:eye_see_u/widgets/custom_text_field.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _licensePlateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _fuelEfficiencyController = TextEditingController();
  final _insuranceNumberController = TextEditingController();
  final _insuranceExpiryController = TextEditingController();
  
  DateTime _registrationDate = DateTime.now();
  DateTime _insuranceExpiry = DateTime.now();

  @override
  void dispose() {
    _licensePlateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _fuelEfficiencyController.dispose();
    _insuranceNumberController.dispose();
    _insuranceExpiryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isRegistration) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isRegistration ? _registrationDate : _insuranceExpiry,
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      setState(() {
        if (isRegistration) {
          _registrationDate = picked;
        } else {
          _insuranceExpiry = picked;
        }
      });
    }
  }

  Future<void> _saveVehicle() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Get User ID - try multiple sources
    final String? userId = Provider.of<AuthService>(context, listen: false).currentUserModel?.id;
    final String? firebaseUserId = FirebaseService.currentUserId;
    final String? finalUserId = userId ?? firebaseUserId;
    
    if (finalUserId == null || finalUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not logged in. Please login again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final vehicleService = Provider.of<VehicleService>(context, listen: false);

    // Parse year with error handling
    int year;
    try {
      year = int.parse(_yearController.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid year'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Parse fuel efficiency with error handling
    double fuelEfficiency;
    try {
      fuelEfficiency = double.parse(_fuelEfficiencyController.text);
      if (fuelEfficiency <= 0) {
        throw Exception();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid fuel efficiency'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final vehicle = VehicleModel(
      id: '',
      userId: finalUserId,
      licensePlate: _licensePlateController.text.trim(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      year: year,
      color: _colorController.text.trim(),
      fuelEfficiency: fuelEfficiency,
      registrationDate: _registrationDate,
      insuranceNumber: _insuranceNumberController.text.trim(),
      insuranceExpiry: _insuranceExpiry,
      isActive: true,
    );

    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saving vehicle...'),
        duration: Duration(seconds: 1),
      ),
    );

    final success = await vehicleService.addVehicle(vehicle);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Vehicle added successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add vehicle. Please try again.'),
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
                        // Logo and Title
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100,
                                  height: 100,
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
                          child: Text(
                            'Add Vehicle',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
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
                                        Icons.add_circle_outline,
                                        size: 60,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Add New Vehicle',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Enter the details of your vehicle',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              // License Plate Field
                              CustomTextField(
                                controller: _licensePlateController,
                                label: 'License Plate',
                                prefixIcon: Icons.confirmation_number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter license plate';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Brand Field
                              CustomTextField(
                                controller: _brandController,
                                label: 'Brand',
                                prefixIcon: Icons.branding_watermark,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter brand';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Model Field
                              CustomTextField(
                                controller: _modelController,
                                label: 'Model',
                                prefixIcon: Icons.model_training,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter model';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Year Field
                              CustomTextField(
                                controller: _yearController,
                                label: 'Year',
                                prefixIcon: Icons.calendar_today,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter year';
                                  }
                                  final year = int.tryParse(value);
                                  if (year == null || year < 2000 || year > DateTime.now().year + 1) {
                                    return 'Please enter a valid year';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Color Field
                              CustomTextField(
                                controller: _colorController,
                                label: 'Color',
                                prefixIcon: Icons.color_lens,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter color';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Fuel Efficiency Field
                              CustomTextField(
                                controller: _fuelEfficiencyController,
                                label: 'Fuel Efficiency (km/l)',
                                prefixIcon: Icons.speed,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter fuel efficiency';
                                  }
                                  final efficiency = double.tryParse(value);
                                  if (efficiency == null || efficiency <= 0) {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Registration Date Picker
                              GestureDetector(
                                onTap: () => _selectDate(context, true),
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
                                          'Registration Date: ${_registrationDate.toString().split(' ')[0]}',
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
                              // Insurance Number Field
                              CustomTextField(
                                controller: _insuranceNumberController,
                                label: 'Insurance Number',
                                prefixIcon: Icons.assignment,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter insurance number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              // Insurance Expiry Picker
                              GestureDetector(
                                onTap: () => _selectDate(context, false),
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
                                          'Insurance Expiry: ${_insuranceExpiry.toString().split(' ')[0]}',
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
                              const SizedBox(height: 32),
                              // Save Button
                              CustomButton(
                                text: 'SAVE VEHICLE',
                                onPressed: _saveVehicle,
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