// import 'package:another_telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Parsed transaction with additional metadata from SMS
class ParsedSMSTransaction {
  final Transaction transaction;
  final String senderName;
  final String? merchantName;
  final String? transactionCode;
  final String provider; // M-Pesa, Airtel, Bank, etc.
  final double? balance; // Account balance if available
  final String rawMessage;

  ParsedSMSTransaction({
    required this.transaction,
    required this.senderName,
    this.merchantName,
    this.transactionCode,
    required this.provider,
    this.balance,
    required this.rawMessage,
  });
}

/// Analytics summary from SMS data
class SMSAnalyticsSummary {
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> categoryBreakdown;
  final Map<String, double> merchantBreakdown;
  final Map<String, int> transactionsByProvider;
  final List<DailySpending> dailySpending;
  final int totalTransactions;

  SMSAnalyticsSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.categoryBreakdown,
    required this.merchantBreakdown,
    required this.transactionsByProvider,
    required this.dailySpending,
    required this.totalTransactions,
  });

  double get netFlow => totalIncome - totalExpense;
  double get savingsRate =>
      totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome) * 100 : 0;
}

/// Daily spending data point
class DailySpending {
  final DateTime date;
  final double amount;
  final int transactionCount;

  DailySpending({
    required this.date,
    required this.amount,
    required this.transactionCount,
  });
}

/// Simplified message model for mock data
class MockSmsMessage {
  final String? address;
  final String? body;
  final int? date;
  final int? id;

  MockSmsMessage({
    this.address,
    this.body,
    this.date,
    this.id,
  });
}

/// Enhanced SMS Service with comprehensive parsing for African financial services
class SMSService {
  // final Telephony telephony = Telephony.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // M-PESA PATTERNS (Kenya - Safaricom)
  // ═══════════════════════════════════════════════════════════════════════════

  // M-PESA Received: "QA12BC34DE Confirmed. You have received Ksh1,200.00 from JOHN DOE 0712345678"
  static final _mpesaReceivedRegex = RegExp(
    r'([A-Z0-9]{10})\s+Confirmed\.?\s+You have received\s+Ksh\s?([\d,]+\.?\d*)\s+from\s+([A-Z\s]+)\s+(\d+)',
    caseSensitive: false,
  );

  // M-PESA Sent: "QA12BC34DE Confirmed. Ksh500.00 sent to JANE DOE 0712345678"
  static final _mpesaSentRegex = RegExp(
    r'([A-Z0-9]{10})\s+Confirmed\.?\s+Ksh\s?([\d,]+\.?\d*)\s+sent to\s+([A-Z\s]+)?\s*(\d+)?',
    caseSensitive: false,
  );

  // M-PESA Paybill: "QA12BC34DE Confirmed. Ksh1,000.00 sent to KENYA POWER for account 12345"
  static final _mpesaPaybillRegex = RegExp(
    r'([A-Z0-9]{10})\s+Confirmed\.?\s+Ksh\s?([\d,]+\.?\d*)\s+(?:sent to|paid to)\s+([A-Z0-9\s]+?)(?:\s+for account\s+(\S+))?',
    caseSensitive: false,
  );

  // M-PESA Buy Goods: "QA12BC34DE Confirmed. Ksh250.00 paid to JAVA HOUSE"
  static final _mpesaBuyGoodsRegex = RegExp(
    r'([A-Z0-9]{10})\s+Confirmed\.?\s+Ksh\s?([\d,]+\.?\d*)\s+paid to\s+([A-Z0-9\s]+)',
    caseSensitive: false,
  );

