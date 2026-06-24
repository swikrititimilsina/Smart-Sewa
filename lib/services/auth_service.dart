import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String adminEmail = 'admin@smartsewa.com';
  static const String adminPassword = 'admin123';

  /// Initializes the default admin account if it does not exist.
  /// This should be called after Firebase.initializeApp()
  static Future<void> initializeAdmin() async {
    try {
      // First, try to sign in to see if the account exists
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail,
        password: adminPassword,
      );
      // If sign in is successful, sign out so we don't leave the app logged in automatically
      await FirebaseAuth.instance.signOut();
      if (kDebugMode) {
        print('Admin account verified.');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        // The user doesn't exist (or we got invalid-credential on newer firebase versions if not found)
        // Let's create it.
        try {
          final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: adminEmail,
            password: adminPassword,
          );
          
          if (userCred.user != null) {
            await FirebaseFirestore.instance.collection('users').doc(userCred.user!.uid).set({
              'name': 'System Admin',
              'email': adminEmail,
              'role': 'admin',
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
          
          await FirebaseAuth.instance.signOut();
          if (kDebugMode) {
            print('Admin account and Firestore document created successfully.');
          }
        } catch (createError) {
          if (kDebugMode) {
            print('Failed to create admin account: $createError');
          }
        }
      } else {
        if (kDebugMode) {
          print('Error checking admin account: ${e.message}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Unexpected error during admin initialization: $e');
      }
    }
  }
}
