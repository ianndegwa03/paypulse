import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/theme/theme_provider.dart';
import 'package:paypulse/core/widgets/dialogs/premium_locked_dialog.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ThemeSettingsScreen> createState() =>
      _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  static const List<Color> _freeColors = [
    Color(0xFF6200EE), // Default Purple-ish
    Colors.blue,
    Colors.green,
    Colors.red,
  ];

  static const List<Color> _premiumColors = [
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.brown,
    Colors.lime,
    Colors.deepPurple,
    Colors.lightBlue,
  ];

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(themeProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.currentUser;
    final isPremium = user?.hasFeatureUnlocked('premium_themes') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Appearance'),
              const SizedBox(height: 16),
              _buildModeSelector(themeConfig.mode),
              const SizedBox(height: 32),
              _buildSectionHeader('Accent Color'),
              const SizedBox(height: 8),
              if (!isPremium) _buildPremiumBanner(),
              const SizedBox(height: 16),
              _buildColorSection(
                title: 'Basic Colors',
                colors: _freeColors,
                selectedColor: themeConfig.primaryColor,
                isLocked: false,
              ),
              const SizedBox(height: 24),
              _buildColorSection(
                title: 'Premium Colors',
                colors: _premiumColors,
                selectedColor: themeConfig.primaryColor,
                isLocked: !isPremium,
                onLockedTap: () => _showPremiumDialog(),
              ),
              const SizedBox(height: 24),
              _buildCustomColorButton(
                isPremium: isPremium,
                currentColor: themeConfig.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildModeSelector(ThemeMode currentMode) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            value: ThemeMode.system,
            groupValue: currentMode,
            onChanged: (mode) =>
                ref.read(themeProvider.notifier).setSystemMode(),
          ),
          const Divider(height: 1),
          RadioListTile<ThemeMode>(
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: currentMode,
            onChanged: (mode) =>
                ref.read(themeProvider.notifier).setLightMode(),
          ),
          const Divider(height: 1),
          RadioListTile<ThemeMode>(
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: currentMode,
            onChanged: (mode) => ref.read(themeProvider.notifier).setDarkMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade300, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Unlock Full Customization',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Get Premium to access all colors',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Navigate to Premium subscription
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.orange,
              minimumSize: const Size(80, 36),
              padding: EdgeInsets.zero,
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSection({
    required String title,
    required List<Color> colors,
    required Color selectedColor,
    required bool isLocked,
    VoidCallback? onLockedTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            if (isLocked) const Icon(Icons.lock, size: 16, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            final isSelected = selectedColor.value == color.value;
            return GestureDetector(
              onTap: () {
                if (isLocked) {
                  onLockedTap?.call();
                } else {
                  ref.read(themeProvider.notifier).setPrimaryColor(color);
                }
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSurface
                        : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : (isLocked
                        ? const Icon(Icons.lock,
                            size: 16, color: Colors.white54)
                        : null),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomColorButton({
    required bool isPremium,
    required Color currentColor,
  }) {
    return Opacity(
      opacity: isPremium ? 1.0 : 0.6,
      child: ListTile(
        onTap: () {
          if (!isPremium) {
            _showPremiumDialog();
          } else {
            // TODO: Implement custom color picker dialog
            // For now, simpler implementation: prompt user they can pick any color in future
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Custom Color Picker coming soon!')),
            );
          }
        },
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.green, Colors.blue],
            ),
            shape: BoxShape.circle,
          ),
        ),
        title: const Text('Custom Color'),
        subtitle: const Text('Pick any color you like'),
        trailing: isPremium
            ? const Icon(Icons.chevron_right)
            : const Icon(Icons.lock),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => PremiumLockedDialog(
        title: 'Premium Colors',
        message:
            'Unlock exclusive colors for \$0.99, or get full PayPulse Premium for \$9.99/mo.',
        onUnlock: () {
          // Mock Unlock
          ref
              .read(authNotifierProvider.notifier)
              .unlockFeature('premium_themes');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Premium Themes Unlocked!')),
          );
        },
      ),
    );
  }
}
