import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ChatDetailScreen extends StatefulWidget {
  final Contact contact;

  const ChatDetailScreen({super.key, required this.contact});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'text': 'Hey! How are you doing?',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'isMe': true,
      'text': 'I\'m doing great! Just checking out the new PayPulse features.',
      'time': DateTime.now().subtract(const Duration(minutes: 4)),
    },
    {
      'isMe': false,
      'text': 'Oh nice! The new community tab looks amazing.',
      'time': DateTime.now().subtract(const Duration(minutes: 2)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: widget.contact.photo != null
                  ? MemoryImage(widget.contact.photo!)
                  : null,
              child: widget.contact.photo == null
                  ? Text(widget.contact.displayName.isNotEmpty
                      ? widget.contact.displayName[0]
                      : '?')
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.contact.displayName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.contact.phones.isNotEmpty
                      ? widget.contact.phones.first.number
                      : 'Online',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.videocam_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.call_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] as bool;

                return _buildMessageBubble(context, message['text'] as String,
                    isMe, message['time'] as DateTime);
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      BuildContext context, String text, bool isMe, DateTime time) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 12,
              backgroundImage: widget.contact.photo != null
                  ? MemoryImage(widget.contact.photo!)
                  : null,
              child: widget.contact.photo == null
                  ? Text(
                      widget.contact.displayName.isNotEmpty
                          ? widget.contact.displayName[0]
                          : '?',
                      style: const TextStyle(fontSize: 10))
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isMe ? 20 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 20),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color:
                      isMe ? Colors.white : theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1E1E24)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_circle_outline),
            color: theme.colorScheme.primary,
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: _sendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _sendMessage(_messageController.text),
              icon:
                  const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isMe': true,
        'text': text,
        'time': DateTime.now(),
      });
      _messageController.clear();
    });
  }
}
