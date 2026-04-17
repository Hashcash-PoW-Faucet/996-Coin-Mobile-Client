import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import '../models/encrypted_wallet_backup.dart';
import '../models/wallet_backup_payload.dart';

class WalletBackupService {
  static const int currentVersion = 1;
  static const String cipherName = 'AES-256-GCM';
  static const String kdfName = 'PBKDF2-HMAC-SHA256';
  static const int defaultIterations = 150000;
  static const int _saltLength = 16;
  static const int _nonceLength = 12;
  static const int _keyLength = 32;
  static const int _tagLengthBits = 128;

  String createEncryptedBackupJson({
    required WalletBackupPayload payload,
    required String password,
    int iterations = defaultIterations,
  }) {
    _validatePassword(password);
    _validatePayload(payload);

    final salt = _randomBytes(_saltLength);
    final nonce = _randomBytes(_nonceLength);
    final key = _deriveKey(
      password: password,
      salt: salt,
      iterations: iterations,
      length: _keyLength,
    );

    final plaintext = Uint8List.fromList(
      utf8.encode(jsonEncode(payload.toJson())),
    );
    final ciphertext = _encrypt(
      plaintext: plaintext,
      key: key,
      nonce: nonce,
    );

    final backup = EncryptedWalletBackup(
      version: currentVersion,
      cipher: cipherName,
      kdf: kdfName,
      iterations: iterations,
      saltBase64: base64Encode(salt),
      nonceBase64: base64Encode(nonce),
      ciphertextBase64: base64Encode(ciphertext),
    );

    return const JsonEncoder.withIndent('  ').convert(backup.toJson());
  }

  EncryptedWalletBackup parseEncryptedBackupJson(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return EncryptedWalletBackup.fromJson(decoded);
    } catch (_) {
      throw Exception('Invalid encrypted backup file.');
    }
  }

  WalletBackupPayload decryptBackupJson({
    required String encryptedBackupJson,
    required String password,
  }) {
    _validatePassword(password);

    final backup = parseEncryptedBackupJson(encryptedBackupJson);
    _validateEncryptedBackup(backup);

    try {
      final salt = Uint8List.fromList(base64Decode(backup.saltBase64));
      final nonce = Uint8List.fromList(base64Decode(backup.nonceBase64));
      final ciphertext = Uint8List.fromList(base64Decode(backup.ciphertextBase64));

      final key = _deriveKey(
        password: password,
        salt: salt,
        iterations: backup.iterations,
        length: _keyLength,
      );

      final plaintext = _decrypt(
        ciphertext: ciphertext,
        key: key,
        nonce: nonce,
      );

      final decoded = jsonDecode(utf8.decode(plaintext)) as Map<String, dynamic>;
      final payload = WalletBackupPayload.fromJson(decoded);
      _validatePayload(payload);
      return payload;
    } catch (_) {
      throw Exception('Could not decrypt backup. Wrong password or invalid file.');
    }
  }

  Uint8List _deriveKey({
    required String password,
    required Uint8List salt,
    required int iterations,
    required int length,
  }) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    derivator.init(Pbkdf2Parameters(salt, iterations, length));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  Uint8List _encrypt({
    required Uint8List plaintext,
    required Uint8List key,
    required Uint8List nonce,
  }) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(KeyParameter(key), _tagLengthBits, nonce, Uint8List(0)),
      );
    return cipher.process(plaintext);
  }

  Uint8List _decrypt({
    required Uint8List ciphertext,
    required Uint8List key,
    required Uint8List nonce,
  }) {
    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(KeyParameter(key), _tagLengthBits, nonce, Uint8List(0)),
      );
    return cipher.process(ciphertext);
  }

  Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }

  void _validatePassword(String password) {
    if (password.trim().isEmpty) {
      throw Exception('Please enter a backup password.');
    }
  }

  void _validatePayload(WalletBackupPayload payload) {
    if (payload.address.trim().isEmpty) {
      throw Exception('Wallet backup payload is missing the address.');
    }
    if (payload.wif.trim().isEmpty) {
      throw Exception('Wallet backup payload is missing the WIF.');
    }
    if (payload.privateKeyHex.trim().isEmpty) {
      throw Exception('Wallet backup payload is missing the private key.');
    }
    if (payload.publicKeyHex.trim().isEmpty) {
      throw Exception('Wallet backup payload is missing the public key.');
    }
  }

  void _validateEncryptedBackup(EncryptedWalletBackup backup) {
    if (backup.cipher != cipherName) {
      throw Exception('Unsupported backup cipher.');
    }
    if (backup.kdf != kdfName) {
      throw Exception('Unsupported backup key derivation function.');
    }
    if (backup.saltBase64.trim().isEmpty ||
        backup.nonceBase64.trim().isEmpty ||
        backup.ciphertextBase64.trim().isEmpty) {
      throw Exception('Encrypted backup file is incomplete.');
    }
  }
}