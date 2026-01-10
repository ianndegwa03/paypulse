import 'package:flutter/material.dart';

class SecureChatScreen extends StatelessWidget {
  final String chatId;
  final String title;

  const SecureChatScreen({
    super.key,
    required this.chatId,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, size: 64, color: Colors.indigo),
            const SizedBox(height: 16),
            Text('End-to-End Encrypted Chat: $chatId'),
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'This chat is secured with PayPulse Quantum-Safe Encryption.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
