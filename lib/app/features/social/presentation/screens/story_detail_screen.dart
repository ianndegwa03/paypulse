import 'package:flutter/material.dart';
import 'package:paypulse/domain/entities/story_entity.dart';

class StoryDetailScreen extends StatefulWidget {
  final StoryEntity story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _animController.forward().then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Story Image (Placeholder or Actual)
            Center(
              child: Container(
                color: Colors.grey[900],
                child: const Icon(Icons.image, color: Colors.white, size: 64),
              ),
            ),

            // Progress Bar
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _animController.value,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 2,
                  );
                },
              ),
            ),

            // Header
            Positioned(
              top: 20,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue, // Placeholder color
                    child: Text(widget.story.userName[0].toUpperCase()),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.story.userName,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
