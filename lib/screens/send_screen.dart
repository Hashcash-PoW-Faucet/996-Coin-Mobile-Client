import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../models/unsigned_transaction_preview.dart';
import '../models/wallet_info.dart';
import '../services/api_service.dart';
import '../services/tx_builder_service.dart';
import '../services/wallet_service.dart';
import '../models/address_book_entry.dart';
import '../services/address_book_store.dart';

class SendScreen extends StatefulWidget {
  final WalletInfo wallet;

  const SendScreen({super.key, required this.wallet});

  @override
  State<SendScreen> createState() => _SendScreenState();
}

class _SendScreenState extends State<SendScreen> {
  final _addressController = TextEditingController();
  final _amountController = TextEditingController();
  final _feeController = TextEditingController(text: '0.001');

  final _api = const ApiService();
  late final WalletService _walletService;
  late final TxBuilderService _txBuilder;

  bool _loading = false;
  String? _error;
  UnsignedTransactionPreview? _preview;
  String? _signedRawTxHex;
  String? _successMessage;

  final _addressBookStore = AddressBookStore();
  List<AddressBookEntry> _addressBookEntries = const [];

  @override
  void initState() {
    super.initState();
    _walletService = WalletService();
    _txBuilder = TxBuilderService(walletService: _walletService);
    _loadAddressBook();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _amountController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  int _parseCoinsToSats(String raw, String fieldLabel) {
    final value = raw.trim();
    final validPattern = RegExp(r'^\d+(\.\d{0,8})?$');
    if (!validPattern.hasMatch(value)) {
      throw Exception('Please enter a valid $fieldLabel with up to 8 decimal places.');
    }

    final parts = value.split('.');
    final wholePart = parts[0];
    final fractionalPart = parts.length > 1 ? parts[1] : '';
    final paddedFraction = fractionalPart.padRight(8, '0');

    final whole = int.parse(wholePart);
    final fractional = paddedFraction.isEmpty ? 0 : int.parse(paddedFraction);
    return whole * 100000000 + fractional;
  }

  Future<void> _scanRecipientQr() async {
    final scannedValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _QrScannerScreen(),
      ),
    );

    if (!mounted || scannedValue == null || scannedValue.trim().isEmpty) {
      return;
    }

