import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get_it/get_it.dart';
import 'package:paypulse/core/services/contacts/contacts_service.dart';
import 'package:paypulse/core/widgets/buttons/primary_button.dart';

class SendMoneyScreen extends StatefulWidget {
  final Contact? initialContact;
  const SendMoneyScreen({super.key, this.initialContact});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<Contact> _contacts = [];
  Contact? _selectedContact;
  bool _isLoadingContacts = false;

  @override
  void initState() {
    super.initState();
    _selectedContact = widget.initialContact;
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoadingContacts = true);
    final service = GetIt.I<ContactsService>();
    try {
      final contacts = await service.getContacts();
      setState(() {
        _contacts = contacts;
        _isLoadingContacts = false;
      });
    } catch (e) {
      setState(() => _isLoadingContacts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Send Money',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Amount Input
                  Text("Enter Amount",
                      style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'))
                    ],
                    decoration: InputDecoration(
                      prefixText: '\$ ',
                      prefixStyle: theme.textTheme.displayMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold),
                      hintText: "0.00",
                      hintStyle: TextStyle(
                          color: theme.colorScheme.primary.withOpacity(0.2)),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Receiver Selection
                  _buildSectionTitle(context, "Send to"),
                  const SizedBox(height: 16),
                  _buildContactPicker(context),

                  const SizedBox(height: 40),
                  // Note
                  _buildSectionTitle(context, "Note (Optional)"),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      hintText: "What's this for?",
                      prefixIcon: const Icon(Icons.edit_note_rounded,
                          color: Colors.grey),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.05),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: PrimaryButton(
              onPressed: () => _handleSend(context),
              label: "Continue to Payment",
              isLoading: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildContactPicker(BuildContext context) {
    if (_isLoadingContacts)
      return const Center(child: CircularProgressIndicator());

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _contacts.take(10).length + 1,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _contactBubble(
                context, null, Icons.search_rounded, "Search");
          }
          final contact = _contacts[index - 1];
          return _contactBubble(
              context, contact, null, contact.displayName.split(' ').first);
        },
      ),
    );
  }

  Widget _contactBubble(
      BuildContext context, Contact? contact, IconData? icon, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedContact?.id == contact?.id && contact != null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        if (contact != null) setState(() => _selectedContact = contact);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withOpacity(0.1),
              backgroundImage:
                  contact?.photo != null ? MemoryImage(contact!.photo!) : null,
              child: contact?.photo == null
                  ? Icon(icon ?? Icons.person_rounded,
                      color:
                          isSelected ? Colors.white : theme.colorScheme.primary)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? theme.colorScheme.primary : Colors.grey)),
        ],
      ),
    );
  }

  void _handleSend(BuildContext context) async {
    if (_amountController.text.isEmpty || _selectedContact == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter amount and select a contact")));
      return;
    }

    HapticFeedback.mediumImpact();
    // Simulate Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context); // Close loading

    // Show Success Detail
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSuccessSheet(context),
    );
  }

  Widget _buildSuccessSheet(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.green, shape: BoxShape.circle),
            child:
                const Icon(Icons.check_rounded, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 24),
          const Text("Transfer Successful!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text("Your money is on its way to ${_selectedContact?.displayName}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 48),
          _receiptRow("Amount", "\$${_amountController.text}"),
          const Divider(height: 32),
          _receiptRow("Fee", "\$0.00"),
          const Spacer(),
          PrimaryButton(
            onPressed: () {
              context.pop();
              context.pop();
            },
            label: "Back to Home",
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold)),
        Text(val,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ],
    );
  }
}
