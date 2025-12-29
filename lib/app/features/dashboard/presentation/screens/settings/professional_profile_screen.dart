import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';

class ProfessionalProfileScreen extends ConsumerStatefulWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  ConsumerState<ProfessionalProfileScreen> createState() =>
      _ProfessionalProfileScreenState();
}

class _ProfessionalProfileScreenState
    extends ConsumerState<ProfessionalProfileScreen> {
  late TextEditingController _occupationController;
  late TextEditingController _nationalityController;
  late TextEditingController _professionalBioController;
  bool _isProfessionalProfileVisible = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).currentUser;
    _occupationController = TextEditingController(text: user?.occupation ?? '');
    _nationalityController =
        TextEditingController(text: user?.nationality ?? '');
    _professionalBioController =
        TextEditingController(text: user?.professionalBio ?? '');
    _isProfessionalProfileVisible = user?.isProfessionalProfileVisible ?? false;
  }

  @override
  void dispose() {
    _occupationController.dispose();
    _nationalityController.dispose();
    _professionalBioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfessionalProfile() async {
    setState(() => _isLoading = true);

    await ref.read(authNotifierProvider.notifier).updateProfile(
          occupation: _occupationController.text.trim(),
          nationality: _nationalityController.text.trim(),
          professionalBio: _professionalBioController.text.trim(),
          isProfessionalProfileVisible: _isProfessionalProfileVisible,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Professional profile updated!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Profile',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visibility Toggle Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isProfessionalProfileVisible
                      ? [Colors.green.shade700, Colors.green.shade500]
                      : [Colors.grey.shade700, Colors.grey.shade600],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isProfessionalProfileVisible
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isProfessionalProfileVisible
                              ? 'Profile is Public'
                              : 'Profile is Private',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _isProfessionalProfileVisible
                              ? 'Others can see your professional info'
                              : 'Your professional info is hidden',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isProfessionalProfileVisible,
                    onChanged: (v) {
                      HapticFeedback.selectionClick();
                      setState(() => _isProfessionalProfileVisible = v);
                    },
                    activeColor: Colors.white,
                    inactiveThumbColor: Colors.white,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Work Details'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _occupationController,
              label: 'Occupation',
              icon: Icons.work_outline_rounded,
              hint: 'e.g. Software Engineer, Doctor, Teacher',
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Background'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nationalityController,
              label: 'Nationality',
              icon: Icons.flag_outlined,
              hint: 'e.g. Kenyan, American, British',
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Professional Bio'),
            const SizedBox(height: 8),
            Text(
              'Write a brief description of your professional background',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _professionalBioController,
              label: 'Professional Bio',
              icon: Icons.description_outlined,
              maxLines: 4,
              hint: 'Tell others about your professional experience...',
            ),

            const SizedBox(height: 16),
            // Character count
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_professionalBioController.text.length}/300',
                style: TextStyle(
                  color: _professionalBioController.text.length > 300
                      ? Colors.red
                      : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 48),
            PrimaryButton(
              onPressed: _isLoading ? null : _saveProfessionalProfile,
              label: _isLoading ? 'Saving...' : 'Save Professional Profile',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: maxLines > 1 ? null : Icon(icon),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
