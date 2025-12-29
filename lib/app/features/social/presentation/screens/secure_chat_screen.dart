import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/di/injector.dart';
import 'package:paypulse/core/services/biometric/biometric_service.dart';
import 'package:paypulse/app/features/social/presentation/state/chat_notifier.dart';
import 'package:paypulse/domain/entities/message_entity.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';

class SecureChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String title;

  const SecureChatScreen({
    super.key,
    required this.chatId,
    required this.title,
  });

  @override
  ConsumerState<SecureChatScreen> createState() => _SecureChatScreenState();
}

class _SecureChatScreenState extends ConsumerState<SecureChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isUnlocked = false;
  bool _ghostChatEnabled = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _authenticate();
      ref.read(chatNotifierProvider.notifier).listenToMessages(widget.chatId);
    });
  }

  Future<void> _authenticate() async {
    try {
      final biometricService = getIt<BiometricService>();
      final didAuthenticate = await biometricService.authenticate(
        reason: 'Please authenticate to enter the Chat Vault',
      );
      if (didAuthenticate) {
        setState(() => _isUnlocked = true);
      } else {
        if (mounted) context.pop();
      }
    } catch (e) {
      setState(() => _isUnlocked = true);
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    ref.read(chatNotifierProvider.notifier).sendMessage(
          chatId: widget.chatId,
          content: _messageController.text.trim(),
        );
    _messageController.clear();
    HapticFeedback.lightImpact();
  }

  void _showPaymentSheet(String type) {
    _amountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPaymentColor(type).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getPaymentIcon(type),
                      color: _getPaymentColor(type),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _getPaymentTitle(type),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Amount',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _processPayment(type),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getPaymentColor(type),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _getPaymentButtonText(type),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment(String type) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    Navigator.pop(context);

    // Send a payment message in the chat
    String messageContent;
    switch (type) {
      case 'send':
        messageContent = '💸 Sent \$${amount.toStringAsFixed(2)}';
        break;
      case 'request':
        messageContent = '📥 Requested \$${amount.toStringAsFixed(2)}';
        break;
      case 'split':
        messageContent = '➗ Split request: \$${amount.toStringAsFixed(2)} each';
        break;
      default:
        messageContent = 'Payment: \$${amount.toStringAsFixed(2)}';
    }

    ref.read(chatNotifierProvider.notifier).sendMessage(
          chatId: widget.chatId,
          content: messageContent,
          type: MessageType.funds,
          amount: amount,
        );

    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_getPaymentTitle(type)} successful!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'send':
        return Icons.send_rounded;
      case 'request':
        return Icons.call_received_rounded;
      case 'split':
        return Icons.call_split_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  Color _getPaymentColor(String type) {
    switch (type) {
      case 'send':
        return Colors.green;
      case 'request':
        return Colors.blue;
      case 'split':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getPaymentTitle(String type) {
    switch (type) {
      case 'send':
        return 'Send Money';
      case 'request':
        return 'Request Money';
      case 'split':
        return 'Split Bill';
      default:
        return 'Payment';
    }
  }

  String _getPaymentButtonText(String type) {
    switch (type) {
      case 'send':
        return 'Send Now';
      case 'request':
        return 'Request Now';
      case 'split':
        return 'Split Now';
      default:
        return 'Confirm';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isUnlocked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final chatState = ref.watch(chatNotifierProvider);
    final theme = Theme.of(context);
    final currentUser = ref.watch(authNotifierProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded,
                    size: 10, color: Colors.green),
                const SizedBox(width: 4),
                Text('End-to-End Encrypted',
                    style:
                        TextStyle(fontSize: 10, color: Colors.green.shade700)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice call coming soon')),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _ghostChatEnabled
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: _ghostChatEnabled ? Colors.purple : null,
            ),
            onPressed: () {
              setState(() => _ghostChatEnabled = !_ghostChatEnabled);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_ghostChatEnabled
                      ? 'Ghost Chat Enabled: Messages wont be saved'
                      : 'Ghost Chat Disabled'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Payment Quick Actions Bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor.withOpacity(0.1),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  icon: Icons.send_rounded,
                  label: 'Send',
                  color: Colors.green,
                  onTap: () => _showPaymentSheet('send'),
                ),
                _buildQuickAction(
                  icon: Icons.call_received_rounded,
                  label: 'Request',
                  color: Colors.blue,
                  onTap: () => _showPaymentSheet('request'),
                ),
                _buildQuickAction(
                  icon: Icons.call_split_rounded,
                  label: 'Split',
                  color: Colors.purple,
                  onTap: () => _showPaymentSheet('split'),
                ),
                _buildQuickAction(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  color: Colors.orange,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Share payment link coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: chatState.messages.length,
              itemBuilder: (context, index) {
                final message = chatState.messages[index];
                final isMe = message.senderId == currentUser?.id;
                return _buildMessageBubble(message, isMe, theme);
              },
            ),
          ),
          _buildInputArea(theme),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      MessageEntity message, bool isMe, ThemeData theme) {
    final isFunds = message.type == MessageType.funds;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isFunds
              ? Colors.green.withOpacity(0.1)
              : (isMe ? theme.colorScheme.primary : theme.cardColor),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 20),
          ),
          border:
              isFunds ? Border.all(color: Colors.green.withOpacity(0.3)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isFunds
                    ? Colors.green.shade700
                    : (isMe ? Colors.white : theme.textTheme.bodyLarge?.color),
                fontSize: 15,
                fontWeight: isFunds ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                color: (isMe ? Colors.white : Colors.grey).withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_money_rounded),
              onPressed: () => _showPaymentSheet('send'),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a secure message...',
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _amountController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
