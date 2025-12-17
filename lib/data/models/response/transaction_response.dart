import 'package:equatable/equatable.dart';

/// Response model for transaction operations
class TransactionResponse extends Equatable {
  final String? id;
  final String? walletId;
  final String? type;
  final String? category;
  final double? amount;
  final String? currency;
  final String? description;
  final String? reference;
  final String? status;
  final String? recipient;
  final String? sender;
  final DateTime? transactionDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? metadata;
  final String? message;
  final bool success;

  const TransactionResponse({
    this.id,
    this.walletId,
    this.type,
    this.category,
    this.amount,
    this.currency,
    this.description,
    this.reference,
    this.status,
    this.recipient,
    this.sender,
    this.transactionDate,
    this.createdAt,
    this.updatedAt,
    this.metadata,
    this.message,
    this.success = true,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      id: json['id'] as String?,
      walletId: json['wallet_id'] as String? ?? json['walletId'] as String?,
      type: json['type'] as String?,
      category: json['category'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      status: json['status'] as String? ?? 'completed',
      recipient: json['recipient'] as String?,
      sender: json['sender'] as String?,
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'type': type,
      'category': category,
      'amount': amount,
      'currency': currency,
      'description': description,
      'reference': reference,
      'status': status,
      'recipient': recipient,
      'sender': sender,
      'transaction_date': transactionDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
      'message': message,
      'success': success,
    };
  }

  /// Check if transaction is credit (incoming)
  bool get isCredit =>
      type?.toLowerCase() == 'credit' ||
      type?.toLowerCase() == 'deposit' ||
      type?.toLowerCase() == 'receive';

  /// Check if transaction is debit (outgoing)
  bool get isDebit =>
      type?.toLowerCase() == 'debit' ||
      type?.toLowerCase() == 'withdrawal' ||
      type?.toLowerCase() == 'send';

  /// Format amount with currency symbol
  String get formattedAmount {
    final currencySymbol = _getCurrencySymbol(currency ?? 'USD');
    final sign = isDebit ? '-' : '+';
    return '$sign$currencySymbol${amount?.abs().toStringAsFixed(2) ?? '0.00'}';
  }

  String _getCurrencySymbol(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'KES':
        return 'KSh';
      default:
        return currencyCode;
    }
  }

  @override
  List<Object?> get props => [
        id,
        walletId,
        type,
        category,
        amount,
        currency,
        description,
        reference,
        status,
        recipient,
        sender,
        transactionDate,
        createdAt,
        updatedAt,
        metadata,
        message,
        success,
      ];
}

/// Response for list of transactions
class TransactionsListResponse extends Equatable {
  final List<TransactionResponse> transactions;
  final int? total;
  final int? page;
  final int? pageSize;
  final bool success;
  final String? message;

  const TransactionsListResponse({
    required this.transactions,
    this.total,
    this.page,
    this.pageSize,
    this.success = true,
    this.message,
  });

  factory TransactionsListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> transactionsJson =
        json['transactions'] as List? ?? json['data'] as List? ?? [];
    return TransactionsListResponse(
      transactions: transactionsJson
          .map((e) => TransactionResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int?,
      page: json['page'] as int?,
      pageSize: json['page_size'] as int? ?? json['pageSize'] as int?,
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
    );
  }

  @override
  List<Object?> get props =>
      [transactions, total, page, pageSize, success, message];
}
