import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _bioController;
  DateTime? _dateOfBirth;
  String? _gender;
  bool _isLoading = false;

  final List<String> _genderOptions = ['Male', 'Female', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController =
        TextEditingController(text: user?.phoneNumber?.value ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _dateOfBirth = user?.dateOfBirth;
    _gender = user?.gender;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _savePersonalInfo() async {
    setState(() => _isLoading = true);

    await ref.read(authNotifierProvider.notifier).updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          bio: _bioController.text.trim(),
          dateOfBirth: _dateOfBirth,
          gender: _gender,
        );

    setState(() => _isLoading = false);

    if (mounted) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personal information updated!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Information',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This information is private and only visible to you.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildSectionTitle('Basic Details'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _firstNameController,
              label: 'First Name',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _lastNameController,
              label: 'Last Name',
              icon: Icons.person_outline_rounded,
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Contact'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.location_on_outlined,
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('Personal Details'),
            const SizedBox(height: 16),

            // Date of Birth Picker
            GestureDetector(
              onTap: _pickDateOfBirth,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cake_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 16),
                    Text(
                      _dateOfBirth != null
                          ? DateFormat('MMM dd, yyyy').format(_dateOfBirth!)
                          : 'Date of Birth',
                      style: TextStyle(
                        color: _dateOfBirth != null
                            ? theme.textTheme.bodyLarge?.color
                            : Colors.grey,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Gender Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonFormField<String>(
                value: _gender,
                hint: const Text('Gender'),
                decoration: const InputDecoration(
                  icon: Icon(Icons.wc_rounded),
                  border: InputBorder.none,
                ),
                items: _genderOptions
                    .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value),
              ),
            ),

            const SizedBox(height: 32),
            _buildSectionTitle('About You'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.edit_note_rounded,
              maxLines: 3,
            ),

            const SizedBox(height: 48),
            PrimaryButton(
              onPressed: _isLoading ? null : _savePersonalInfo,
              label: _isLoading ? 'Saving...' : 'Save Changes',
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
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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
