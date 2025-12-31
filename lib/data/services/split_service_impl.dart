import 'dart:async';
import 'package:paypulse/domain/entities/split_bill_entity.dart';
import 'package:paypulse/domain/entities/split_item_entity.dart';
import 'package:paypulse/domain/entities/split_participant_entity.dart';
import 'package:paypulse/domain/services/split_service.dart';
import 'package:uuid/uuid.dart';

class SplitServiceImpl implements SplitService {
  final _uuid = const Uuid();

  // In-memory storage for active session (repo would go here)
  final Map<String, StreamController<SplitBill>> _controllers = {};
  final Map<String, SplitBill> _cache = {};

  @override
  Future<SplitBill> createSplitBill(
      String title, double totalAmount, String currencyCode) async {
    final id = _uuid.v4();
    final newBill = SplitBill(
      id: id,
      creatorId: 'current_user', // TODO: Get real user ID
      title: title,
      totalAmount: totalAmount,
      currencyCode: currencyCode,
      date: DateTime.now(),
      items: [],
      participants: [],
    );

    _cache[id] = newBill;
    _ensureController(id).add(newBill);
    return newBill;
  }

  @override
  Stream<SplitBill?> getBillStream(String billId) {
    return _ensureController(billId).stream;
  }

  @override
  Future<SplitBill> addItem(String billId, SplitItem item) async {
    final bill = _cache[billId];
    if (bill == null) throw Exception('Bill not found');

    final updatedItems = List<SplitItem>.from(bill.items)..add(item);
    final updatedBill = bill.copyWith(items: updatedItems);

    _updateCache(updatedBill);
    return updatedBill;
  }

  @override
  Future<SplitBill> addParticipant(String billId, String userId) async {
    final bill = _cache[billId];
    if (bill == null) throw Exception('Bill not found');

    // Don't add if exists
    if (bill.participants.any((p) => p.userId == userId)) return bill;

    final newParticipant = SplitParticipant(
        userId: userId,
        displayName: 'User $userId', // TODO: Fetch real name
        status: SplitStatus.pending);

    final updatedParticipants = List<SplitParticipant>.from(bill.participants)
      ..add(newParticipant);
    final updatedBill = bill.copyWith(participants: updatedParticipants);

    _updateCache(updatedBill);
    return updatedBill;
  }

  @override
  Future<SplitBill> toggleItemAssignment(
      String billId, String itemId, String userId) async {
    final bill = _cache[billId];
    if (bill == null) throw Exception('Bill not found');

    final updatedItems = bill.items.map((item) {
      if (item.id == itemId) {
        final assigned = List<String>.from(item.assignedUserIds);
        if (assigned.contains(userId)) {
          assigned.remove(userId);
        } else {
          assigned.add(userId);
        }
        return item.copyWith(assignedUserIds: assigned);
      }
      return item;
    }).toList();

    final updatedBill = bill.copyWith(items: updatedItems);
    _updateCache(updatedBill);
    return updatedBill;
  }

  @override
  Future<void> settleBill(String billId) async {
    // TODO: Implement transaction creation logic using WalletRepository
    final bill = _cache[billId];
    if (bill == null) return;

    final settledBill = bill.copyWith(isSettled: true);
    _updateCache(settledBill);
  }

  StreamController<SplitBill> _ensureController(String id) {
    if (!_controllers.containsKey(id)) {
      _controllers[id] = StreamController<SplitBill>.broadcast();
      if (_cache.containsKey(id)) {
        _controllers[id]!.add(_cache[id]!);
      }
    }
    return _controllers[id]!;
  }

  void _updateCache(SplitBill bill) {
    _cache[bill.id] = bill;
    _ensureController(bill.id).add(bill);
  }
}
