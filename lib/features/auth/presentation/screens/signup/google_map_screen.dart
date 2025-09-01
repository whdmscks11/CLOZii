import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen>
    with WidgetsBindingObserver {
  bool _awaitingSettings = false; // 설정 화면으로 보냈는지 표시

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
