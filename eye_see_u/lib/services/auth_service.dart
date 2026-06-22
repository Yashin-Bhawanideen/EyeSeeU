import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eye_see_u/models/user_model.dart';
import 'package:eye_see_u/services/firebase_service.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUserModel;
  bool _isLoading = false;

  UserModel? get currentUserModel => _currentUserModel;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => FirebaseService.currentUser != null;

  AuthService() {
    _init();
  }

  void _init() {
    FirebaseService.auth.authStateChanges().listen((User? user) async {
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _currentUserModel = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final doc = await FirebaseService.users.doc(userId).get();
      if (doc.exists) {
        // Fixed: Get data and explicitly cast to Map<String, dynamic>
        final Map<String, dynamic>? data = doc.data();
        if (data != null) {
          _currentUserModel = UserModel.fromMap(doc.id, data);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String companyName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Create user in Firebase Auth
      final userCredential = await FirebaseService.auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Create user document in Firestore
      final userModel = UserModel(
        id: userCredential.user!.uid,
        email: email,
        fullName: fullName,
        phoneNumber: phoneNumber,
        createdAt: DateTime.now(),
        companyName: companyName,
      );

      await FirebaseService.users
          .doc(userCredential.user!.uid)
          .set(userModel.toMap());

      _currentUserModel = userModel;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Registration failed: $e');
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseService.auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await FirebaseService.auth.signOut();
      _currentUserModel = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}