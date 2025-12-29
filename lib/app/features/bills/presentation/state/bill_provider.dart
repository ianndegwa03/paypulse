import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/domain/entities/bill_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';

class BillState {
  final List<BillEntity> bills;
  final bool isLoading;

  BillState({
    this.bills = const [],
    this.isLoading = false,
  });

  BillState copyWith({
    List<BillEntity>? bills,
    bool? isLoading,
  }) {
    return BillState(
      bills: bills ?? this.bills,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BillNotifier extends StateNotifier<BillState> {
  BillNotifier() : super(BillState()) {
    _initMockBills();
  }

  void _initMockBills() {
    final now = DateTime.now();
    state = state.copyWith(
      bills: [
        BillEntity(
          id: '1',
          title: 'Rent',
          payee: 'Property Management',
          amount: 1200.0,
          currency: CurrencyType.USD,
          dueDate: DateTime(now.year, now.month, 5),
          isPaid: true,
          category: 'Housing',
        ),
        BillEntity(
          id: '2',
          title: 'Electricity',
          payee: 'Power Co',
          amount: 85.50,
          currency: CurrencyType.USD,
          dueDate: DateTime(now.year, now.month, 15),
          isPaid: false,
          category: 'Utilities',
        ),
        BillEntity(
          id: '3',
          title: 'Netflix',
          payee: 'Netflix Inc',
          amount: 15.99,
          currency: CurrencyType.USD,
          dueDate: DateTime(now.year, now.month, 22),
          isPaid: false,
          category: 'Entertainment',
        ),
        BillEntity(
          id: '4',
          title: 'Internet',
          payee: 'TechFiber',
          amount: 60.0,
          currency: CurrencyType.USD,
          dueDate: DateTime(now.year, now.month, 28),
          isPaid: false,
          category: 'Utilities',
        ),
      ],
    );
  }

  void togglePaid(String id) {
    state = state.copyWith(
      bills: state.bills.map((b) {
        if (b.id == id) {
          return BillEntity(
            id: b.id,
            title: b.title,
            payee: b.payee,
            amount: b.amount,
            currency: b.currency,
            dueDate: b.dueDate,
            isPaid: !b.isPaid,
            category: b.category,
          );
        }
        return b;
      }).toList(),
    );
  }
}

final billProvider = StateNotifierProvider<BillNotifier, BillState>((ref) {
  return BillNotifier();
});
