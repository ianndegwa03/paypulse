import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paypulse/domain/entities/invoice_entity.dart';
import 'package:paypulse/app/features/auth/presentation/state/auth_notifier.dart';
import 'package:paypulse/app/features/pro/presentation/state/pro_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class InvoiceGeneratorScreen extends ConsumerStatefulWidget {
  const InvoiceGeneratorScreen({super.key});

  @override
  ConsumerState<InvoiceGeneratorScreen> createState() =>
      _InvoiceGeneratorScreenState();
}

class _InvoiceGeneratorScreenState
    extends ConsumerState<InvoiceGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final List<InvoiceItem> _items = [];
  DateTime _dueDate = DateTime.now().add(const Duration(days: 14));

  void _addItem() {
    // Show dialog to add item
    showDialog(
        context: context,
        builder: (context) => _AddItemDialog(onAdd: (item) {
              setState(() {
                _items.add(item);
              });
            }));
  }

  void _generatePdf() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }

    final userId = ref.watch(authNotifierProvider).userId ?? 'unknown';
    final invoice = Invoice(
        id: const Uuid().v4(),
        userId: userId,
        clientName: _clientNameController.text,
        clientEmail: _clientEmailController.text,
        issueDate: DateTime.now(),
        dueDate: _dueDate,
        items: _items,
        currencyCode: 'USD');

    // Save to Firebase
    await ref.read(proServiceProvider).createInvoice(invoice);

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('INVOICE',
                  style: pw.TextStyle(
                      fontSize: 40, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('To: ${invoice.clientName}'),
                      pw.Text(invoice.clientEmail),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                          'Date: ${DateFormat('yyyy-MM-dd').format(invoice.issueDate)}'),
                      pw.Text(
                          'Due: ${DateFormat('yyyy-MM-dd').format(invoice.dueDate)}'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 40),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Description', 'Qty', 'Unit Price', 'Total'],
                  ...invoice.items.map((item) => [
                        item.description,
                        item.quantity.toString(),
                        item.unitPrice.toStringAsFixed(2),
                        item.total.toStringAsFixed(2)
                      ])
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                pw.Text(
                    'Grand Total: \$${invoice.totalAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 18))
              ])
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Invoice")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _clientNameController,
              decoration: const InputDecoration(
                  labelText: 'Client Name', border: OutlineInputBorder()),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clientEmailController,
              decoration: const InputDecoration(
                  labelText: 'Client Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Due Date"),
              subtitle: Text(DateFormat('MMM d, yyyy').format(_dueDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    initialDate: _dueDate);
                if (date != null) setState(() => _dueDate = date);
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Items",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Item"))
              ],
            ),
            ..._items.map((item) => ListTile(
                  title: Text(item.description),
                  subtitle: Text("${item.quantity} x \$${item.unitPrice}"),
                  trailing: Text("\$${item.total.toStringAsFixed(2)}"),
                )),
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                    child: Text("No items added",
                        style: TextStyle(color: Colors.grey))),
              ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _generatePdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Generate & Send Invoice"),
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.black, // Pro style
                  foregroundColor: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}

class _AddItemDialog extends StatefulWidget {
  final Function(InvoiceItem) onAdd;
  const _AddItemDialog({required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _descController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Item"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description')),
          TextField(
              controller: _qtyController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number),
          TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Unit Price'),
              keyboardType: TextInputType.number),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel")),
        ElevatedButton(
            onPressed: () {
              if (_descController.text.isNotEmpty &&
                  _priceController.text.isNotEmpty) {
                final item = InvoiceItem(
                  description: _descController.text,
                  quantity: double.tryParse(_qtyController.text) ?? 1,
                  unitPrice: double.tryParse(_priceController.text) ?? 0,
                );
                widget.onAdd(item);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"))
      ],
    );
  }
}
