import 'package:flutter/material.dart';
import 'package:paypulse/domain/entities/split_request_entity.dart';

class RequestCard extends StatelessWidget {
  final SplitRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const RequestCard({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary, shape: BoxShape.circle),
                child: const Icon(Icons.splitscreen_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Split Request",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${request.initiatorName} wants to split",
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            request.description,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "\$${request.perPersonAmount.toStringAsFixed(2)}",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: onDecline,
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: onAccept,
                    icon:
                        const Icon(Icons.check, color: Colors.green, size: 20),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
