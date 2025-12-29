import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationService {
  final http.Client client;

  LocationService({http.Client? client})
      : this.client = client ?? http.Client();

  Future<Map<String, String>> getUserLocation() async {
    try {
      final response = await client
          .get(Uri.parse('http://ip-api.com/json'))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'countryCode': data['countryCode'] ?? 'US',
          'countryName': data['country'] ?? 'United States',
          'currency': _getCurrencyFromCountry(data['countryCode'] ?? 'US'),
        };
      }
    } catch (_) {}
    return {
      'countryCode': 'US',
      'countryName': 'United States',
      'currency': 'USD',
    };
  }

  String _getCurrencyFromCountry(String countryCode) {
    switch (countryCode) {
      case 'KE':
        return 'KES';
      case 'GB':
        return 'GBP';
      case 'EU':
        return 'EUR';
      case 'ZA':
        return 'ZAR';
      case 'NG':
        return 'NGN';
      case 'JP':
        return 'JPY';
      default:
        return 'USD';
    }
  }
}
