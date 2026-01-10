import 'package:equatable/equatable.dart';

class SystemStatsEntity extends Equatable {
  final int totalUsers;
  final int activeTransactions;
  final double systemHealth;
  final int pendingKyc;

  const SystemStatsEntity({
    required this.totalUsers,
    required this.activeTransactions,
    required this.systemHealth,
    required this.pendingKyc,
  });

  @override
  List<Object?> get props => [
        totalUsers,
        activeTransactions,
        systemHealth,
        pendingKyc,
      ];
}
