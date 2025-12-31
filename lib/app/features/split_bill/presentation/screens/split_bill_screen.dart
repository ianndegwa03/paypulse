import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:paypulse/app/features/split_bill/presentation/state/split_providers.dart';
import 'package:paypulse/domain/entities/split_item_entity.dart';
import 'package:uuid/uuid.dart';

class SplitBillScreen extends ConsumerStatefulWidget {
  const SplitBillScreen({super.key});

  @override
  ConsumerState<SplitBillScreen> createState() => _SplitBillScreenState();
}

class _SplitBillScreenState extends ConsumerState<SplitBillScreen> {
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Temporary state for quick add
  void _addItem() {
    final name = _itemController.text;
    final price = double.tryParse(_priceController.text);

    if (name.isNotEmpty && price != null) {
      final billId = ref.read(splitBillIdProvider);
      if (billId != null) {
        final newItem = SplitItem(
          id: const Uuid().v4(),
          name: name,
          price: price,
        );
        ref.read(splitServiceProvider).addItem(billId, newItem);
        _itemController.clear();
        _priceController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final billAsync = ref.watch(currentSplitBillProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("BILL CRUSHER",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            onPressed: () {
              // Placeholder for adding dummy users for demo
              final billId = ref.read(splitBillIdProvider);
              if (billId != null) {
                ref.read(splitServiceProvider).addParticipant(
                    billId, 'user_${DateTime.now().millisecondsSinceEpoch}');
              }
            },
          )
        ],
      ),
      body: billAsync.when(
        data: (bill) {
          if (bill == null) return _buildEmptyState(theme);

          return Column(
            children: [
              // 1. Manual Entry Zone
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10))
                    ]),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _itemController,
                        decoration: InputDecoration(
                          hintText: "Item (e.g. Pizza)",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: theme.scaffoldBackgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "0.00",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: theme.scaffoldBackgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                        ),
                        onSubmitted: (_) => _addItem(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add_rounded),
                      style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(48, 48)),
                    )
                  ],
                ),
              ),

              // 2. Draggable Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: bill.items.length,
                  itemBuilder: (context, index) {
                    final item = bill.items[index];
                    return DragTarget<String>(
                      onAccept: (userId) {
                        ref
                            .read(splitServiceProvider)
                            .toggleItemAssignment(bill.id, item.id, userId);
                      },
                      builder: (context, candidates, rejects) {
                        final isSelected = candidates.isNotEmpty;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.1)
                                  : theme.cardColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : Colors.transparent,
                                  width: 2)),
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text("\$${item.price.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color: theme
                                              .textTheme.bodySmall?.color)),
                                ],
                              ),
                              const Spacer(),
                              // Assigned Avatars
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: item.assignedUserIds.map((uid) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: CircleAvatar(
                                        radius: 12,
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        child: Text(
                                            uid.substring(0, 1).toUpperCase(),
                                            style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // 3. Participants Rail (Draggable Source)
              if (bill.participants.isNotEmpty)
                Container(
                  height: 100,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: bill.participants.length,
                    itemBuilder: (context, index) {
                      final p = bill.participants[index];
                      return Draggable<String>(
                        data: p.userId,
                        feedback: Material(
                          color: Colors.transparent,
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: theme.colorScheme.primary,
                            child:
                                const Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.3,
                          child: _buildParticipantAvatar(theme, p.displayName),
                        ),
                        child: _buildParticipantAvatar(theme, p.displayName),
                      );
                    },
                  ),
                ),

              // 4. Bottom Total Bar
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, -10))
                      ]),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("TOTAL REMAINING",
                              style: theme.textTheme.labelSmall),
                          Text("\$${bill.remainingAmount.toStringAsFixed(2)}",
                              style: theme.textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: bill.remainingAmount == 0
                            ? () => ref
                                .read(splitServiceProvider)
                                .settleBill(bill.id)
                            : null,
                        icon: const Icon(Icons.check_circle_rounded),
                        label: const Text("SETTLE UP"),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildParticipantAvatar(ThemeData theme, String name) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Text(name.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          Text("User", style: theme.textTheme.labelSmall)
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded,
              size: 64, color: theme.disabledColor),
          const SizedBox(height: 16),
          Text("Start a New Split", style: theme.textTheme.titleMedium),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () async {
              final service = ref.read(splitServiceProvider);
              final bill = await service.createSplitBill("New Bill", 0, "USD");
              ref.read(splitBillIdProvider.notifier).state = bill.id;
            },
            child: const Text("Create Session"),
          )
        ],
      ),
    );
  }
}
