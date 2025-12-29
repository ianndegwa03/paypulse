import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/wallet/presentation/state/shared_space_notifier.dart';

class SplitBillScreen extends ConsumerWidget {
  const SplitBillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sharedSpaceState = ref.watch(sharedSpaceProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildThemedHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildThemedVaultHero(context),
                    const SizedBox(height: 40),
                    Text("ACTIVE SHARED SPACES",
                        style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 20),
                    if (sharedSpaceState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (sharedSpaceState.spaces.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(Icons.dashboard_customize_rounded,
                                  size: 48,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text("No active shared spaces",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withOpacity(0.5))),
                            ],
                          ),
                        ),
                      )
                    else
                      ...sharedSpaceState.spaces
                          .map((space) => _buildSpaceTile(context, space)),
                    const SizedBox(height: 40),
                    _buildThemedCreateBtn(context, ref),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpaceTile(BuildContext context, dynamic space) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.group_work_rounded,
                color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(space.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                Text(
                  '\$${space.paidAmount.toStringAsFixed(2)} / \$${space.totalAmount.toStringAsFixed(2)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          Text(
            space.isSettled ? 'SETTLED' : 'ACTIVE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: space.isSettled ? Colors.green : Colors.orange,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildThemedHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _headerAction(context, Icons.arrow_back_ios_new_rounded,
              onTap: () => Navigator.pop(context)),
          const SizedBox(width: 16),
          Text("Split Bills",
              style: theme.textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1.5)),
          const Spacer(),
          _headerAction(context, Icons.history_rounded),
        ],
      ),
    );
  }

  Widget _headerAction(BuildContext context, IconData icon,
      {VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _buildThemedVaultHero(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : const Color(0xFF1C222E),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
                color: (isDark ? theme.colorScheme.primary : Colors.black)
                    .withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 15))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hub_rounded, color: Colors.blueAccent, size: 16),
              const SizedBox(width: 10),
              Text("NETWORK RECEIVABLES",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("\$2,450.00",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -2)),
          const SizedBox(height: 48),
          Row(
            children: [
              _themedAvatarStack(context),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _showRouletteDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100)),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.casino_rounded, size: 16),
                    SizedBox(width: 8),
                    Text("ROULETTE",
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _themedAvatarStack(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 110,
      height: 40,
      child: Stack(
        children: List.generate(4, (index) {
          return Positioned(
            left: index * 22.0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.surface
                      : const Color(0xFF1C222E),
                  shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: theme.dividerColor.withOpacity(0.1),
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?u=$index'),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildThemedCreateBtn(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        // Simple dialog to create space for demo purposes
        showDialog(
            context: context,
            builder: (context) => _CreateSpaceDialog(ref: ref));
      },
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border:
              Border.all(color: theme.dividerColor.withOpacity(0.1), width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text("INITIALIZE SHARED SPACE",
                style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  void _showRouletteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _RouletteDialog(),
    );
  }
}

class _CreateSpaceDialog extends StatefulWidget {
  final WidgetRef ref;
  const _CreateSpaceDialog({required this.ref});

  @override
  State<_CreateSpaceDialog> createState() => _CreateSpaceDialogState();
}

class _CreateSpaceDialogState extends State<_CreateSpaceDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  Future<void> _create() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (title.isEmpty || amount <= 0) return;

    // Mock members for now - in real app, select friends
    // We can just use current user + dummy
    await widget.ref
        .read(sharedSpaceProvider.notifier)
        .createSpace(title, amount, ['current_user', 'dummy_friend']);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Shared Space'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _titleController,
              decoration:
                  const InputDecoration(labelText: 'Title (e.g. Dinner)')),
          TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Total Amount'),
              keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: _create, child: const Text('Create')),
      ],
    );
  }
}

class _RouletteDialog extends StatefulWidget {
  const _RouletteDialog();

  @override
  State<_RouletteDialog> createState() => _RouletteDialogState();
}

class _RouletteDialogState extends State<_RouletteDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _winnerIndex;
  final int _itemCount = 6; // Mock participants

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.forward().then((_) {
      setState(() {
        _winnerIndex = Random().nextInt(_itemCount);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        height: 350,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.purpleAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.purpleAccent.withOpacity(0.4),
              blurRadius: 30,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("WHO PAYS?",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: 20)),
            const SizedBox(height: 30),
            SizedBox(
              height: 200,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Spin logic
                  double rotation = _controller.value * 10 * pi;
                  if (_winnerIndex != null) {
                    // Stop at winner (mock alignment)
                    rotation = 0;
                  }

                  return Transform.rotate(
                    angle: rotation,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Wheel circle
                        Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.purpleAccent.withOpacity(0.5),
                                width: 4),
                          ),
                        ),
                        // Mock Items around circle
                        ...List.generate(_itemCount, (index) {
                          final angle = (2 * pi / _itemCount) * index;
                          return Transform.translate(
                            offset: Offset(60 * cos(angle), 60 * sin(angle)),
                            child: CircleAvatar(
                              radius: 15,
                              backgroundImage: NetworkImage(
                                  'https://i.pravatar.cc/150?u=$index'),
                            ),
                          );
                        }),
                        // Pointer
                        const Icon(Icons.arrow_drop_up_rounded,
                            size: 40, color: Colors.purpleAccent),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_winnerIndex != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text("Member \$_winnerIndex Pays!",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
          ],
        ),
      ),
    );
  }
}
