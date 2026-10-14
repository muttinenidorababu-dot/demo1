import 'package:url_launcher/url_launcher.dart';
import '../models/seva_kendra.dart';

class LocationService {
  static final List<SevaKendra> kendras = [
    const SevaKendra(
      id: 'kendra-1',
      name: 'Common Service Center (CSC) - DigiSeva Hub',
      type: 'Common Service Center (CSC)',
      address: 'Shop 14, Main Market Road, Near Gandhi Chowk',
      latitude: 17.385044,
      longitude: 78.486671,
      distanceKm: 0.8,
      phone: '+91 98765 43210',
      timing: '09:00 AM - 07:00 PM (Mon-Sat)',
      isOpenNow: true,
      servicesOffered: [
        'Aadhaar e-KYC & Mobile Update',
        'Ayushman Card Generation',
        'PM-KISAN Biometric Registration',
        'PAN Card & Income Certificate Application',
      ],
      rating: 4.8,
    ),
    const SevaKendra(
      id: 'kendra-2',
      name: 'MeeSeva / Jan Seva Kendra - Citizen Center',
      type: 'MeeSeva Kendra',
      address: 'Opposite Government Junior College, Station Road',
      latitude: 17.392011,
      longitude: 78.473522,
      distanceKm: 1.4,
      phone: '+91 98480 12345',
      timing: '09:30 AM - 06:00 PM (All Days)',
      isOpenNow: true,
      servicesOffered: [
        'Caste & Residence Certificates',
        'Ration Card / Food Security Additions',
        'PMAY Housing Application Submission',
        'Electricity & Water Bill Subsidies',
      ],
      rating: 4.7,
    ),
    const SevaKendra(
      id: 'kendra-3',
      name: 'Municipal Ward Administration & Civic Center',
      type: 'Municipal Ward Office',
      address: 'Ward Office Complex, Civic Center Circle',
      latitude: 17.401123,
      longitude: 78.461987,
      distanceKm: 2.1,
      phone: '040-23456789',
      timing: '10:00 AM - 05:00 PM (Govt Working Days)',
      isOpenNow: true,
      servicesOffered: [
        'Street Vendor Certificate of Vending (TVC)',
        'Trade License & Vendor Grievances',
        'Birth & Death Certificate Attestation',
        'Property Tax & Grievance Redressal',
      ],
      rating: 4.3,
    ),
    const SevaKendra(
      id: 'kendra-4',
      name: 'India Post Seva Kendra & Payments Bank',
      type: 'Post Office Seva',
      address: 'Head Post Office, Collectorate Road',
      latitude: 17.378942,
      longitude: 78.491204,
      distanceKm: 2.7,
      phone: '1800-266-6868',
      timing: '09:00 AM - 04:00 PM (Mon-Sat)',
      isOpenNow: true,
      servicesOffered: [
        'Sukanya Samriddhi Account Opening',
        'Atal Pension Yojana Enrolment',
        'Aadhaar Child Biometrics & Address Update',
        'Direct Benefit Transfer (DBT) Account Seeding',
      ],
      rating: 4.9,
    ),
    const SevaKendra(
      id: 'kendra-5',
      name: 'Rural Gram Panchayat Citizen Kiosk',
      type: 'Common Service Center (CSC)',
      address: 'Panchayat Bhavan, Village Entrance',
      latitude: 17.412345,
      longitude: 78.502311,
      distanceKm: 3.9,
      phone: '+91 94401 88990',
      timing: '08:30 AM - 06:30 PM (Mon-Sat)',
      isOpenNow: false,
      servicesOffered: [
        'PM-KISAN Land Record Linkage',
        'PMAY Gramin Geo-tagging Assistance',
        'Soil Health Card & Fertilizer Subsidy',
      ],
      rating: 4.5,
    ),
  ];

  static List<String> get centerTypes => [
        'All Centers',
        'Common Service Center (CSC)',
        'MeeSeva Kendra',
        'Municipal Ward Office',
        'Post Office Seva',
      ];

  static List<SevaKendra> getFilteredKendras({String type = 'All Centers', String query = ''}) {
    return kendras.where((k) {
      final matchesType = type == 'All Centers' || k.type == type;
      final matchesQuery = query.isEmpty ||
          k.name.toLowerCase().contains(query.toLowerCase()) ||
          k.address.toLowerCase().contains(query.toLowerCase()) ||
          k.servicesOffered.any((s) => s.toLowerCase().contains(query.toLowerCase()));
      return matchesType && matchesQuery;
    }).toList();
  }

  static Future<void> launchGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> launchPhoneCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