    setState(() {
      _addressController.text = scannedValue.trim();
    });
  }

  Future<void> _loadAddressBook() async {
    final entries = await _addressBookStore.loadEntries();
    if (!mounted) return;
    setState(() {
      _addressBookEntries = entries;
    });
  }

  Future<void> _openAddressBookPicker() async {
    if (_addressBookEntries.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your address book is empty.')),
      );
      return;
    }

    final selected = await showModalBottomSheet<AddressBookEntry>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _addressBookEntries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = _addressBookEntries[index];
              return ListTile(
                title: Text(entry.label),
                subtitle: Text(entry.address),
                onTap: () => Navigator.of(context).pop(entry),
              );
            },
          ),
        );
      },
    );

    if (!mounted || selected == null) return;
    setState(() {
      _addressController.text = selected.address;
    });
  }

  Future<void> _saveCurrentAddressToAddressBook() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination address first.')),
      );
      return;
    }

    try {
      _walletService.addressToPubKeyHash(address);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 996 address.')),
      );
      return;
    }

    final labelController = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Address'),
          content: TextField(
            controller: labelController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Label',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(labelController.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    labelController.dispose();

    if (!mounted || label == null || label.trim().isEmpty) {
      return;
    }

    final entry = AddressBookEntry(label: label.trim(), address: address);
    await _addressBookStore.upsertEntry(entry);
    await _loadAddressBook();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Address saved to address book.')),
    );
  }

  bool get _canScanQr =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _buildPreview() async {
    setState(() {
      _loading = true;
      _error = null;
      _preview = null;
      _signedRawTxHex = null;
      _successMessage = null;
    });

    try {
      final toAddress = _addressController.text.trim();
      final amountText = _amountController.text.trim();
      final feeText = _feeController.text.trim();

      if (toAddress.isEmpty) {
        throw Exception('Please enter a destination address.');
      }

      final sendAmountSats = _parseCoinsToSats(amountText, 'amount');
      final feeSats = _parseCoinsToSats(feeText, 'fee');

      if (sendAmountSats <= 0) {
        throw Exception('Please enter a valid amount greater than zero.');
      }

      final utxos = await _api.getUtxos(widget.wallet.address);
      final preview = _txBuilder.buildUnsignedTransaction(
        availableUtxos: utxos,
        toAddress: toAddress,
        changeAddress: widget.wallet.address,
        sendAmountSats: sendAmountSats,
        feeSats: feeSats,
      );

      if (!mounted) return;
      setState(() {
        _preview = preview;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _broadcastTransaction() async {
    final preview = _preview;
    if (preview == null) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _successMessage = null;
    });

    try {
      var signedHex = _signedRawTxHex;
      if (signedHex == null || signedHex.trim().isEmpty) {
        signedHex = _txBuilder.signLegacyP2pkhTransaction(
          privateKeyHex: widget.wallet.privateKeyHex,
          inputs: preview.inputs,
          outputs: preview.outputs,
        );
      }

      final mempoolResult = await _api.testMempoolAccept(signedHex);
      final allowed = mempoolResult['allowed'] == true;
      if (!allowed) {
        final rejectReason = (mempoolResult['reject-reason'] ?? 'Transaction rejected by mempool policy.').toString();
        throw Exception(rejectReason);
      }

      final txid = await _api.sendRawTransaction(signedHex);

      if (!mounted) return;
      setState(() {
        _signedRawTxHex = signedHex;
        _successMessage =
            'Transaction successfully added to mempool.\n\n'
            'TXID: $txid\n\n'
            'Your balance may not update immediately. The updated balance will usually be reflected once the transaction has been included in a block.';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send NNS')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Destination address',
                border: const OutlineInputBorder(),
                suffixIcon: _canScanQr
                    ? IconButton(
                        onPressed: _loading ? null : _scanRecipientQr,
                        tooltip: 'Scan QR code',
                        icon: const Icon(Icons.qr_code_scanner),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _openAddressBookPicker,
                    icon: const Icon(Icons.book_outlined),
                    label: const Text('Address Book'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading ? null : _saveCurrentAddressToAddressBook,
                    icon: const Icon(Icons.bookmark_add_outlined),
                    label: const Text('Save Address'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount (NNS)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _feeController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Fee (NNS)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _buildPreview,
              child: const Text('Review Transaction'),
            ),
            const SizedBox(height: 12),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_preview != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Inputs: ${_preview!.inputs.length}'),
                      Text('Outputs: ${_preview!.outputs.length}'),
                      Text('Selected total: ${_preview!.selectedInputTotalSats / 100000000} NNS'),
                      Text('Send amount: ${_preview!.sendAmountSats / 100000000} NNS'),
                      Text('Fee: ${_preview!.feeSats / 100000000} NNS'),
                      Text('Change: ${_preview!.changeSats / 100000000} NNS'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: (_loading || _successMessage != null) ? null : _broadcastTransaction,
                        child: const Text('Send Transaction'),
                      ),
                      const SizedBox(height: 12),
                      if (_successMessage != null) ...[
                        const Text(
                          'Result',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(_successMessage!),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Back to Wallet'),
                        ),
                      ] else
                        const Text(
                          'When you send the transaction, the wallet will sign it locally, test it against mempool policy, and then broadcast it if the policy check succeeds.',
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QrScannerScreen extends StatefulWidget {
  const _QrScannerScreen();

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  bool _handled = false;

  void _handleBarcode(BarcodeCapture capture) {
    if (_handled) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue?.trim();
      if (rawValue != null && rawValue.isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(rawValue);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Recipient QR')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _handleBarcode,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child: const Text(
                'Point the camera at a wallet address QR code.',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

