import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static const String _pinKey = 'app_pin';

  final FlutterSecureStorage _storage =
      const FlutterSecureStorage();

  Future<void> savePin(String pin) async {
    await _storage.write(
      key: _pinKey,
      value: pin,
    );

    final saved = await _storage.read(key: _pinKey);

    print('PIN SAVED TEST: $saved');
  }

  Future<String?> getPin() async {
    final pin = await _storage.read(key: _pinKey);

    print('PIN READ TEST: $pin');

    return pin;
  }

  Future<bool> hasPin() async {
    final exists = await _storage.containsKey(key: _pinKey);

    print('PIN EXISTS TEST: $exists');

    return exists;
  }

  Future<bool> verifyPin(String pin) async {
    final savedPin = await getPin();

    return savedPin == pin;
  }

  Future<void> deletePin() async {
    await _storage.delete(key: _pinKey);
  }
}