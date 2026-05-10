import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinVault {
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'user_pin';

  Future<bool> hasPin() async {
    return await _storage.read(key: _pinKey) != null;
  }

  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  Future<bool> verifyPin(String pin) async {
    final savedPin = await _storage.read(key: _pinKey);
    return savedPin == pin;
  }

  Future<void> reset() async {
    await _storage.delete(key: _pinKey);
    // Also clear database (call from UI)
  }
}
