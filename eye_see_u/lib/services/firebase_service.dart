import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Authentication
  static FirebaseAuth get auth => _auth;
  
  // Firestore Collections
  static CollectionReference<Map<String, dynamic>> get users => _firestore.collection('users');
  static CollectionReference<Map<String, dynamic>> get vehicles => _firestore.collection('vehicles');
  static CollectionReference<Map<String, dynamic>> get vehicleUsages => _firestore.collection('vehicle_usages');

  // Current User
  static User? get currentUser => _auth.currentUser;
  static String? get currentUserId => _auth.currentUser?.uid;

  // Helper method to check if user is logged in
  static bool get isLoggedIn => _auth.currentUser != null;

  //get firestore instance
  static FirebaseFirestore get firestore => _firestore;
}