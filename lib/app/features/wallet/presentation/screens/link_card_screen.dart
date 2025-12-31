import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'package:paypulse/core/theme/app_colors.dart';
import 'package:paypulse/domain/entities/card_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'dart:math';

class LinkCardScreen extends ConsumerStatefulWidget {
  const LinkCardScreen({super.key});

  @override
  ConsumerState<LinkCardScreen> createState() => _LinkCardScreenState();
}

class _LinkCardScreenState extends ConsumerState<LinkCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authState = ref.read(authNotifierProvider);
      final userId = authState.currentUser?.id ?? authState.userId;

      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not authenticated")),
        );
        setState(() => _isLoading = false);
        return;
      }

      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final lastFour = cardNumber.substring(cardNumber.length - 4);
      final expiry = _expiryController.text;
      final holder = _cardHolderController.text;

      // Simple card type detection logic (placeholder for real bin lookup)
      CardType type = CardType.visa;
      if (cardNumber.startsWith('5')) type = CardType.mastercard;

      final newCard = CardEntity(
        id: '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}',
        userId: userId,
        lastFour: lastFour,
        expiryDate: expiry,
        cardHolderName: holder,
        type: type,
        isDefault: true,
      );

      await ref.read(walletStateProvider.notifier).linkCard(newCard);

      if (mounted) {
        setState(() => _isLoading = false);
        context.pop(); // Go back to home
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.iconTheme.color),
          onPressed: () => context.pop(),
        ),
        title: Text("Link Card",
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardPreview(theme),
              const SizedBox(height: 32),
              _buildLabel("Card Number", theme),
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                decoration: _inputDecoration("0000 0000 0000 0000", theme),
                validator: (value) {
                  if (value == null || value.length < 19)
                    return "Invalid card number"; // 16 digits + 3 spaces
                  return null;
                },
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Expiry Date", theme),
                        TextFormField(
                          controller: _expiryController,
                          keyboardType: TextInputType.datetime,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                            _DateFormatter(),
                          ],
                          decoration: _inputDecoration("MM/YY", theme),
                          validator: (value) {
                            if (value == null || value.length < 5)
                              return "Invalid";
                            return null;
                          },
                          onChanged: (val) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("CVV", theme),
                        TextFormField(
                          controller: _cvvController,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          decoration: _inputDecoration("123", theme),
                          validator: (value) {
                            if (value == null || value.length < 3)
                              return "Invalid";
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildLabel("Cardholder Name", theme),
              TextFormField(
                controller: _cardHolderController,
                textCapitalization: TextCapitalization.characters,
                decoration: _inputDecoration("JOHN DOE", theme),
                validator: (value) =>
                    value == null || value.isEmpty ? "Required" : null,
                onChanged: (val) => setState(() {}),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text("Securely Link Card",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded,
                        size: 14, color: Colors.grey.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Text("Your payment info is stored securely.",
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: theme.textTheme.bodyMedium
              ?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  InputDecoration _inputDecoration(String hint, ThemeData theme) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: theme.cardColor,
      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2)),
    );
  }

  Widget _buildCardPreview(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.premiumGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text("Debit Card", style: TextStyle(color: Colors.white70)),
            Icon(Icons.contactless_rounded,
                color: Colors.white.withOpacity(0.8)),
          ]),
          Text(
            _cardNumberController.text.isEmpty
                ? "0000 0000 0000 0000"
                : _cardNumberController.text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 2),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("CARD HOLDER",
                  style: TextStyle(color: Colors.white60, fontSize: 10)),
              Text(
                  _cardHolderController.text.isEmpty
                      ? "YOUR NAME"
                      : _cardHolderController.text.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("EXPIRES",
                  style: TextStyle(color: Colors.white60, fontSize: 10)),
              Text(
                  _expiryController.text.isEmpty
                      ? "MM/YY"
                      : _expiryController.text,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ],
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length)
        buffer.write(' ');
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}

class _DateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != text.length)
        buffer.write('/');
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
