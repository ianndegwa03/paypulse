import 'package:equatable/equatable.dart';

enum InvoiceStatus { draft, sent, paid, overdue }

class InvoiceItem extends Equatable {
  final String description;
  final double quantity;
  final double unitPrice;

  const InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;

  @override
  List<Object?> get props => [description, quantity, unitPrice];
}

class Invoice extends Equatable {
  final String id;
  final String userId;
  final String clientName;
  final String clientEmail;
  final DateTime issueDate;
  final DateTime dueDate;
  final List<InvoiceItem> items;
  final String currencyCode;
  final InvoiceStatus status;
  final String? notes;

  const Invoice({
    required this.id,
    required this.userId,
    required this.clientName,
    required this.clientEmail,
    required this.issueDate,
    required this.dueDate,
    required this.items,
    required this.currencyCode,
    this.status = InvoiceStatus.draft,
    this.notes,
  });

  double get totalAmount => items.fold(0, (sum, item) => sum + item.total);

  Invoice copyWith({
    String? id,
    String? userId,
    String? clientName,
    String? clientEmail,
    DateTime? issueDate,
    DateTime? dueDate,
    List<InvoiceItem>? items,
    String? currencyCode,
    InvoiceStatus? status,
    String? notes,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      items: items ?? this.items,
      currencyCode: currencyCode ?? this.currencyCode,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        clientName,
        clientEmail,
        issueDate,
        dueDate,
        items,
        currencyCode,
        status,
        notes,
      ];
}
