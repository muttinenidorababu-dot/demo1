class SevaKendra {
  final String id;
  final String name;
  final String type; // Common Service Center (CSC), MeeSeva Kendra, Municipal Ward Office, Post Office Seva
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final String phone;
  final String timing;
  final bool isOpenNow;
  final List<String> servicesOffered;
  final double rating;

  const SevaKendra({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.phone,
    required this.timing,
    required this.isOpenNow,
    required this.servicesOffered,
    this.rating = 4.6,
  });

  String get googleMapsUrl =>
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
}
