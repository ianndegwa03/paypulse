import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';
import 'package:paypulse/domain/entities/virtual_card_entity.dart';
import 'package:paypulse/app/features/wallet/presentation/state/wallet_providers.dart';
import 'dart:math';

class CreateGhostCardScreen extends ConsumerStatefulWidget {
  const CreateGhostCardScreen({super.key});

  @override
  ConsumerState<CreateGhostCardScreen> createState() =>
      _CreateGhostCardScreenState();
}

class _CreateGhostCardScreenState extends ConsumerState<CreateGhostCardScreen> {
  late TextEditingController _labelController;
  late TextEditingController _limitController;
  double _ttlDays = 1.0;
  bool _merchantLock = false;
  Color _selectedColor = Colors.deepPurple;
  bool _isGenerating = false;

  final List<Color> _ghostColors = [
    Colors.deepPurple,
    Colors.indigo,
    Colors.blueGrey,
    const Color(0xFF1A1A1A),
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: 'Ghost Card');
    _limitController = TextEditingController(text: '500');
  }

  @override
  void dispose() {
    _labelController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  int get _anonymityScore {
    int score = 40; // Base score
    if (_ttlDays <= 1) score += 30;
    if (_ttlDays > 1 && _ttlDays <= 7) score += 15;
    if (_merchantLock) score += 20;
    if (double.tryParse(_limitController.text) != null &&
        double.parse(_limitController.text) < 1000) score += 10;
    return min(score, 100);
  }

  String _generateCardNumber() {
    final random = Random.secure();
    return List.generate(
        4, (_) => List.generate(4, (_) => random.nextInt(10)).join()).join(' ');
  }

  String _generateCvv() {
    final random = Random.secure();
    return List.generate(3, (_) => random.nextInt(10)).join();
  }

  Future<void> _createGhostCard() async {
    setState(() => _isGenerating = true);

    final destructionDate =
        DateTime.now().add(Duration(days: _ttlDays.round()));
    final card = VirtualCardEntity(
      id: 'ghost_${DateTime.now().millisecondsSinceEpoch}',
      cardNumber: _generateCardNumber(),
      expiryDate:
          '${destructionDate.month.toString().padLeft(2, '0')}/${(destructionDate.year % 100)}',
      cvv: _generateCvv(),
      label: _labelController.text,
      hexColor: '#${_selectedColor.value.toRadixString(16).substring(2)}',
      isDisposable: true,
      isActive: true,
      isGhostCard: true,
      destructionDate: destructionDate,
      merchantLock: _merchantLock ? 'PENDING' : null,
      maxTransactionLimit: double.tryParse(_limitController.text),
      anonymityScore: _anonymityScore,
    );

    await ref.read(walletStateProvider.notifier).createVirtualCard(card);

    setState(() => _isGenerating = false);

    if (mounted) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.security_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(
                      'Ghost Card "${_labelController.text}" is now active!')),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ghost Card',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardPreview(),
            const SizedBox(height: 32),
            _buildAnonymityShield(),
            const SizedBox(height: 32),
            _buildSectionTitle('General Info'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _labelController,
              label: 'Card Label',
              icon: Icons.label_outline_rounded,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Security Settings'),
            const SizedBox(height: 16),
            _buildTTLSider(),
            const SizedBox(height: 16),
            _buildSwitchTile(
              title: 'Merchant Lock',
              subtitle: 'Card locks to the first vendor used',
              value: _merchantLock,
              onChanged: (v) => setState(() => _merchantLock = v),
              icon: Icons.store_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _limitController,
              label: 'Transaction Limit',
              icon: Icons.account_balance_wallet_outlined,
              keyboardType: TextInputType.number,
              suffix: const Text('USD'),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('Appearance'),
            const SizedBox(height: 16),
            _buildColorPicker(),
            const SizedBox(height: 48),
            PrimaryButton(
              onPressed: _isGenerating ? null : _createGhostCard,
              label: _isGenerating ? 'Generating...' : 'Generate Ghost Card',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            _selectedColor,
            _selectedColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _selectedColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.1,
              child:
                  Icon(Icons.security_rounded, size: 180, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _labelController.text.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Icon(Icons.security_rounded,
                        color: Colors.white, size: 24),
                  ],
                ),
                const Text(
                  '••••  ••••  ••••  ••••',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EXPIRY',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 10)),
                        const Text('EPHEMERAL',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Icon(Icons.credit_card_rounded,
                        color: Colors.white70),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnonymityShield() {
    final score = _anonymityScore;
    Color scoreColor = Colors.red;
    if (score > 40) scoreColor = Colors.orange;
    if (score > 70) scoreColor = Colors.green;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  color: scoreColor,
                  strokeWidth: 6,
                ),
              ),
              Text('$score%',
                  style: TextStyle(
                      color: scoreColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Anonymity Score',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  score > 70
                      ? 'Maximum protection active. Your real identity is fully shielded.'
                      : 'Standard protection. Consider shortening TTL for higher security.',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTTLSider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Time To Live (TTL)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text('${_ttlDays.round()} Days',
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: _ttlDays,
          min: 1,
          max: 30,
          divisions: 29,
          onChanged: (v) => setState(() => _ttlDays = v),
        ),
        const Text(
          'Card will self-destruct after this period.',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffix != null
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: suffix,
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        secondary: Icon(icon, color: Theme.of(context).primaryColor),
        value: value,
        onChanged: (v) {
          HapticFeedback.selectionClick();
          onChanged(v);
        },
      ),
    );
  }

  Widget _buildColorPicker() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _ghostColors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final color = _ghostColors[index];
          final isSelected = _selectedColor == color;
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = color),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2)
                      ]
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
