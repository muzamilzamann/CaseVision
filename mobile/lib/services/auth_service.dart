import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _tokenKey = 'access_token';
  static const String _userKey = 'user_profile';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      final rawData = doc.data() ?? {
        'full_name': credential.user!.displayName ?? '',
        'email': email,
      };

      // Strip non-JSON-safe types (like Firestore Timestamp) before storing.
      final userData = <String, dynamic>{
        'full_name': rawData['full_name'],
        'email': rawData['email'],
      };

      final token = await credential.user!.getIdToken();

      return {
        'access_token': token,
        'user': {'uid': uid, ...userData},
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user!.updateDisplayName(fullName);

      final uid = credential.user!.uid;
      final userData = {
        'full_name': fullName,
        'email': email,
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).set(userData);

      final token = await credential.user!.getIdToken();

      // Sign out immediately after registration so the user has to log in.
      await _auth.signOut();

      return {
        'access_token': token,
        'user': {'uid': uid, 'full_name': fullName, 'email': email},
      };
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapAuthError(e));
    }
  }

  Future<void> saveSession(Map<String, dynamic> responseData) async {
    await _storage.write(key: _tokenKey, value: responseData['access_token'] as String?);
    await _storage.write(key: _userKey, value: jsonEncode(responseData['user']));
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<Map<String, dynamic>?> readUser() async {
    final value = await _storage.read(key: _userKey);
    if (value == null) {
      return null;
    }
    return jsonDecode(value) as Map<String, dynamic>;
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}