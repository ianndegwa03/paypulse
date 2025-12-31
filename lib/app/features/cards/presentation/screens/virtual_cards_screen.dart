import 'package:flutter/material.dart';
import 'package:paypulse/app/features/cards/presentation/widgets/premium_3d_card.dart';
import 'package:paypulse/domain/entities/virtual_card_entity.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class VirtualCardsScreen extends StatefulWidget {
  const VirtualCardsScreen({super.key});

  @override
  State<VirtualCardsScreen> createState() => _VirtualCardsScreenState();
}

class _VirtualCardsScreenState extends State<VirtualCardsScreen> {
  final _pageController = PageController(viewportFraction: 0.85);

  final List<VirtualCardEntity> _cards = [
    const VirtualCardEntity(
        id: '1',
        cardNumber: '1234567812344242',
        expiryDate: '05/28',
        cvv: '123',
        label: 'Primary',
        cardHolderName: 'KANDE N',
        design: CardDesign.metalBlack),
    const VirtualCardEntity(
        id: '2',
        cardNumber: '8765432187658899',
        expiryDate: '08/27',
        cvv: '456',
        label: 'Online',
        cardHolderName: 'KANDE N',
        design: CardDesign.cyberNeon),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor, // Dark mode aware
        appBar: AppBar(
          title: const Text("MY CARDS"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            const SizedBox(height: 32),
            SizedBox(
              height: 280,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(child: Premium3DCard(card: _cards[index])),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SmoothPageIndicator(
              controller: _pageController,
              count: _cards.length,
              effect: ExpandingDotsEffect(
                activeDotColor: theme.colorScheme.primary,
                dotColor: theme.disabledColor.withOpacity(0.3),
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
            const SizedBox(height: 48),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Controls",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildControlTile(theme, Icons.ac_unit, "Freeze Card",
                      "Temporarily disable this card", () {}),
                  _buildControlTile(theme, Icons.settings_rounded,
                      "Card Settings", "Manage limits and security", () {}),
                  _buildControlTile(theme, Icons.history_rounded,
                      "Transaction History", "View recent activity", () {}),
                ],
              ),
            )
          ],
        ));
  }

  Widget _buildControlTile(ThemeData theme, IconData icon, String title,
      String subtitle, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
