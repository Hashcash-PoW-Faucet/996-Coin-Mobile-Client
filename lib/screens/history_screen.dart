// =========================
// lib/screens/history_screen.dart
// =========================
import 'package:flutter/material.dart';

import '../models/history_entry.dart';
import '../services/api_service.dart';

class HistoryScreen extends StatefulWidget {
  final String address;

  const HistoryScreen({super.key, required this.address});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _api = const ApiService();

  bool _loading = true;
  String? _error;
  List<HistoryEntry> _rows = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await _api.getHistory(widget.address);
      if (!mounted) return;
      setState(() {
        _rows = rows;
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
      appBar: AppBar(title: const Text('History')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : ListView.separated(
                    itemCount: _rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final row = _rows[index];
                      return Card(
                        child: ListTile(
                          title: Text('${row.delta} NNS'),
                          subtitle: Text('${row.time}\n${row.txid}'),
                          isThreeLine: true,
                          trailing: Text(row.confirmations?.toString() ?? '-'),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
