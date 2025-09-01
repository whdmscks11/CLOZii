import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  @override
  Widget build(BuildContext context) {
    CameraPosition initialPosition = CameraPosition(
      target: LatLng(14.2639, 121.0742),
      zoom: 19,
    );

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(child: GoogleMap(initialCameraPosition: initialPosition)),
        ],
      ),
    );
  }
}
