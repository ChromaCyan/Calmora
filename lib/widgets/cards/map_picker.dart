import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng _selectedLocation = LatLng(16.0431, 120.3331); 
  final LatLngBounds _dagupanBounds = LatLngBounds(
    southwest: LatLng(16.0110, 120.2980),
    northeast: LatLng(16.0870, 120.3650),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.6),
        elevation: 0,
        title: const Text("Select Clinic Location"),
      ),
      body: Stack(
        children: [
          Image.asset(
            "images/login_bg_image.png",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          Container(
            color: theme.colorScheme.surface.withOpacity(0.6),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: const SizedBox.expand(),
            ),
          ),

          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14,
            ),
            onTap: (LatLng latLng) {
              if (_dagupanBounds.contains(latLng)) {
                setState(() {
                  _selectedLocation = latLng;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: const AwesomeSnackbarContent(
      title: 'Invalid Location!',
      message: 'Please select a location within Dagupan City only.',
      contentType: ContentType.warning,
    ),
    duration: Duration(seconds: 3),
  ),
);

              }
            },
            markers: {
              Marker(
                markerId: const MarkerId("selected"),
                position: _selectedLocation,
              ),
            },
            cameraTargetBounds: CameraTargetBounds(_dagupanBounds),
          ),

          // Confirm button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text("Confirm Location"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontSize: 16),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context, _selectedLocation);
              },
            ),
          )
        ],
      ),
    );
  }
}
