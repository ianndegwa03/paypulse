import 'package:flutter/material.dart';
import 'package:paypulse/domain/entities/vault_entity.dart';

class VaultCard extends StatelessWidget {
  final VaultEntity vault;
  final VoidCallback onTap;

  const VaultCard({super.key, required this.vault, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = vault.progress;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(vault.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const Spacer(),
            Text(
              vault.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              "\$${vault.currentAmount.toStringAsFixed(0)} / \$${vault.targetAmount.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
