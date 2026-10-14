import 'package:flutter/material.dart';
import '../models/seva_kendra.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class SevaKendraMapScreen extends StatefulWidget {
  const SevaKendraMapScreen({super.key});

  @override
  State<SevaKendraMapScreen> createState() => _SevaKendraMapScreenState();
}

class _SevaKendraMapScreenState extends State<SevaKendraMapScreen> {
  String _selectedType = 'All Centers';
  String _searchQuery = '';
  SevaKendra? _selectedKendra;

  @override
  void initState() {
    super.initState();
    _selectedKendra = LocationService.kendras.first;
  }

  @override
  Widget build(BuildContext context) {
    final filteredKendras = LocationService.getFilteredKendras(
      type: _selectedType,
      query: _searchQuery,
    );

    return Scaffold(
      backgroundColor: AppTheme.lightBg,
      appBar: AppBar(
        title: const Text('Seva Kendra Locator', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Simulated Interactive Map Radar View
          Container(
            height: 190,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Map background styling
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: _MapGridPainter(),
                    ),
                  ),
                ),

                // Selected center info banner on map
                if (_selectedKendra != null)
                  Positioned(
                    top: 14,
                    left: 14,
                    right: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedKendra!.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  '${_selectedKendra!.distanceKm} km away • ${_selectedKendra!.timing}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.civicOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.directions, size: 14),
                            label: const Text('Directions', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              LocationService.launchGoogleMaps(
                                _selectedKendra!.latitude,
                                _selectedKendra!.longitude,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                // Radar center pin (User location)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.my_location_rounded, size: 14, color: AppTheme.civicCyan),
                        SizedBox(width: 6),
                        Text(
                          'Your GPS: Active (0.8 km Radius)',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search and Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search center, service or landmark...',
                hintStyle: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 42,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: LocationService.centerTypes.length,
              itemBuilder: (ctx, idx) {
                final type = LocationService.centerTypes[idx];
                final isSelected = _selectedType == type;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryNavy,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textDark,
                    ),
                    onSelected: (_) => setState(() => _selectedType = type),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Kendras List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredKendras.length,
              itemBuilder: (ctx, idx) {
                final kendra = filteredKendras[idx];
                final isSelected = _selectedKendra?.id == kendra.id;

                return _buildKendraCard(context, kendra, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKendraCard(BuildContext context, SevaKendra kendra, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedKendra = kendra),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.civicOrange : AppTheme.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryIndigo.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              kendra.type,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryIndigo,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: kendra.isOpenNow
                                  ? AppTheme.civicGreen.withOpacity(0.12)
                                  : Colors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              kendra.isOpenNow ? 'Open Now' : 'Closed',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: kendra.isOpenNow ? AppTheme.civicGreen : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        kendra.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        kendra.address,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.borderLight),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.near_me_rounded, size: 16, color: AppTheme.civicOrange),
                      Text(
                        '${kendra.distanceKm} km',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Services list chips
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: kendra.servicesOffered.map((svc) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    svc,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      kendra.timing,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 20, color: AppTheme.primaryNavy),
                      onPressed: () => LocationService.launchPhoneCall(kendra.phone),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.civicOrange,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Directions', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        LocationService.launchGoogleMaps(kendra.latitude, kendra.longitude);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.0;

    final paintPin = Paint()
      ..color = AppTheme.civicOrange
      ..style = PaintingStyle.fill;

    const step = 25.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintGrid);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // Draw user radar wave
    final wavePaint = Paint()
      ..color = AppTheme.civicCyan.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final userCenter = Offset(size.width * 0.35, size.height * 0.55);
    canvas.drawCircle(userCenter, 35, wavePaint);
    canvas.drawCircle(userCenter, 60, wavePaint..color = AppTheme.civicCyan.withOpacity(0.1));

    // User dot
    canvas.drawCircle(userCenter, 7, Paint()..color = AppTheme.civicCyan);

    // Kendra pins
    canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.3), 6, paintPin);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.4), 6, paintPin);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 6, paintPin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