  // M-PESA Balance check in message
  static final _mpesaBalanceRegex = RegExp(
    r'balance\s+(?:is|was)?\s*Ksh\s?([\d,]+\.?\d*)',
    caseSensitive: false,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // AIRTEL MONEY PATTERNS (Kenya/Africa)
  // ═══════════════════════════════════════════════════════════════════════════

  static final _airtelReceivedRegex = RegExp(
    r'You have received\s+KES\s?([\d,]+\.?\d*)\s+from\s+([A-Z\s]+)',
    caseSensitive: false,
  );

  static final _airtelSentRegex = RegExp(
    r'You have sent\s+KES\s?([\d,]+\.?\d*)\s+to\s+([A-Z\s\d]+)',
    caseSensitive: false,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BANK SMS PATTERNS (KCB, Equity, Standard Chartered, etc.)
  // ═══════════════════════════════════════════════════════════════════════════

  // Generic bank credit
  static final _bankCreditRegex = RegExp(
    r'(?:credited|deposited|received)\s+(?:KES|Ksh|NGN|ZAR|R)?\s?([\d,]+\.?\d*)',
    caseSensitive: false,
  );

  // Generic bank debit
  static final _bankDebitRegex = RegExp(
    r'(?:debited|withdrawn|purchased|paid)\s+(?:KES|Ksh|NGN|ZAR|R)?\s?([\d,]+\.?\d*)',
    caseSensitive: false,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // NIGERIAN PATTERNS
  // ═══════════════════════════════════════════════════════════════════════════

  static final _nigerianBankRegex = RegExp(
    r'(?:NGN|₦)\s?([\d,]+\.?\d*)\s+(?:credited|debited|transferred)',
    caseSensitive: false,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SOUTH AFRICAN PATTERNS
  // ═══════════════════════════════════════════════════════════════════════════

  static final _sarBankRegex = RegExp(
    r'(?:ZAR|R)\s?([\d,]+\.?\d*)\s+(?:credited|debited|paid)',
    caseSensitive: false,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // PERMISSIONS
  // ═══════════════════════════════════════════════════════════════════════════

  Future<bool> requestPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    return await Permission.sms.isGranted;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MAIN PARSING METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get all financial transactions from SMS
  Future<List<ParsedSMSTransaction>> getFinancialTransactions({
    DateTime? since,
    int limit = 500,
  }) async {
    bool granted = await requestPermission();
    if (!granted) return [];

    /*
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [
        SmsColumn.ADDRESS,
        SmsColumn.BODY,
        SmsColumn.DATE,
        SmsColumn.ID
      ],
    );
    */
    List<MockSmsMessage> messages = _getMockMessages();

    List<ParsedSMSTransaction> transactions = [];

    for (var msg in messages) {
      if (limit > 0 && transactions.length >= limit) break;

      final date = DateTime.fromMillisecondsSinceEpoch(
        msg.date ?? DateTime.now().millisecondsSinceEpoch,
      );

      // Filter by date if specified
      if (since != null && date.isBefore(since)) continue;

      final tx = _parseMessage(msg);
      if (tx != null) {
        transactions.add(tx);
      }
    }

    // Sort by date descending
    transactions
        .sort((a, b) => b.transaction.date.compareTo(a.transaction.date));

    return transactions;
  }

  /// Get analytics summary
  Future<SMSAnalyticsSummary> getAnalyticsSummary({
    DateTime? since,
    int limit = 500,
  }) async {
    final transactions =
        await getFinancialTransactions(since: since, limit: limit);

    double totalIncome = 0;
    double totalExpense = 0;
    final categoryBreakdown = <String, double>{};
    final merchantBreakdown = <String, double>{};
    final transactionsByProvider = <String, int>{};
    final dailySpendingMap = <String, DailySpending>{};

    for (var tx in transactions) {
      final amount = tx.transaction.amount;
      final isCredit = tx.transaction.type == TransactionType.credit;

      if (isCredit) {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }

      // Category breakdown
      final category = tx.transaction.categoryId;
      categoryBreakdown[category] = (categoryBreakdown[category] ?? 0) + amount;

      // Merchant breakdown
      if (tx.merchantName != null && !isCredit) {
        merchantBreakdown[tx.merchantName!] =
            (merchantBreakdown[tx.merchantName!] ?? 0) + amount;
      }

      // Provider count
      transactionsByProvider[tx.provider] =
          (transactionsByProvider[tx.provider] ?? 0) + 1;

      // Daily spending
      if (!isCredit) {
        final dateKey = _formatDateKey(tx.transaction.date);
        final existing = dailySpendingMap[dateKey];
        dailySpendingMap[dateKey] = DailySpending(
          date: DateTime(
            tx.transaction.date.year,
            tx.transaction.date.month,
            tx.transaction.date.day,
          ),
          amount: (existing?.amount ?? 0) + amount,
          transactionCount: (existing?.transactionCount ?? 0) + 1,
        );
      }
    }

    // Sort daily spending by date
    final dailySpending = dailySpendingMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return SMSAnalyticsSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      categoryBreakdown: categoryBreakdown,
      merchantBreakdown: merchantBreakdown,
      transactionsByProvider: transactionsByProvider,
      dailySpending: dailySpending,
      totalTransactions: transactions.length,
    );
  }

  String _formatDateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Parse a single SMS message
  ParsedSMSTransaction? _parseMessage(MockSmsMessage msg) {
    final body = msg.body ?? '';
    final address = msg.address?.toLowerCase() ?? '';
    final bodyLower = body.toLowerCase();

    // Determine provider
    String provider = 'Unknown';
    if (address.contains('mpesa') || bodyLower.contains('mpesa')) {
      provider = 'M-Pesa';
    } else if (address.contains('airtel') || bodyLower.contains('airtel')) {
      provider = 'Airtel Money';
    } else if (address.contains('equity') || bodyLower.contains('equity')) {
      provider = 'Equity Bank';
    } else if (address.contains('kcb') || bodyLower.contains('kcb')) {
      provider = 'KCB Bank';
    } else if (address.contains('stanchart') ||
        bodyLower.contains('standard chartered')) {
      provider = 'Standard Chartered';
    } else if (bodyLower.contains('bank')) {
      provider = 'Bank';
    }

    // Try M-PESA patterns first
    var result = _tryParseMPesa(msg, body, provider);
    if (result != null) return result;

    // Try Airtel patterns
    result = _tryParseAirtel(msg, body, provider);
    if (result != null) return result;

    // Try bank patterns
    result = _tryParseBank(msg, body, address, provider);
    if (result != null) return result;

    return null;
  }

  ParsedSMSTransaction? _tryParseMPesa(
    MockSmsMessage msg,
    String body,
    String provider,
  ) {
    // M-Pesa Received
    var match = _mpesaReceivedRegex.firstMatch(body);
    if (match != null) {
      return _createTransaction(
        msg: msg,
        body: body,
        amount: _parseAmount(match.group(2)!),
        isCredit: true,
        transactionCode: match.group(1),
        senderName: match.group(3)?.trim() ?? 'Unknown',
        provider: 'M-Pesa',
        currency: CurrencyType.KES,
      );
    }

    // M-Pesa Sent
    match = _mpesaSentRegex.firstMatch(body);
    if (match != null) {
      return _createTransaction(
        msg: msg,
        body: body,
        amount: _parseAmount(match.group(2)!),
        isCredit: false,
        transactionCode: match.group(1),
        senderName: match.group(3)?.trim() ?? 'Unknown',
        provider: 'M-Pesa',
        currency: CurrencyType.KES,
      );
    }

    // M-Pesa Buy Goods / Paybill
    match = _mpesaPaybillRegex.firstMatch(body);
    if (match == null) {
      match = _mpesaBuyGoodsRegex.firstMatch(body);
    }
    if (match != null) {
      final merchantName = match.group(3)?.trim();
      return _createTransaction(
        msg: msg,
        body: body,
        amount: _parseAmount(match.group(2)!),
        isCredit: false,
        transactionCode: match.group(1),
        senderName: merchantName ?? 'Merchant',
        merchantName: merchantName,
        provider: 'M-Pesa',
        currency: CurrencyType.KES,
        category: _categorizeMerchant(merchantName ?? ''),
      );
    }

    return null;
  }

  ParsedSMSTransaction? _tryParseAirtel(
    MockSmsMessage msg,
    String body,
    String provider,
  ) {
    // Airtel Received
    var match = _airtelReceivedRegex.firstMatch(body);
    if (match != null) {
      return _createTransaction(
        msg: msg,
        body: body,
        amount: _parseAmount(match.group(1)!),
        isCredit: true,
        senderName: match.group(2)?.trim() ?? 'Unknown',
        provider: 'Airtel Money',
        currency: CurrencyType.KES,
      );
    }

    // Airtel Sent
    match = _airtelSentRegex.firstMatch(body);
    if (match != null) {
      return _createTransaction(
        msg: msg,
        body: body,
        amount: _parseAmount(match.group(1)!),
        isCredit: false,
        senderName: match.group(2)?.trim() ?? 'Unknown',
        provider: 'Airtel Money',
        currency: CurrencyType.KES,
      );
    }

    return null;
  }

  ParsedSMSTransaction? _tryParseBank(
    MockSmsMessage msg,
    String body,
    String address,
    String provider,
  ) {
    final bodyLower = body.toLowerCase();

    // Determine currency based on content
    CurrencyType currency = CurrencyType.KES;
    if (bodyLower.contains('ngn') || bodyLower.contains('₦')) {
      currency = CurrencyType.NGN;
    } else if (bodyLower.contains('zar') ||
        address.contains('fnb') ||
        address.contains('absa')) {
      currency = CurrencyType.ZAR;
    }

    // Try Nigerian bank pattern
    var match = _nigerianBankRegex.firstMatch(body);
    if (match != null) {
      final isCredit = bodyLower.contains('credited');
      return _createTransaction(
        msg: msg,
        body: body,
        amount: _parseAmount(match.group(1)!),
        isCredit: isCredit,
        senderName: 'Bank',
        provider: provider,
        currency: CurrencyType.NGN,
      );
    }

    // Try SA bank pattern
    match = _sarBankRegex.firstMatch(body);
    if (match != null) {
      final isCredit = bodyLower.contains('credited');
      return _createTransaction(
        msg: msg,
        body: body,
        amount: _parseAmount(match.group(1)!),
        isCredit: isCredit,
        senderName: 'Bank',
        provider: provider,
        currency: CurrencyType.ZAR,
      );
    }

    // Generic bank credit/debit
    match = _bankCreditRegex.firstMatch(body);
    if (match != null) {
      return _createTransaction(
        msg: msg,
        body: body,
        amount: _parseAmount(match.group(1)!),
        isCredit: true,
        senderName: 'Bank',
        provider: provider,
        currency: currency,
      );
    }

    match = _bankDebitRegex.firstMatch(body);
    if (match != null) {
      return _createTransaction(
        msg: msg,
        body: body,
        amount: _parseAmount(match.group(1)!),
        isCredit: false,
        senderName: 'Merchant/Payee',
        provider: provider,
        currency: currency,
      );
    }

    return null;
  }

  ParsedSMSTransaction _createTransaction({
    required MockSmsMessage msg,
    required String body,
    required double amount,
    required bool isCredit,
    String? transactionCode,
    required String senderName,
    String? merchantName,
    required String provider,
    required CurrencyType currency,
    String? category,
  }) {
    // Try to extract balance
    double? balance;
    final balanceMatch = _mpesaBalanceRegex.firstMatch(body);
    if (balanceMatch != null) {
      balance = _parseAmount(balanceMatch.group(1)!);
    }

    final transaction = Transaction(
      id: 'sms_${msg.id ?? DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      description:
          _buildDescription(senderName, merchantName, isCredit, provider),
      date: DateTime.fromMillisecondsSinceEpoch(
        msg.date ?? DateTime.now().millisecondsSinceEpoch,
      ),
      categoryId: category ?? _categorizeByContent(body),
      paymentMethodId: 'SMS_IMPORT',
      type: isCredit ? TransactionType.credit : TransactionType.debit,
      currencyCode: currency.name,
      status: TransactionStatus.completed,
    );

    return ParsedSMSTransaction(
      transaction: transaction,
      senderName: senderName,
      merchantName: merchantName,
      transactionCode: transactionCode,
      provider: provider,
      balance: balance,
      rawMessage: body,
    );
  }

  double _parseAmount(String amountStr) {
    return double.parse(amountStr.replaceAll(',', '').replaceAll(' ', ''));
  }

  String _buildDescription(
    String senderName,
    String? merchantName,
    bool isCredit,
    String provider,
  ) {
    if (merchantName != null) {
      return 'Payment to $merchantName';
    }
    if (isCredit) {
      return 'Received from $senderName via $provider';
    }
    return 'Sent to $senderName via $provider';
  }

  String _categorizeMerchant(String merchantName) {
    final lower = merchantName.toLowerCase();

    // Food & Dining
    if (_matchesAny(lower, [
      'java',
      'kfc',
      'subway',
      'pizza',
      'restaurant',
      'cafe',
      'food',
      'chicken',
      'burger',
      'grill',
      'kitchen',
      'deli',
      'bakery'
    ])) return 'Dining';

    // Transport
    if (_matchesAny(lower, [
      'uber',
      'bolt',
      'little',
      'shell',
      'total',
      'petrol',
      'fuel',
      'parking',
      'taxi',
      'matatu'
    ])) return 'Transport';

    // Utilities
    if (_matchesAny(lower, [
      'kenya power',
      'kplc',
      'safaricom',
      'airtel',
      'telkom',
      'nairobi water',
      'dstv',
      'zuku',
      'gotv'
    ])) return 'Utilities';

    // Shopping
    if (_matchesAny(lower, [
      'naivas',
      'carrefour',
      'quickmart',
      'tuskys',
      'nakumatt',
      'shoprite',
      'game',
      'woolworths',
      'pick n pay'
    ])) return 'Shopping';

    // Entertainment
    if (_matchesAny(lower, [
      'netflix',
      'spotify',
      'showmax',
      'cinema',
      'imax',
      'betway',
      'sportpesa',
      'betting'
    ])) return 'Entertainment';

    // Healthcare
    if (_matchesAny(lower, [
      'hospital',
      'clinic',
      'pharmacy',
      'chemist',
      'medical',
      'health'
    ])) return 'Healthcare';

    // Education
    if (_matchesAny(
        lower, ['school', 'university', 'college', 'academy', 'tuition']))
      return 'Education';

    return 'General';
  }

  String _categorizeByContent(String body) {
    final lower = body.toLowerCase();

    if (_matchesAny(lower, ['food', 'restaurant', 'cafe', 'meal'])) {
      return 'Dining';
    }
    if (_matchesAny(lower, ['uber', 'bolt', 'fuel', 'petrol', 'parking'])) {
      return 'Transport';
    }
    if (_matchesAny(
        lower, ['airtel', 'safaricom', 'bundle', 'power', 'water'])) {
      return 'Utilities';
    }
    if (_matchesAny(lower, ['netflix', 'spotify', 'showmax', 'betting'])) {
      return 'Entertainment';
    }
    if (_matchesAny(lower, ['hospital', 'pharmacy', 'clinic'])) {
      return 'Healthcare';
    }
    if (_matchesAny(lower, ['school', 'tuition', 'college'])) {
      return 'Education';
    }

    return 'General';
  }

  bool _matchesAny(String text, List<String> keywords) {
    return keywords.any((k) => text.contains(k));
  }

  List<MockSmsMessage> _getMockMessages() {
    return [];
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════

final smsServiceProvider = Provider((ref) => SMSService());

/// Parsed SMS transactions
final smsTransactionsProvider =
    FutureProvider<List<ParsedSMSTransaction>>((ref) async {
  final service = ref.watch(smsServiceProvider);
  return service.getFinancialTransactions(
    since: DateTime.now().subtract(const Duration(days: 90)),
  );
});

/// Legacy provider for backward compatibility
final legacySmsTransactionsProvider =
    FutureProvider<List<Transaction>>((ref) async {
  final parsed = await ref.watch(smsTransactionsProvider.future);
  return parsed.map((p) => p.transaction).toList();
});

/// SMS analytics summary
final smsAnalyticsProvider = FutureProvider<SMSAnalyticsSummary>((ref) async {
  final service = ref.watch(smsServiceProvider);
  return service.getAnalyticsSummary(
    since: DateTime.now().subtract(const Duration(days: 30)),
  );
});

/// Auto-refreshing SMS analytics (refreshes when app comes to foreground)
final refreshableSmsAnalyticsProvider =
    FutureProvider.autoDispose<SMSAnalyticsSummary>((ref) async {
  final service = ref.watch(smsServiceProvider);
  return service.getAnalyticsSummary(
    since: DateTime.now().subtract(const Duration(days: 30)),
  );
});

/// SMS permission status
final smsPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(smsServiceProvider);
  return service.hasPermission();
});
