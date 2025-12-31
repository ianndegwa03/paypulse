import 'package:paypulse/domain/entities/split_bill_entity.dart';
import 'package:paypulse/domain/entities/split_item_entity.dart';

abstract class SplitService {
  /// Create a new split bill session
  Future<SplitBill> createSplitBill(
      String title, double totalAmount, String currencyCode);

  /// Add an item to the bill
  Future<SplitBill> addItem(String billId, SplitItem item);

  /// Add a participant to the bill
  Future<SplitBill> addParticipant(String billId, String userId);

  /// Assign an item to a user (toggle assignment)
  Future<SplitBill> toggleItemAssignment(
      String billId, String itemId, String userId);

  /// Settle the bill and create transactions
  Future<void> settleBill(String billId);

  /// Get current bill state
  Stream<SplitBill?> getBillStream(String billId);
}
