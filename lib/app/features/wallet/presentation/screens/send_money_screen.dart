import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:paypulse/app/features/contacts/presentation/state/contacts_provider.dart';
import 'package:paypulse/app/features/wallet/presentation/state/currency_provider.dart';
import 'package:paypulse/domain/entities/enums.dart';
import 'dart:ui';

class SendMoneyScreen extends ConsumerStatefulWidget {
  final Contact? initialContact;

  const SendMoneyScreen({super.key, this.initialContact});

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  String _amount = "0";
  Contact? _selectedContact;
  bool _isPriority = false;
  bool _isPrivate = true;
  bool _isScheduled = false;
  DateTime? _scheduledDate;
  String _note = "";

  @override
  void initState() {
    super.initState();
    _selectedContact = widget.initialContact;
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutQuart);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutQuart);
    } else {
      Navigator.pop(context);
    }
  }

  void _onKeyPress(String val) {
    HapticFeedback.lightImpact();
    setState(() {
      if (val == "back") {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = "0";
        }
      } else if (val == ".") {
        if (!_amount.contains(".")) {
          _amount += ".";
        }
      } else {
        if (_amount == "0") {
          _amount = val;
        } else {
          if (_amount.contains(".") && _amount.split(".")[1].length >= 2)
            return;
          _amount += val;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currencyState = ref.watch(currencyProvider);
    final metadata = getCurrencyMetadata(currencyState.selectedCurrency);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Theme-aligned background accent
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
                    theme.colorScheme.primary.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildAnimatedProgressBar(theme),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) => setState(() => _currentStep = idx),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = _pageController.page! - index;
                            value = (1 - (value.abs() * 0.4)).clamp(0.0, 1.0);
                          }
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(
                              scale: 0.85 + (value * 0.15),
                              child: child,
                            ),
                          );
                        },
                        child: _getStepWidget(
                            index, metadata, currencyState, theme),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getStepWidget(int index, CurrencyMetadata metadata,
      CurrencyState currencyState, ThemeData theme) {
    switch (index) {
      case 0:
        return _buildAmountStep(metadata, currencyState, theme);
      case 1:
        return _buildContactStep(theme);
      case 2:
        return _buildOptionsStep(theme);
      case 3:
        return _buildReviewStep(theme, metadata, currencyState);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: theme.colorScheme.onSurface, size: 16),
            ),
            onPressed: _prevStep,
          ),
          Column(
            children: [
              Text(
                "PAYPULSE TERMINAL",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _getStepTitle(),
                  key: ValueKey(_currentStep),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 48), // Balance for symmetry
        ],
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return "Set Amount";
      case 1:
        return "Recipient";
      case 2:
        return "Refinements";
      case 3:
        return "Execution";
      default:
        return "";
    }
  }

  Widget _buildAnimatedProgressBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: Row(
        children: List.generate(4, (index) {
          final active = index <= _currentStep;
          final current = index == _currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: current ? 6 : 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: active
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(3),
                boxShadow: current
                    ? [
                        BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8)
                      ]
                    : [],
              ),
            ),
          );
        }),
      ),
    );
  }

  // STEP 1: AMOUNT
  Widget _buildAmountStep(
      CurrencyMetadata metadata, CurrencyState currencyState, ThemeData theme) {
    final double amtVal = double.tryParse(_amount) ?? 0;
    final double converted = amtVal *
        (currencyState.exchangeRates[currencyState.selectedCurrency] ?? 1.0);

    return Column(
      children: [
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(metadata.symbol,
                style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Text(
                _amount,
                key: ValueKey(_amount),
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w900,
                  fontSize: 80,
                  letterSpacing: -5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showCurrencyPicker(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(currencyState.selectedCurrency.name,
                    style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(width: 8),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.primary, size: 18),
              ],
            ),
          ),
        ),
        if (currencyState.selectedCurrency != CurrencyType.USD)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
                "≈ ${metadata.symbol}${converted.toStringAsFixed(2)} local equilibrium",
                style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                    fontWeight: FontWeight.bold)),
          ),
        const Spacer(),
        _buildControlHub(context, theme, currencyState,
            onPrimary: _nextStep, label: "VERIFY LIQUIDITY"),
      ],
    );
  }

  // STEP 2: CONTACT
  Widget _buildContactStep(ThemeData theme) {
    final contactsAsync = ref.watch(contactsProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: TextField(
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                hintText: "Search name, handle or phone...",
                hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.2),
                    fontWeight: FontWeight.w700),
                prefixIcon: Icon(Icons.search_rounded,
                    color: theme.colorScheme.primary.withOpacity(0.5)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
          ),
        ),
        Expanded(
          child: contactsAsync.when(
            data: (contacts) => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final isSelected = _selectedContact?.id == contact.id;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedContact = contact);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : theme.dividerColor.withOpacity(0.05)),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 10))
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : theme.colorScheme.primary.withOpacity(0.1),
                          child: Text(contact.displayName[0],
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(contact.displayName,
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16)),
                              Text("PayPulse Verified Node",
                                  style: TextStyle(
                                      color: isSelected
                                          ? Colors.white70
                                          : theme.colorScheme.onSurface
                                              .withOpacity(0.4),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.verified_rounded,
                              color: Colors.white, size: 24),
                      ],
                    ),
                  ),
                );
              },
            ),
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Center(child: Text("Sync unavailable")),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: _premiumButton(
            theme: theme,
            onPressed: _selectedContact != null ? _nextStep : null,
            label: "ESTABLISH CONNECT",
          ),
        ),
      ],
    );
  }

  // STEP 3: OPTIONS
  Widget _buildOptionsStep(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(theme, "PROTOCOL PARAMS"),
          const SizedBox(height: 16),
          _buildOptionTile(
              theme,
              "FLASH SEND",
              _isPriority,
              Icons.bolt_rounded,
              "Top-tier network priority",
              () => setState(() => _isPriority = !_isPriority)),
          const SizedBox(height: 16),
          _buildOptionTile(
              theme,
              "STEALTH PROTOCOL",
              _isPrivate,
              Icons.visibility_off_rounded,
              "Encrypted sender identity",
              () => setState(() => _isPrivate = !_isPrivate)),
          const SizedBox(height: 40),
          _sectionTitle(theme, "SCHEDULING & REMARKS"),
          const SizedBox(height: 16),
          _buildOptionTile(
              theme,
              _isScheduled
                  ? "SET: ${_scheduledDate!.day}/${_scheduledDate!.month}"
                  : "INSTANT DELIVERY",
              _isScheduled,
              Icons.calendar_today_rounded,
              "Automated time-lock execution", () async {
            final d = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)));
            if (d != null)
              setState(() {
                _scheduledDate = d;
                _isScheduled = true;
              });
          }),
          const SizedBox(height: 16),
          _buildOptionTile(
              theme,
              _note.isEmpty ? "ATTACH REMARK" : "REMARK ATTACHED",
              _note.isNotEmpty,
              Icons.sticky_note_2_rounded,
              "Digital paper trail integration",
              () => _showNoteDialog(theme)),
          const Spacer(),
          _premiumButton(
              theme: theme, onPressed: _nextStep, label: "FINALIZE CONFIG"),
        ],
      ),
    );
  }

  Widget _sectionTitle(ThemeData theme, String title) {
    return Text(title,
        style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 2));
  }

  Widget _buildOptionTile(ThemeData theme, String title, bool active,
      IconData icon, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
              color: active
                  ? Colors.transparent
                  : theme.dividerColor.withOpacity(0.05)),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8))
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withOpacity(0.2)
                      : theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle),
              child: Icon(icon,
                  color: active ? Colors.white : theme.colorScheme.primary,
                  size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: active
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: active
                              ? Colors.white70
                              : theme.colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (active)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }

  // STEP 4: REVIEW
  Widget _buildReviewStep(
      ThemeData theme, CurrencyMetadata metadata, CurrencyState currencyState) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                    color: theme.shadowColor.withOpacity(0.05),
                    blurRadius: 30,
                    offset: const Offset(0, 15))
              ],
            ),
            child: Column(
              children: [
                Text("TOTAL LIQUIDITY SHIFT",
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2)),
                const SizedBox(height: 16),
                Text("${metadata.symbol}$_amount",
                    style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900, letterSpacing: -2)),
                const SizedBox(height: 40),
                _buildReviewDetail(theme, "Identity",
                    _selectedContact?.displayName ?? "Unknown"),
                const Divider(height: 40, thickness: 0.5),
                _buildReviewDetail(theme, "Network Speed",
                    _isPriority ? "Flash (Priority)" : "Standard"),
                const Divider(height: 40, thickness: 0.5),
                _buildReviewDetail(theme, "Network Fee",
                    _isPriority ? "${metadata.symbol}2.50" : "Free"),
                const Divider(height: 40, thickness: 0.5),
                _buildReviewDetail(
                    theme,
                    "Execution",
                    _isScheduled
                        ? "${_scheduledDate!.day}/${_scheduledDate!.month}"
                        : "Immediate"),
                if (_note.isNotEmpty) ...[
                  const Divider(height: 40, thickness: 0.5),
                  _buildReviewDetail(theme, "Digital Remark", _note),
                ],
              ],
            ),
          ),
          const Spacer(),
          _premiumButton(
            theme: theme,
            onPressed: () async {
              HapticFeedback.heavyImpact();
              _showSuccessOverlay(theme);
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close screen
              }
            },
            label: "EXECUTE TRANSACTION",
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_rounded,
                  color: theme.colorScheme.primary, size: 14),
              const SizedBox(width: 8),
              Text("ENCRYPTED VIA PAYPULSE NODE SECURE",
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                      letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewDetail(ThemeData theme, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontWeight: FontWeight.w900)),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _premiumButton(
      {required ThemeData theme,
      required String label,
      VoidCallback? onPressed}) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color:
                      theme.colorScheme.primary.withOpacity(isDark ? 0.3 : 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.2),
          minimumSize: const Size(double.infinity, 70),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 2)),
      ),
    );
  }

  void _showSuccessOverlay(ThemeData theme) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 80),
              ),
              const SizedBox(height: 32),
              Text("SHIFT SECURED",
                  style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4)),
              const SizedBox(height: 12),
              Text("TX-ID: PP-${DateTime.now().millisecondsSinceEpoch}",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showCurrencyPicker() {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: theme.dividerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 32),
            Text("NETWORK CURRENCY",
                style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3)),
            const SizedBox(height: 24),
            ...CurrencyType.values
                .map((c) => ListTile(
                      onTap: () {
                        ref.read(currencyProvider.notifier).setCurrency(c);
                        Navigator.pop(context);
                      },
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      title: Text(c.name,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900)),
                      trailing:
                          ref.watch(currencyProvider).selectedCurrency == c
                              ? Icon(Icons.check_circle_rounded,
                                  color: theme.colorScheme.primary)
                              : null,
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(ThemeData theme) {
    showDialog(
        context: context,
        builder: (context) => BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: AlertDialog(
                backgroundColor: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                    side:
                        BorderSide(color: theme.dividerColor.withOpacity(0.1))),
                title: Text("Transaction Remark",
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w900)),
                content: TextField(
                    autofocus: true,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: "What is this liquid shift for?",
                      hintStyle: TextStyle(
                          color: theme.colorScheme.onSurface.withOpacity(0.2)),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) => _note = v),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("ATTACH",
                          style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1)))
                ],
              ),
            )).then((_) => setState(() {}));
  }

  Widget _buildControlHub(
      BuildContext context, ThemeData theme, CurrencyState currencyState,
      {required String label, required VoidCallback onPrimary}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 40,
              offset: const Offset(0, -10))
        ],
      ),
      padding: const EdgeInsets.only(bottom: 24, top: 20),
      child: Column(
        children: [
          _buildTerminalKeyboard(theme),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _premiumButton(
                theme: theme, onPressed: onPrimary, label: label),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalKeyboard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          _kbRow(theme, ["1", "2", "3"]),
          _kbRow(theme, ["4", "5", "6"]),
          _kbRow(theme, ["7", "8", "9"]),
          _kbRow(theme, [".", "0", "back"]),
        ],
      ),
    );
  }

  Widget _kbRow(ThemeData theme, List<String> keys) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys.map((k) => _kbBtn(theme, k)).toList(),
      ),
    );
  }

  Widget _kbBtn(ThemeData theme, String k) {
    return GestureDetector(
      onTap: () => _onKeyPress(k),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        height: 60,
        child: Center(
          child: k == "back"
              ? Icon(Icons.backspace_rounded,
                  color: theme.colorScheme.onSurface.withOpacity(0.3), size: 24)
              : Text(k,
                  style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface)),
        ),
      ),
    );
  }
}
