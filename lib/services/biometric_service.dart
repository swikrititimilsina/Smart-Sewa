import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class BiometricService {
  static final _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();

  // Keys are per-user (email-based) so different accounts are fully isolated
  static String _keyEnabled(String email) => 'biometric_enabled_${email.toLowerCase()}';
  static String _keyCredentials(String email) => 'user_credentials_${email.toLowerCase()}';

  /// Check if the device has biometric hardware and is enrolled
  static Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Authenticate the user using Biometrics
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Please authenticate to access Smart Sewa securely',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Check if biometric login is enabled for a specific user email
  static Future<bool> isBiometricEnabled(String email) async {
    final val = await _storage.read(key: _keyEnabled(email));
    return val == 'true';
  }

  /// Enable or disable biometric login for a specific user email
  static Future<void> setBiometricEnabled(String email, bool enabled) async {
    await _storage.write(key: _keyEnabled(email), value: enabled.toString());
    if (!enabled) {
      await clearCredentials(email);
    }
  }

  /// Securely save email and password for a specific user
  static Future<void> saveCredentials(String email, String password) async {
    final credentials = jsonEncode({'email': email, 'password': password});
    await _storage.write(key: _keyCredentials(email), value: credentials);
  }

  /// Retrieve saved credentials for a specific user email
  static Future<Map<String, String>?> getCredentials(String email) async {
    final credentialsStr = await _storage.read(key: _keyCredentials(email));
    if (credentialsStr != null) {
      try {
        final map = jsonDecode(credentialsStr) as Map<String, dynamic>;
        return {
          'email': map['email']?.toString() ?? '',
          'password': map['password']?.toString() ?? '',
        };
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Clear saved credentials for a specific user
  static Future<void> clearCredentials(String email) async {
    await _storage.delete(key: _keyCredentials(email));
  }
}
