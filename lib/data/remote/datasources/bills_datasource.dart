import 'package:paypulse/data/models/bill_model.dart';
import 'package:paypulse/domain/entities/enums.dart';

abstract class BillsDataSource {
  Future<List<BillModel>> getBills();
  Future<void> payBill(String billId);
}

class BillsDataSourceImpl implements BillsDataSource {
  @override
  Future<List<BillModel>> getBills() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 700));
    return [
      BillModel(
        id: '1',
        title: 'Electricity Bill',
        payee: 'City Power',
        amount: 150.0,
        currency: CurrencyType.USD,
        dueDate: DateTime.now().add(const Duration(days: 5)),
        category: 'Utilities',
      ),
      BillModel(
        id: '2',
        title: 'Internet Subscription',
        payee: 'FiberNet',
        amount: 80.0,
        currency: CurrencyType.USD,
        dueDate: DateTime.now().add(const Duration(days: 12)),
        category: 'internet',
      ),
    ];
  }

  @override
  Future<void> payBill(String billId) async {
    await Future.delayed(const Duration(milliseconds: 1500));
  }
}
