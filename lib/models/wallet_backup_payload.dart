class WalletBackupPayload {
  final int version;
  final String coin;
  final String symbol;
  final String address;
  final String wif;
  final String privateKeyHex;
  final String publicKeyHex;
  final String createdAt;

  const WalletBackupPayload({
    required this.version,
    required this.coin,
    required this.symbol,
    required this.address,
    required this.wif,
    required this.privateKeyHex,
    required this.publicKeyHex,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'coin': coin,
      'symbol': symbol,
      'address': address,
      'wif': wif,
      'private_key_hex': privateKeyHex,
      'public_key_hex': publicKeyHex,
      'created_at': createdAt,
    };
  }

  factory WalletBackupPayload.fromJson(Map<String, dynamic> json) {
    return WalletBackupPayload(
      version: json['version'] as int? ?? 1,
      coin: json['coin'] as String? ?? '996-Coin',
      symbol: json['symbol'] as String? ?? 'NNS',
      address: json['address'] as String? ?? '',
      wif: json['wif'] as String? ?? '',
      privateKeyHex: json['private_key_hex'] as String? ?? '',
      publicKeyHex: json['public_key_hex'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}