import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paypulse/core/theme/design_system_v2.dart';
import 'package:paypulse/domain/entities/transaction_entity.dart';
import 'package:paypulse/domain/entities/enums.dart';

/// Story-style transaction feed (swipeable cards like Instagram stories)
class TransactionStories extends StatefulWidget {
  final List<Transaction> transactions;

  const TransactionStories({super.key, required this.transactions});

  @override
  State<TransactionStories> createState() => _TransactionStoriesState();
}

class _TransactionStoriesState extends State<TransactionStories> {
  final PageController _controller = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final recent = widget.transactions.take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.auto_stories_rounded,
                  size: 18, color: PulseDesign.primary),
              const SizedBox(width: 8),
              Text(
                'RECENT ACTIVITY',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: PulseDesign.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Story indicators
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(
              recent.length,
              (i) => Expanded(
                child: Container(
                  height: 3,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: i <= _currentPage
                        ? PulseDesign.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Story cards
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            itemCount: recent.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              return _StoryCard(transaction: recent[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  final Transaction transaction;

  const _StoryCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDebit = transaction.type == TransactionType.debit;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDebit
              ? [Colors.red.shade400, Colors.red.shade700]
              : [PulseDesign.primary, PulseDesign.primary.withBlue(200)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
                (isDebit ? Colors.red : PulseDesign.primary).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -30,
            bottom: -30,
            child: Icon(
              isDebit ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
              size: 150,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isDebit ? 'SENT' : 'RECEIVED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, h:mm a').format(transaction.date),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  transaction.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '${isDebit ? "-" : "+"}\$${transaction.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
