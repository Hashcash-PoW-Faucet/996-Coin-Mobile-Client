// =========================
// lib/screens/home_screen.dart
// =========================
import 'package:flutter/material.dart';

import '../models/wallet_info.dart';
import '../models/wallet_backup_payload.dart';
import '../services/secure_wallet_store.dart';
import '../services/wallet_backup_service.dart';
import 'create_wallet_screen.dart';
import 'import_wallet_screen.dart';
import 'wallet_screen.dart';
import '../services/auth_service.dart';
import 'setup_pin_screen.dart';
import 'unlock_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _store = SecureWalletStore();
  final _authService = AuthService();
  final _backupService = WalletBackupService();
  bool _unlocked = false;
  WalletInfo? _wallet;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final wallet = await _store.loadWallet();
    final pinConfigured = await _authService.isPinConfigured();

    WalletInfo? visibleWallet = wallet;

    if (wallet != null && pinConfigured && !_unlocked && mounted) {
      final unlocked = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const UnlockScreen()),
      );
      _unlocked = unlocked == true;
      if (!_unlocked) {
        visibleWallet = null;
      }
    }

    if (!mounted) return;
    setState(() {
      _wallet = visibleWallet;
      _loading = false;
    });
  }

  Future<void> _importEncryptedBackup() async {
    final backupController = TextEditingController();
    final passwordController = TextEditingController();
    String? localError;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Import Encrypted Backup'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paste the encrypted backup text and enter the backup password to restore the wallet.',
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: backupController,
                        minLines: 6,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          labelText: 'Encrypted backup text',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Backup password',
                        ),
                      ),
                      if (localError != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          localError!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final backupText = backupController.text.trim();
                    final password = passwordController.text.trim();

                    if (backupText.isEmpty) {
                      setLocalState(() {
                        localError = 'Please paste the encrypted backup text.';
                      });
                      return;
                    }
                    if (password.isEmpty) {
                      setLocalState(() {
                        localError = 'Please enter the backup password.';
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop({
                      'backup': backupText,
                      'password': password,
                    });
                  },
                  child: const Text('Restore'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == null) {
      return;
    }

    try {
      final payload = _backupService.decryptBackupJson(
        encryptedBackupJson: result['backup']!,
        password: result['password']!,
      );

      final restoredWallet = WalletInfo(
        address: payload.address,
        wif: payload.wif,
        privateKeyHex: payload.privateKeyHex,
        publicKeyHex: payload.publicKeyHex,
      );

      await _store.saveWallet(restoredWallet);

      final pinConfigured = await _authService.isPinConfigured();
      if (restoredWallet.address.isNotEmpty && !pinConfigured && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const SetupPinScreen()),
        );
      }

      _unlocked = true;
      await _loadWallet();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Encrypted wallet backup restored successfully.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_wallet != null) {
      return WalletScreen(wallet: _wallet!);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('996-Coin Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Light Wallet MVP',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Create a new wallet or import an existing one. Private keys stay on this device.',
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CreateWalletScreen()),
                );
                final hasWallet = await _store.loadWallet();
                final pinConfigured = await _authService.isPinConfigured();
                if (hasWallet != null && !pinConfigured && mounted) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SetupPinScreen()),
                  );
                }
                _unlocked = true;
                _loadWallet();
              },
              child: const Text('Create Wallet'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ImportWalletScreen()),
                );
                final hasWallet = await _store.loadWallet();
                final pinConfigured = await _authService.isPinConfigured();
                if (hasWallet != null && !pinConfigured && mounted) {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SetupPinScreen()),
                  );
                }
                _unlocked = true;
                _loadWallet();
              },
              child: const Text('Import Private Key'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _importEncryptedBackup,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Import Encrypted Backup'),
            ),
          ],
        ),
      ),
    );
  }
}
