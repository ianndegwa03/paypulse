import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy & Security")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(
            context,
            theme,
            Icons.fingerprint,
            "Biometric Data",
            "This app uses FaceID/TouchID strictly for local authentication. Biometric data is never stored on our servers or transmitted externally. It remains securely within your device's Secure Enclave.",
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            theme,
            Icons.contacts_rounded,
            "Contact Access",
            "Contact access is used solely to facilitate easier money transfers to your friends. We do not upload your address book for marketing purposes.",
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            theme,
            Icons.shield_rounded,
            "Secure Storage",
            "All sensitive tokens (Authentication, API Keys) are encrypted using industry-standard AES encryption and stored in your device's secure keystore.",
          ),
          const SizedBox(height: 32),
          ListTile(
            title: const Text("Delete Account"),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            textColor: Colors.red,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Account deletion flow would start here.")));
            },
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, ThemeData theme, IconData icon,
      String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(description,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.textTheme.bodySmall?.color)),
        ],
      ),
    );
  }
}
