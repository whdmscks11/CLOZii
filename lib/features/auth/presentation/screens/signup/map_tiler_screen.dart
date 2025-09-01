import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MapTilerScreen extends StatefulWidget {
  const MapTilerScreen({super.key});

  @override
  State<MapTilerScreen> createState() => _MapTilerScreenState();
}

class _MapTilerScreenState extends State<MapTilerScreen>
    with WidgetsBindingObserver {
  final String apiKey = 'AjKFjKJePXd7MBE9Nfke';

  bool _awaitingSettings = false; // 설정 화면으로 보냈는지 표시
  LatLng _selectedPoint = LatLng(14.266843, 121.073063); // 선택된 위치

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ observer 등록
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✅ 해제
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingSettings) {
      _awaitingSettings = false;
      _checkPermission();
    }
  }

  Future<void> _checkPermission() async {
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      // 위치 서비스가 꺼져 있습니다. 설정에서 켜주세요.
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    // ✅ denied면 다시 요청 (iOS의 "다음번에 묻기" 포함)
    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      final goSetting = await _showGoSettingsDialog() ?? false;

      if (goSetting) {
        _awaitingSettings = true;
        await Geolocator.openAppSettings();
      } else {
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  Future<bool?> _showGoSettingsDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 권한 거부됨'),
        content: const Text('지도 기능을 사용하려면 위치 권한이 필요합니다.\n설정으로 이동하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('예'),
          ),
        ],
      ),
    );
  }

  Future<String?> _getAddressFromLatLng(double lat, double lon) async {
    final url = Uri.parse(
      'https://api.maptiler.com/geocoding/$lon,$lat.json?key=$apiKey',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final features = data['features'] as List?;
      if (features != null && features.isNotEmpty) {
        return features.first['place_name'];
      }
    }
    return null;
  }

  Widget _buildBottomInfo(String text) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.my_location, size: 32),
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.1)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("선택된 위치", style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(text, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: kToolbarHeight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: _selectedPoint, initialZoom: 19),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.maptiler.com/maps/basic-v2/{z}/{x}/{y}.png?key=$apiKey",
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPoint,
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FutureBuilder(
              future: _getAddressFromLatLng(
                _selectedPoint.latitude,
                _selectedPoint.longitude,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _buildBottomInfo('주소를 불러올 수 없습니다.');
                }
                return _buildBottomInfo(snapshot.data ?? '알 수 없는 주소');
              },
            ),
          ),
        ],
      ),
    );
  }
}
