import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum BankIntegrationStep { selectBank, enterDetails, verify, confirm, success }

class BankIntegrationFlowScreen extends ConsumerStatefulWidget {
  const BankIntegrationFlowScreen({super.key});

  @override
  ConsumerState<BankIntegrationFlowScreen> createState() =>
      _BankIntegrationFlowScreenState();
}

class _BankIntegrationFlowScreenState
    extends ConsumerState<BankIntegrationFlowScreen> {
  BankIntegrationStep _currentStep = BankIntegrationStep.selectBank;
  String? _selectedBank;
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _routingNumberController =
      TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  bool _isVerifying = false;
  bool _isLinking = false;
  String _linkType = 'bank'; // 'bank' or 'card'

  final List<Map<String, dynamic>> _banks = [
    {'name': 'Chase', 'icon': Icons.account_balance, 'color': Colors.blue},
    {
      'name': 'Bank of America',
      'icon': Icons.account_balance,
      'color': Colors.red
    },
    {
      'name': 'Wells Fargo',
      'icon': Icons.account_balance,
      'color': Colors.orange
    },
    {
      'name': 'Citi Bank',
      'icon': Icons.account_balance,
      'color': Colors.blue.shade900
    },
    {
      'name': 'Capital One',
      'icon': Icons.account_balance,
      'color': Colors.green
    },
    {
      'name': 'M-Pesa',
      'icon': Icons.phone_android,
      'color': Colors.green.shade700
    },
    {
      'name': 'Equity Bank',
      'icon': Icons.account_balance,
      'color': Colors.orange.shade800
    },
    {
      'name': 'KCB',
      'icon': Icons.account_balance,
      'color': Colors.green.shade800
    },
  ];

  @override
  void dispose() {
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() {
      switch (_currentStep) {
        case BankIntegrationStep.selectBank:
          _currentStep = BankIntegrationStep.enterDetails;
          break;
        case BankIntegrationStep.enterDetails:
          _currentStep = BankIntegrationStep.verify;
          _sendVerificationCode();
          break;
        case BankIntegrationStep.verify:
          _currentStep = BankIntegrationStep.confirm;
          break;
        case BankIntegrationStep.confirm:
          _linkAccount();
          break;
        case BankIntegrationStep.success:
          context.pop();
          break;
      }
    });
  }

  void _previousStep() {
    setState(() {
      switch (_currentStep) {
        case BankIntegrationStep.selectBank:
          context.pop();
          break;
        case BankIntegrationStep.enterDetails:
          _currentStep = BankIntegrationStep.selectBank;
          break;
        case BankIntegrationStep.verify:
          _currentStep = BankIntegrationStep.enterDetails;
          break;
        case BankIntegrationStep.confirm:
          _currentStep = BankIntegrationStep.verify;
          break;
        case BankIntegrationStep.success:
          break;
      }
    });
  }

  Future<void> _sendVerificationCode() async {
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isVerifying = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent to your registered phone'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _linkAccount() async {
    setState(() => _isLinking = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isLinking = false;
      _currentStep = BankIntegrationStep.success;
    });
    HapticFeedback.heavyImpact();
  }

  double get _progress {
    switch (_currentStep) {
      case BankIntegrationStep.selectBank:
        return 0.2;
      case BankIntegrationStep.enterDetails:
        return 0.4;
      case BankIntegrationStep.verify:
        return 0.6;
      case BankIntegrationStep.confirm:
        return 0.8;
      case BankIntegrationStep.success:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _currentStep != BankIntegrationStep.success
          ? AppBar(
              title: const Text('Link Account',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              elevation: 0,
              backgroundColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _previousStep,
              ),
            )
          : null,
      body: Column(
        children: [
          // Progress Indicator
          if (_currentStep != BankIntegrationStep.success)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getStepTitle(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Step ${_currentStep.index + 1} of 4',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor:
                          AlwaysStoppedAnimation(theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),

          Expanded(child: _buildStepContent()),
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case BankIntegrationStep.selectBank:
        return 'Select your bank or payment method';
      case BankIntegrationStep.enterDetails:
        return 'Enter your account details';
      case BankIntegrationStep.verify:
        return 'Verify your identity';
      case BankIntegrationStep.confirm:
        return 'Review and confirm';
      case BankIntegrationStep.success:
        return 'Success';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case BankIntegrationStep.selectBank:
        return _buildSelectBankStep();
      case BankIntegrationStep.enterDetails:
        return _buildEnterDetailsStep();
      case BankIntegrationStep.verify:
        return _buildVerifyStep();
      case BankIntegrationStep.confirm:
        return _buildConfirmStep();
      case BankIntegrationStep.success:
        return _buildSuccessStep();
    }
  }

  Widget _buildSelectBankStep() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Link Type Selector
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _linkType = 'bank'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _linkType == 'bank'
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _linkType == 'bank'
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.account_balance_rounded,
                            color: _linkType == 'bank'
                                ? theme.colorScheme.primary
                                : Colors.grey),
                        const SizedBox(height: 8),
                        Text('Bank Account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _linkType == 'bank'
                                  ? theme.colorScheme.primary
                                  : null,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _linkType = 'card'),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _linkType == 'card'
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _linkType == 'card'
                            ? theme.colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.credit_card_rounded,
                            color: _linkType == 'card'
                                ? theme.colorScheme.primary
                                : Colors.grey),
                        const SizedBox(height: 8),
                        Text('Debit/Credit Card',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _linkType == 'card'
                                  ? theme.colorScheme.primary
                                  : null,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          if (_linkType == 'bank') ...[
            Text('Popular Banks',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(
              _banks.length,
              (index) => _buildBankTile(_banks[index]),
            ),
          ] else ...[
            // Card selection goes straight to details
            Center(
              child: Column(
                children: [
                  Icon(Icons.credit_card_rounded,
                      size: 80, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  const Text('Add your card details in the next step'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedBank = 'Card');
                      _nextStep();
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBankTile(Map<String, dynamic> bank) {
    final isSelected = _selectedBank == bank['name'];
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedBank = bank['name']);
        Future.delayed(const Duration(milliseconds: 200), _nextStep);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (bank['color'] as Color).withOpacity(0.1)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? bank['color'] : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (bank['color'] as Color).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(bank['icon'], color: bank['color']),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                bank['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: bank['color']),
          ],
        ),
      ),
    );
  }

  Widget _buildEnterDetailsStep() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your information is encrypted and secure',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (_linkType == 'bank') ...[
            _buildTextField(
              controller: _accountNumberController,
              label: 'Account Number',
              icon: Icons.numbers_rounded,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _routingNumberController,
              label: 'Routing Number',
              icon: Icons.route_rounded,
              keyboardType: TextInputType.number,
            ),
          ] else ...[
            _buildTextField(
              controller: _cardNumberController,
              label: 'Card Number',
              icon: Icons.credit_card_rounded,
              keyboardType: TextInputType.number,
              hintText: '1234 5678 9012 3456',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _expiryController,
                    label: 'Expiry',
                    icon: Icons.date_range_rounded,
                    hintText: 'MM/YY',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _cvvController,
                    label: 'CVV',
                    icon: Icons.security_rounded,
                    keyboardType: TextInputType.number,
                    hintText: '123',
                    obscureText: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _cardHolderController,
              label: 'Cardholder Name',
              icon: Icons.person_outline_rounded,
              hintText: 'As shown on card',
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Continue',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hintText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildVerifyStep() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (_isVerifying) ...[
            const SizedBox(height: 80),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text('Sending verification code...'),
          ] else ...[
            Icon(Icons.verified_user_rounded,
                size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            const Text(
              'Verify Your Identity',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'We sent a verification code to your registered phone number',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _verificationCodeController,
              label: 'Verification Code',
              icon: Icons.dialpad_rounded,
              keyboardType: TextInputType.number,
              hintText: '6-digit code',
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _sendVerificationCode,
              child: const Text('Resend Code'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Verify',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfirmStep() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Details',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildConfirmRow('Account Type',
                    _linkType == 'bank' ? 'Bank Account' : 'Credit/Debit Card'),
                const Divider(height: 32),
                _buildConfirmRow('Institution', _selectedBank ?? 'N/A'),
                const Divider(height: 32),
                _buildConfirmRow(
                  _linkType == 'bank' ? 'Account Number' : 'Card Number',
                  _linkType == 'bank'
                      ? '****${_accountNumberController.text.length > 4 ? _accountNumberController.text.substring(_accountNumberController.text.length - 4) : _accountNumberController.text}'
                      : '****${_cardNumberController.text.length > 4 ? _cardNumberController.text.substring(_cardNumberController.text.length - 4) : _cardNumberController.text}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'By confirming, you authorize PayPulse to link this account for payments.',
                    style:
                        TextStyle(color: Colors.orange.shade700, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLinking ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLinking
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm & Link',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSuccessStep() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  size: 80, color: Colors.green),
            ),
            const SizedBox(height: 32),
            const Text(
              'Account Linked!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Your $_selectedBank account has been successfully linked to PayPulse.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Done',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _currentStep = BankIntegrationStep.selectBank;
                  _selectedBank = null;
                });
              },
              child: const Text('Link Another Account'),
            ),
          ],
        ),
      ),
    );
  }
}
