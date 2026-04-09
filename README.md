# 996-Coin Mobile Wallet

A Flutter-based light wallet for 996-Coin (NNS).

## Current Features

- Create a new wallet locally
- Import an existing wallet
- Store wallet data locally on the device
- PIN protection and optional biometric unlock
- Show address, balance, and transaction history
- Show a receive QR code
- Build, sign, test, and broadcast transactions locally
- Address book for saved recipient addresses
- QR scanning for recipient addresses on supported mobile devices

## Project Status

This project is currently focused on a simple mobile light wallet experience for 996-Coin.
The app talks to the explorer API for balance, UTXO, history, mempool test, and broadcast operations,
while transaction signing happens locally inside the wallet.

## Tech Stack

- Flutter
- Dart
- Explorer API backend
- Local key handling and transaction signing

## Development

### Run locally

```bash
flutter pub get
flutter run
```

### Build Android APK

```bash
flutter build apk --release
```

### Build Android App Bundle

```bash
flutter build appbundle --release
```

## Notes

- Balance updates may not appear immediately after sending a transaction.
  In many cases, the updated balance is reflected once the transaction has been included in a block.
- QR scanning is intended mainly for Android and iOS devices.
- Keep your private key and WIF secret.

## License

MIT
