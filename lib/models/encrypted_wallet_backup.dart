

class EncryptedWalletBackup {
  final int version;
  final String cipher;
  final String kdf;
  final int iterations;
  final String saltBase64;
  final String nonceBase64;
  final String ciphertextBase64;

  const EncryptedWalletBackup({
    required this.version,
    required this.cipher,
    required this.kdf,
    required this.iterations,
    required this.saltBase64,
    required this.nonceBase64,
    required this.ciphertextBase64,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'cipher': cipher,
      'kdf': kdf,
      'iterations': iterations,
      'salt_base64': saltBase64,
      'nonce_base64': nonceBase64,
      'ciphertext_base64': ciphertextBase64,
    };
  }

  factory EncryptedWalletBackup.fromJson(Map<String, dynamic> json) {
    return EncryptedWalletBackup(
      version: json['version'] as int? ?? 1,
      cipher: json['cipher'] as String? ?? 'AES-256-GCM',
      kdf: json['kdf'] as String? ?? 'PBKDF2-HMAC-SHA256',
      iterations: json['iterations'] as int? ?? 150000,
      saltBase64: json['salt_base64'] as String? ?? '',
      nonceBase64: json['nonce_base64'] as String? ?? '',
      ciphertextBase64: json['ciphertext_base64'] as String? ?? '',
    );
  }
}