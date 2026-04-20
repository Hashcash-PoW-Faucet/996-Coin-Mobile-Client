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
- Encrypted wallet backup export and restore

## Project Status

This project is currently focused on a simple mobile light wallet experience for 996-Coin.
The app talks to the explorer API for balance, UTXO, history, mempool test, and broadcast operations,
while transaction signing happens locally inside the wallet.

## Security and Privacy Notes

- Private keys stay on the device.
- Transaction signing happens locally in the wallet.
- The explorer API is used only for blockchain-related lookups and transaction broadcast.
- This is a light wallet, not a full node.

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
flutter pub get
flutter build apk --release
```

### Build Android App Bundle

```bash
flutter pub get
flutter build appbundle --release
```

## Android / F-Droid Notes

This repository contains multiple platform folders, but F-Droid packaging is relevant only for the Android app.

### Android build

```bash
flutter pub get
flutter build apk --release
```

### Packaging notes

- Official Android releases should be built from tagged source revisions.
- The Android app is intended to build directly from source.
- F-Droid metadata, screenshots, and changelogs should be provided separately via the standard fastlane metadata structure.

## Notes

- Balance updates may not appear immediately after sending a transaction.
  In many cases, the updated balance is reflected once the transaction has been included in a block.
- QR scanning is intended mainly for Android and iOS devices.
- Keep your private key and WIF secret.

## License

This project is licensed under the MIT License.
