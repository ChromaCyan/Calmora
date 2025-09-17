import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class ProDeetsCard extends StatefulWidget {
  final int yearsOfExperience;
  final List languagesSpoken;
  final String location;
  final String clinic;

  const ProDeetsCard({
    Key? key,
    required this.yearsOfExperience,
    required this.languagesSpoken,
    required this.location,
    required this.clinic,
  }) : super(key: key);

  @override
  State<ProDeetsCard> createState() => _ProDeetsCardState();
}

class _ProDeetsCardState extends State<ProDeetsCard> {
  String? _readableClinicAddress;
  LatLng? _clinicLatLng;

  @override
  void initState() {
    super.initState();
    _parseAndGeocodeClinic();
  }

  Future<void> _parseAndGeocodeClinic() async {
    try {
      final parts = widget.clinic.split(',');
      final lat = double.parse(parts[0]);
      final lng = double.parse(parts[1]);
      _clinicLatLng = LatLng(lat, lng);

      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final readable = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.postalCode
        ].where((part) => part != null && part.trim().isNotEmpty).join(', ');

        setState(() {
          _readableClinicAddress = readable;
        });
      }
    } catch (e) {
      debugPrint("Error parsing clinic location or reverse geocoding: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
            Icons.work,
            'Years of Experience: ${widget.yearsOfExperience}',
            theme.colorScheme.primary),
        _buildInfoRow(
            Icons.language,
            'Languages: ${widget.languagesSpoken.join(", ")}',
            theme.colorScheme.primary),
        _buildInfoRow(Icons.location_on, 'Location: ${widget.location}',
            theme.colorScheme.primary),
        _buildInfoRow(
          Icons.local_hospital,
          'Clinic: ${_readableClinicAddress ?? widget.clinic}',
          theme.colorScheme.primary,
        ),
        if (_clinicLatLng != null) ...[
          const SizedBox(height: 12),
          Text(
            'Clinic Location Map',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _clinicLatLng!,
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('clinic_marker'),
                    position: _clinicLatLng!,
                  ),
                },
                zoomControlsEnabled: false,
                liteModeEnabled: true,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
