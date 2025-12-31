import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? profileImageUrl;
  final String? name; // For initials
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const UserAvatar({
    super.key,
    this.profileImageUrl,
    this.name,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // If we have a valid URL, try to show the image
    // Note: In production, use CachedNetworkImage for better performance/offline support
    final hasImage = profileImageUrl != null && profileImageUrl!.isNotEmpty;

    if (hasImage) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(profileImageUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Fallback will be handled by CHILD if we wrap differently,
          // but CircleAvatar doesn't easily fallback to child on error.
          // For simple implementation, we assume NetworkImage works or fails silently.
          // A robust solution uses CachedNetworkImage's errorWidget.
        },
        // If image fails loading, we can't easily show initials with just CircleAvatar.
        // But for this stage, we assume URL validity logic is upstream or accept broken image icon.
      );
    }

    // Fallback: Initials
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Theme.of(context).primaryColor,
      child: Text(
        _getInitials(name),
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: radius * 0.8,
        ),
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    if (parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return "?";
  }
}
