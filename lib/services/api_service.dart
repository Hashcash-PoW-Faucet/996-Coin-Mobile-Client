// =========================
// lib/services/api_service.dart
// =========================
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/history_entry.dart';
import '../models/tx_status.dart';
import '../models/utxo.dart';

class ApiService {
  final String baseUrl;

  const ApiService({this.baseUrl = AppConfig.apiBaseUrl});

  Future<double> getBalance(String address) async {
    final uri = Uri.parse('$baseUrl/api/getbalance/$address');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load balance');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return ((data['balance'] ?? 0) as num).toDouble();
  }

  Future<List<Utxo>> getUtxos(String address) async {
    final uri = Uri.parse('$baseUrl/api/utxos/$address');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load UTXOs');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final utxos = (data['utxos'] as List<dynamic>? ?? const []);
    return utxos
        .map((e) => Utxo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<HistoryEntry>> getHistory(String address, {int page = 1, int limit = 50}) async {
    final uri = Uri.parse('$baseUrl/api/address/$address/history?page=$page&limit=$limit');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load history');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final rows = (data['history'] as List<dynamic>? ?? const []);
    return rows
        .map((e) => HistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TxStatus> getTxStatus(String txid) async {
    final uri = Uri.parse('$baseUrl/api/txstatus/$txid');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load transaction status');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return TxStatus.fromJson(data);
  }

  Future<Map<String, dynamic>> testMempoolAccept(String rawHex) async {
    final uri = Uri.parse('$baseUrl/api/testmempoolaccept');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'hex': rawHex}),
    );
    if (res.statusCode != 200) {
      throw Exception('Mempool test failed');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['ok'] != true) {
      throw Exception((data['error'] ?? 'Mempool test failed').toString());
    }
    final result = data['result'];
    if (result is! Map<String, dynamic>) {
      throw Exception('Unexpected testmempoolaccept response');
    }
    return result;
  }

  Future<String> sendRawTransaction(String rawHex) async {
    final uri = Uri.parse('$baseUrl/api/sendrawtransaction');
    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'hex': rawHex}),
    );
    if (res.statusCode != 200) {
      throw Exception('Broadcast failed');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['ok'] != true) {
      throw Exception((data['error'] ?? 'Broadcast failed').toString());
    }
    return (data['txid'] ?? '').toString();
  }
}
