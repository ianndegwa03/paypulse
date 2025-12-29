import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ConnectWalletScreen extends ConsumerStatefulWidget {
  const ConnectWalletScreen({super.key});

  @override
  ConsumerState<ConnectWalletScreen> createState() =>
      _ConnectWalletScreenState();
}

class _ConnectWalletScreenState extends ConsumerState<ConnectWalletScreen> {
  int _currentStep = 0;
  String? _selectedType;

  final List<String> _institutions = [
    'Chase',
    'Bank of America',
    'Wells Fargo',
    'Citibank',
    'Capital One',
    'Goldman Sachs'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onSurface, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: _buildStepIndicator(context),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildCurrentStep(context),
      ),
    );
  }

  Widget _buildStepIndicator(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final isActive = index <= _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 32 : 16,
          height: 5,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary
                : theme.dividerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(context);
      case 1:
        return _buildStep2(context);
      default:
        return _buildStep3(context);
    }
  }

  Widget _buildStep1(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Financial Core",
              style: theme.textTheme.headlineLarge
                  ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1.5)),
          const SizedBox(height: 12),
          Text(
              "Connect your capital sources to the PayPulse ecosystem for seamless liquidity.",
              style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 32),

          // Premium Bank Integration Flow Button
          GestureDetector(
            onTap: () => context.push('/bank-integration-flow'),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_card_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Link Bank or Card',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            )),
                        Text('Step-by-step secure integration',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            )),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
          Text('OR CHOOSE QUICK OPTIONS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              )),
          const SizedBox(height: 16),

          _selectionCard(
              context,
              "Native Pulse Wallet",
              "Create a high-frequency trading and transfer wallet within our network.",
              Icons.account_balance_wallet_rounded,
              theme.colorScheme.primary),
          const SizedBox(height: 16),
          _selectionCard(
              context,
              "Legacy Bank Vault",
              "Securely tunnel your existing institutional accounts into PayPulse.",
              Icons.account_balance_rounded,
              theme.colorScheme.secondary),
        ],
      ),
    );
  }

  Widget _selectionCard(BuildContext context, String title, String desc,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    final isSelected = _selectedType == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = title;
          _currentStep = 1;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
                color:
                    isSelected ? color : theme.dividerColor.withOpacity(0.05),
                width: 2),
            boxShadow: [
              BoxShadow(
                  color: theme.shadowColor.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10))
            ]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(desc,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          height: 1.4)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.2)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Choose Institution",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              hintText: "Search financial partners...",
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: theme.colorScheme.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _institutions.length,
              itemBuilder: (context, index) {
                return _institutionCard(context, _institutions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _institutionCard(BuildContext context, String name) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _currentStep = 2),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
                color: theme.shadowColor.withOpacity(0.02), blurRadius: 10)
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.05),
                  shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_rounded,
                  size: 24, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(name,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Authorization",
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 12),
          Text("Establish a secure, encrypted tunnel with the legacy provider.",
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 40),
          _themedInput(context, "MEMBER IDENTIFIER"),
          const SizedBox(height: 20),
          _themedInput(context, "SECURITY ACCESS KEY", obscure: true),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 70),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              elevation: 4,
              shadowColor: theme.colorScheme.primary.withOpacity(0.3),
            ),
            child: const Text("ESTABLISH TUNNEL",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 1)),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded,
                  size: 14, color: theme.colorScheme.primary.withOpacity(0.5)),
              const SizedBox(width: 8),
              Text("AES-256 BANK GRADE SECURITY",
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _themedInput(BuildContext context, String label,
      {bool obscure = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
                letterSpacing: 1)),
        const SizedBox(height: 12),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          ),
        ),
      ],
    );
  }
}
