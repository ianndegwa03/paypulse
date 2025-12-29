import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_state.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _occupationController;
  late TextEditingController _addressController;
  late TextEditingController _nationalityController;
  late TextEditingController _professionalBioController;
  DateTime? _selectedDateOfBirth;
  String? _selectedGender;
  String _privacyLevel = 'Public';
  bool _stealthModeEnabled = false;
  bool _isProfessionalProfileVisible = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController =
        TextEditingController(text: user?.phoneNumber?.value ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _occupationController = TextEditingController(text: user?.occupation ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _nationalityController =
        TextEditingController(text: user?.nationality ?? '');
    _professionalBioController =
        TextEditingController(text: user?.professionalBio ?? '');
    _selectedDateOfBirth = user?.dateOfBirth;
    _selectedGender = user?.gender;
    _privacyLevel = user?.privacyLevel ?? 'Public';
    _stealthModeEnabled = user?.stealthModeEnabled ?? false;
    _isProfessionalProfileVisible = user?.isProfessionalProfileVisible ?? false;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    _nationalityController.dispose();
    _professionalBioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authNotifierProvider.notifier).updateProfile(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            bio: _bioController.text.trim(),
            occupation: _occupationController.text.trim(),
            address: _addressController.text.trim(),
            nationality: _nationalityController.text.trim(),
            dateOfBirth: _selectedDateOfBirth,
            gender: _selectedGender,
            privacyLevel: _privacyLevel,
            stealthModeEnabled: _stealthModeEnabled,
            isProfessionalProfileVisible: _isProfessionalProfileVisible,
            professionalBio: _professionalBioController.text.trim(),
          );

      if (mounted) {
        final state = ref.read(authNotifierProvider);
        if (state.errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
          context.pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image != null) {
      await ref
          .read(authNotifierProvider.notifier)
          .uploadProfileImage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatarSection(context, authState),
              const SizedBox(height: 32),
              _buildSectionTitle(theme, 'Basic Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline_rounded,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bioController,
                label: 'Short Bio',
                icon: Icons.edit_note_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(theme, 'Contact Details'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                hint: '+1 234 567 8900',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Residential Address',
                icon: Icons.location_on_outlined,
                hint: '123 Street, City, Country',
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(theme, 'Personal Details'),
              const SizedBox(height: 16),
              _buildDatePicker(context, theme),
              const SizedBox(height: 16),
              _buildGenderDropdown(theme),
              const SizedBox(height: 32),
              _buildSectionTitle(theme, 'Professional & Nationality'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _occupationController,
                label: 'Occupation',
                icon: Icons.work_outline_rounded,
                hint: 'Software Engineer',
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _nationalityController,
                label: 'Nationality',
                icon: Icons.public_rounded,
                hint: 'e.g. American',
              ),
              const SizedBox(height: 32),
              _buildSectionTitle(theme, 'Privacy & Professional Identity'),
              const SizedBox(height: 16),
              _buildPrivacyLevelDropdown(theme),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: 'Stealth Mode',
                subtitle: 'Hide profile from non-contacts',
                value: _stealthModeEnabled,
                onChanged: (v) => setState(() => _stealthModeEnabled = v),
                icon: Icons.security_rounded,
              ),
              const SizedBox(height: 16),
              _buildSwitchTile(
                title: 'Professional Profile',
                subtitle: 'Make professional details visible',
                value: _isProfessionalProfileVisible,
                onChanged: (v) =>
                    setState(() => _isProfessionalProfileVisible = v),
                icon: Icons.business_center_rounded,
              ),
              if (_isProfessionalProfileVisible) ...[
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _professionalBioController,
                  label: 'Professional Bio',
                  icon: Icons.description_outlined,
                  maxLines: 4,
                  hint: 'Tell us about your professional background...',
                ),
              ],
              const SizedBox(height: 48),
              PrimaryButton(
                onPressed: authState.isLoading ? null : _saveProfile,
                label: 'Save Changes',
                isLoading: authState.isLoading,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context, AuthState authState) {
    final theme = Theme.of(context);
    final hasProfileImage = authState.currentUser?.profileImageUrl != null &&
        authState.currentUser!.profileImageUrl!.isNotEmpty;

    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.2),
                width: 3,
              ),
            ),
            child: CircleAvatar(
              radius: 56,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage: hasProfileImage
                  ? NetworkImage(authState.currentUser!.profileImageUrl!)
                  : null,
              child: authState.isLoading
                  ? const CircularProgressIndicator()
                  : !hasProfileImage
                      ? Text(
                          (authState.currentUser?.firstName.isNotEmpty ?? false)
                              ? authState.currentUser!.firstName[0]
                                  .toUpperCase()
                              : 'U',
                          style: theme.textTheme.headlineLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: authState.isLoading ? null : _pickImage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: theme.scaffoldBackgroundColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    size: 20, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
            Icon(icon, color: theme.colorScheme.primary.withOpacity(0.5)),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _selectedDateOfBirth ?? DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (date != null) setState(() => _selectedDateOfBirth = date);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                size: 20, color: theme.colorScheme.primary.withOpacity(0.5)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDateOfBirth == null
                    ? 'Select Date of Birth'
                    : 'Born on ${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                style: TextStyle(
                  color: _selectedDateOfBirth == null ? Colors.grey : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      onChanged: (v) => setState(() => _selectedGender = v),
      items: ['Male', 'Female', 'Other', 'Prefer not to say']
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: Icon(Icons.people_outline_rounded,
            color: theme.colorScheme.primary.withOpacity(0.5)),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildPrivacyLevelDropdown(ThemeData theme) {
    return DropdownButtonFormField<String>(
      value: _privacyLevel,
      onChanged: (v) => setState(() => _privacyLevel = v!),
      items: ['Public', 'ContactsOnly', 'Stealth']
          .map((l) => DropdownMenuItem(value: l, child: Text(l)))
          .toList(),
      decoration: InputDecoration(
        labelText: 'Privacy Level',
        prefixIcon: Icon(Icons.visibility_outlined,
            color: theme.colorScheme.primary.withOpacity(0.5)),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: SwitchListTile(
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        secondary: Icon(icon, color: theme.colorScheme.primary),
        value: value,
        onChanged: onChanged,
        activeColor: theme.colorScheme.primary,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
