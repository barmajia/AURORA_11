import 'dart:convert';
import 'package:vault_storage/vault_storage.dart';
import 'package:aurora/models/analysis/analytics.dart';
import 'package:aurora/models/analysis/enums.dart';

class AnalyticsStorage {
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

  static Future<void> saveDailyAnalytics(List<DailyAnalytics> analytics) async {
    final list = analytics.map((a) => a.toMap()).toList();
    await _saveString('daily_analytics', jsonEncode(list));
  }

  static Future<List<DailyAnalytics>> getDailyAnalytics() async {
    final value = await _getString('daily_analytics');
    if (value == null || value.isEmpty) return [];
    try {
      final list = jsonDecode(value) as List;
      return list
          .map((item) => DailyAnalytics.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<DailyAnalytics>> getDailyAnalyticsByType(MetricType type) async {
    final analytics = await getDailyAnalytics();
    return analytics.where((a) => a.metricType == type).toList();
  }

  static Future<List<DailyAnalytics>> getDailyAnalyticsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final analytics = await getDailyAnalytics();
    return analytics
        .where(
            (a) => a.metricDate.isAfter(start) && a.metricDate.isBefore(end.add(const Duration(days: 1))))
        .toList();
  }

  static Future<void> addDailyAnalytics(DailyAnalytics analytics) async {
    final list = await getDailyAnalytics();
    list.insert(0, analytics);
    await saveDailyAnalytics(list);
  }

  static Future<void> clearDailyAnalytics() async {
    await _vault.delete('daily_analytics');
  }

  static Future<void> saveSnapshot(AnalyticsSnapshot snapshot) async {
    await _saveString('analytics_snapshot', jsonEncode(snapshot.toMap()));
  }

  static Future<AnalyticsSnapshot?> getSnapshot() async {
    final value = await _getString('analytics_snapshot');
    if (value == null || value.isEmpty) return null;
    try {
      final json = jsonDecode(value) as Map<String, dynamic>;
      return AnalyticsSnapshot.fromMap(json);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearSnapshot() async {
    await _vault.delete('analytics_snapshot');
  }

  static Future<void> clearAll() async {
    await clearDailyAnalytics();
    await clearSnapshot();
  }
}
