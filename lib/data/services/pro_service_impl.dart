import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paypulse/domain/entities/invoice_entity.dart';
import 'package:paypulse/domain/entities/pro_profile_entity.dart';
import 'package:paypulse/domain/services/pro_service.dart';

class ProServiceImpl implements ProService {
  final FirebaseFirestore _firestore;
  final StreamController<bool> _proModeController =
      StreamController<bool>.broadcast();

  ProServiceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<bool> getProModeStream() => _proModeController.stream;

  @override
  Future<void> toggleProMode(bool isEnabled) async {
    _proModeController.add(isEnabled);
    // Persist this setting in User collection if needed
  }

  @override
  Future<ProProfile?> getProProfile(String userId) async {
    final doc = await _firestore.collection('pro_profiles').doc(userId).get();
    if (!doc.exists) return null;
    return _mapDocToProfile(doc);
  }

  @override
  Future<ProProfile> updateProProfile(ProProfile profile) async {
    await _firestore.collection('pro_profiles').doc(profile.userId).set({
      'businessName': profile.businessName,
      'profession': profile.profession,
      'hourlyRate': profile.hourlyRate,
      'skills': profile.skills,
      'isProModeEnabled': profile.isProModeEnabled,
    }, SetOptions(merge: true));
    return profile;
  }

  @override
  Future<List<Invoice>> getInvoices(String userId) async {
    final snapshot = await _firestore
        .collection('invoices')
        .where('userId', isEqualTo: userId)
        .orderBy('issueDate', descending: true)
        .get();

    return snapshot.docs.map((doc) => _mapDocToInvoice(doc)).toList();
  }

  @override
  Future<Invoice> createInvoice(Invoice invoice) async {
    await _firestore.collection('invoices').doc(invoice.id).set({
      'userId': invoice.userId,
      'clientName': invoice.clientName,
      'clientEmail': invoice.clientEmail,
      'issueDate': Timestamp.fromDate(invoice.issueDate),
      'dueDate': Timestamp.fromDate(invoice.dueDate),
      'items': invoice.items
          .map((item) => {
                'description': item.description,
                'quantity': item.quantity,
                'unitPrice': item.unitPrice,
              })
          .toList(),
      'currencyCode': invoice.currencyCode,
    });
    return invoice;
  }

  ProProfile _mapDocToProfile(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProProfile(
      userId: doc.id,
      businessName: data['businessName'] ?? '',
      profession: data['profession'] ?? '',
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      skills: List<String>.from(data['skills'] ?? []),
      isProModeEnabled: data['isProModeEnabled'] ?? false,
    );
  }

  Invoice _mapDocToInvoice(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Invoice(
      id: doc.id,
      userId: data['userId'] ?? '',
      clientName: data['clientName'] ?? '',
      clientEmail: data['clientEmail'] ?? '',
      issueDate: (data['issueDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      items: (data['items'] as List).map((i) {
        final item = i as Map<String, dynamic>;
        return InvoiceItem(
          description: item['description'] ?? '',
          quantity: (item['quantity'] as num).toDouble(),
          unitPrice: (item['unitPrice'] as num).toDouble(),
        );
      }).toList(),
      currencyCode: data['currencyCode'] ?? 'USD',
    );
  }
}
