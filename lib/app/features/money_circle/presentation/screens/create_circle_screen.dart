import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/money_circle/presentation/state/money_circle_providers.dart';
import 'package:paypulse/domain/entities/money_circle_entity.dart';

class CreateCircleScreen extends ConsumerStatefulWidget {
  const CreateCircleScreen({super.key});

  @override
  ConsumerState<CreateCircleScreen> createState() => _CreateCircleScreenState();
}

class _CreateCircleScreenState extends ConsumerState<CreateCircleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  CircleFrequency _frequency = CircleFrequency.monthly;
  String _currency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Money Circle")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Circle Name",
                hintText: "e.g. Bali Trip 2025",
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: "Contribution Amount",
                prefixText: "$_currency ",
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<CircleFrequency>(
              value: _frequency,
              decoration: const InputDecoration(
                labelText: "Frequency",
                border: OutlineInputBorder(),
              ),
              items: CircleFrequency.values.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(f.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) => setState(() => _frequency = val!),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Initialize Circle",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(authNotifierProvider).userId;
    if (userId == null) return;

    try {
      await ref.read(moneyCircleServiceProvider).createCircle(
            name: _nameController.text,
            contributionAmount: double.parse(_amountController.text),
            frequency: _frequency,
            currencyCode: _currency,
            creatorId: userId,
          );
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
}
