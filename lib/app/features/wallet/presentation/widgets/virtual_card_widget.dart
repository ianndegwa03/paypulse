import 'package:flutter/material.dart';
import 'package:paypulse/domain/entities/virtual_card_entity.dart';

class VirtualCardWidget extends StatelessWidget {
  final VirtualCardEntity card;
  final VoidCallback onTap;

  const VirtualCardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(card.hexColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.label.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (card.isDisposable)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("DISPOSABLE",
                        style: TextStyle(color: Colors.white, fontSize: 8)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text("••••",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Text(card.cardNumber.substring(card.cardNumber.length - 4),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("VIRTUAL CARD",
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
                Text("${card.expiryDate} • CVV ${card.cvv}",
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final h = hex.replaceAll('#', '');
    if (h.length == 6) return Color(int.parse('FF$h', radix: 16));
    return Colors.black;
  }
}
