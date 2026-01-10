import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/admin_settings_entity.dart';
import 'package:paypulse/domain/entities/system_stats_entity.dart';
import 'package:paypulse/domain/entities/log_entity.dart';

abstract class AdminDataSource {
  Future<AdminSettingsEntity> getSettings();
  Future<void> updateSettings(AdminSettingsEntity settings);
  Future<SystemStatsEntity> getSystemStats();
  Stream<List<LogEntity>> getRecentLogs();
  Future<void> logAction(LogEntity log);
}

class AdminDataSourceImpl implements AdminDataSource {
  final FirebaseFirestore _firestore;

  AdminDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<AdminSettingsEntity> getSettings() async {
    final doc =
        await _firestore.collection('admin').doc('global_settings').get();
    if (doc.exists && doc.data() != null) {
      // Assuming AdminSettingsEntity has a fromMap or we map it manually
      // For now, simpler mapping since Entity doesn't have fromMap visible in previous context
      // We might need to map manually if Entity is pure domain.
      // Let's assume we need to map manually or add fromMap to Entity if safe.
      // Actually AdminSettingsEntity is just a data class.
      // Retaining "Simulated" behavior for settings if not fully implemented in DB yet?
      // The user wants "Real Data". I should try to read from DB.
      // Providing default if not exists.
      final data = doc.data()!;
      return AdminSettingsEntity(
        isInvestmentEnabled: data['isInvestmentEnabled'] ?? false,
        isCryptoEnabled: data['isCryptoEnabled'] ?? false,
        isSavingsEnabled: data['isSavingsEnabled'] ?? false,
        isBillsEnabled: data['isBillsEnabled'] ?? false,
        isSocialEnabled: data['isSocialEnabled'] ?? false,
        isMaintenanceMode: data['isMaintenanceMode'] ?? false,
      );
    }
    return const AdminSettingsEntity();
  }

  @override
  Future<void> updateSettings(AdminSettingsEntity settings) async {
    await _firestore.collection('admin').doc('global_settings').set({
      'isInvestmentEnabled': settings.isInvestmentEnabled,
      'isCryptoEnabled': settings.isCryptoEnabled,
      'isSavingsEnabled': settings.isSavingsEnabled,
      'isBillsEnabled': settings.isBillsEnabled,
      'isSocialEnabled': settings.isSocialEnabled,
      'isMaintenanceMode': settings.isMaintenanceMode,
    }, SetOptions(merge: true));
  }

  @override
  Future<SystemStatsEntity> getSystemStats() async {
    final userCountQuery = await _firestore.collection('users').count().get();
    final txCountQuery =
        await _firestore.collectionGroup('transactions').count().get();

    // Simulating "Active Txs" as total transactions for now, or last 24h?
    // "Active stats" usually implies volume or recent count.
    // Let's simply count all for "total volume" proxy, or maybe we can't filter count efficiently without index.
    // collectionGroup count is fine.

    final pendingKycQuery = await _firestore
        .collection('users')
        .where('isPhoneVerified', isEqualTo: false)
        .count()
        .get();

    return SystemStatsEntity(
      totalUsers: userCountQuery.count ?? 0,
      activeTransactions: txCountQuery.count ?? 0,
      systemHealth: 99.9, // Static for now
      pendingKyc: pendingKycQuery.count ?? 0,
    );
  }

  @override
  Stream<List<LogEntity>> getRecentLogs() {
    return _firestore
        .collection('admin_logs')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LogEntity(
          id: doc.id,
          message: data['message'] ?? '',
          type: data['type'] ?? 'INFO',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          userId: data['userId'],
        );
      }).toList();
    });
  }

  @override
  Future<void> logAction(LogEntity log) async {
    await _firestore.collection('admin_logs').add({
      'message': log.message,
      'type': log.type,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': log.userId,
    });
  }
}
