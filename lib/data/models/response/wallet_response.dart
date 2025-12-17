import 'package:equatable/equatable.dart';

/// Response model for wallet operations
class WalletResponse extends Equatable {
  final String? id;
  final String? name;
  final String? currency;
  final double? balance;
  final double? availableBalance;
  final String? walletType;
  final String? status;
  final String? accountNumber;
  final String? bankName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDefault;
  final bool? isActive;
  final String? message;
  final bool success;

  const WalletResponse({
    this.id,
    this.name,
    this.currency,
    this.balance,
    this.availableBalance,
    this.walletType,
    this.status,
    this.accountNumber,
    this.bankName,
    this.createdAt,
    this.updatedAt,
    this.isDefault,
    this.isActive,
    this.message,
    this.success = true,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      id: json['id'] as String?,
      name: json['name'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      balance: (json['balance'] as num?)?.toDouble(),
      availableBalance: (json['available_balance'] as num?)?.toDouble() ??
          (json['availableBalance'] as num?)?.toDouble(),
      walletType:
          json['wallet_type'] as String? ?? json['walletType'] as String?,
      status: json['status'] as String?,
      accountNumber:
          json['account_number'] as String? ?? json['accountNumber'] as String?,
      bankName: json['bank_name'] as String? ?? json['bankName'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isDefault: json['is_default'] as bool? ?? json['isDefault'] as bool?,
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'balance': balance,
      'available_balance': availableBalance,
      'wallet_type': walletType,
      'status': status,
      'account_number': accountNumber,
      'bank_name': bankName,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_default': isDefault,
      'is_active': isActive,
      'message': message,
      'success': success,
    };
  }

  /// Format balance with currency symbol
  String get formattedBalance {
    final currencySymbol = _getCurrencySymbol(currency ?? 'USD');
    return '$currencySymbol${balance?.toStringAsFixed(2) ?? '0.00'}';
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
        name,
        currency,
        balance,
        availableBalance,
        walletType,
        status,
        accountNumber,
        bankName,
        createdAt,
        updatedAt,
        isDefault,
        isActive,
        message,
        success,
      ];
}

/// Response for list of wallets
class WalletsListResponse extends Equatable {
  final List<WalletResponse> wallets;
  final int? total;
  final bool success;
  final String? message;

  const WalletsListResponse({
    required this.wallets,
    this.total,
    this.success = true,
    this.message,
  });

  factory WalletsListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> walletsJson =
        json['wallets'] as List? ?? json['data'] as List? ?? [];
    return WalletsListResponse(
      wallets: walletsJson
          .map((e) => WalletResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int?,
      success: json['success'] as bool? ?? true,
      message: json['message'] as String?,
    );
  }

  @override
  List<Object?> get props => [wallets, total, success, message];
}
