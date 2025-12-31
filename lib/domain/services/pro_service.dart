import 'package:paypulse/domain/entities/invoice_entity.dart';
import 'package:paypulse/domain/entities/pro_profile_entity.dart';

abstract class ProService {
  Future<ProProfile?> getProProfile(String userId);
  Future<ProProfile> updateProProfile(ProProfile profile);
  Future<List<Invoice>> getInvoices(String userId);
  Future<Invoice> createInvoice(Invoice invoice);
  Stream<bool> getProModeStream();
  Future<void> toggleProMode(bool isEnabled);
}
