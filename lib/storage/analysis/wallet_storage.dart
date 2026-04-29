import 'dart:convert';
import 'package:vault_storage/vault_storage.dart';
import 'package:aurora/models/analysis/wallet.dart';
import 'package:aurora/models/analysis/enums.dart';

class WalletStorage {
  static late final VaultStorage _vault;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    _vault = VaultStorage();
    await _vault.init(
      key: 'aurora_master_key',
      alias: 'aurora_app',
    );
    _isInitialized = true;
  }

  static Future<void> _saveString(String key, String value) async {
    await _vault.write(key, value);
  }

  static Future<String?> _getString(String key) async {
    try {
      return await _vault.read(key);
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveWallet(Wallet wallet) async {
    await _saveString('wallet_data', jsonEncode(wallet.toMap()));
  }

  static Future<Wallet?> getWallet() async {
    final value = await _getString('wallet_data');
    if (value == null || value.isEmpty) return null;
    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      return Wallet.fromMap(json);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearWallet() async {
    await _vault.delete('wallet_data');
  }

  static Future<void> saveTransactions(List<WalletTransaction> transactions) async {
    final list = transactions.map((t) => t.toMap()).toList();
    await _saveString('wallet_transactions', jsonEncode(list));
  }

  static Future<List<WalletTransaction>> getTransactions() async {
    final value = await _getString('wallet_transactions');
    if (value == null || value.isEmpty) return [];
    try {
      final list = jsonDecode(value) as List;
      return list
          .map((item) => WalletTransaction.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> addTransaction(WalletTransaction transaction) async {
    final transactions = await getTransactions();
    transactions.insert(0, transaction);
    await saveTransactions(transactions);
  }

  static Future<void> clearTransactions() async {
    await _vault.delete('wallet_transactions');
  }

  static Future<void> clearAll() async {
    await clearWallet();
    await clearTransactions();
  }
}
