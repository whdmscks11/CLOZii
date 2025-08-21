import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapTilerScreen extends StatelessWidget {
  const MapTilerScreen({super.key});

  final String apiKey = 'AjKFjKJePXd7MBE9Nfke';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(14.266667, 121.073056),
          initialZoom: 19,
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=${apiKey}",
            userAgentPackageName: 'com.example.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(14.5995, 120.9842),
                width: 40,
                height: 40,
                alignment: Alignment.bottomCenter,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
