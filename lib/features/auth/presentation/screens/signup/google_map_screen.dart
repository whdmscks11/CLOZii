import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen>
    with WidgetsBindingObserver {
  late final GoogleMapController controller;
  bool _awaitingSettings = false; // 설정 화면으로 보냈는지 표시
  CameraPosition initialPosition = CameraPosition(
    target: LatLng(14.2639, 121.07445),
    zoom: 19,
  );

  static const _apiKey = 'AIzaSyDgrIuXiYkGyUyVaukA7mXwCvPUaE--uFM'; // ← 본인 키
  String? _selectedName;
  LatLng? tappedLatlng;

  final _client = http.Client(); // 재사용
  final List<_Poi> _cache = []; // 프리패치 캐시
  bool _prefetching = false;

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

  double _distMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLng = (b.longitude - a.longitude) * pi / 180;
    final la1 = a.latitude * pi / 180;
    final la2 = b.latitude * pi / 180;
    final h =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLng / 2) * sin(dLng / 2) * cos(la1) * cos(la2);
    return 2 * R * asin(sqrt(h));
  }

  Future<void> _prefetchVisiblePois() async {
    if (_prefetching) return;
    _prefetching = true;
    try {
      final bounds = await controller.getVisibleRegion();
      final center = LatLng(
        (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );
      // 대각선 길이의 절반 정도를 반경으로 추정
      final cornerA = bounds.northeast;
      final cornerB = bounds.southwest;
      final approxRadius = (_distMeters(cornerA, cornerB) / 2)
          .clamp(30, 120)
          .toInt();

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${center.latitude},${center.longitude}'
        '&radius=$approxRadius'
        '&key=$_apiKey',
      );

      final res = await _client.get(url);
      if (res.statusCode != 200) return;

      final data = json.decode(res.body) as Map<String, dynamic>;
      final results = (data['results'] as List?) ?? const [];

      // 캐시에 병합(중복 제거)
      final existing = _cache.map((e) => e.id).toSet();
      for (final r in results) {
        final loc = r['geometry']?['location'];
        if (loc is! Map) continue;
        final id = r['place_id'] as String?;
        final name = r['name'] as String?;
        if (id == null || name == null) continue;
        if (existing.contains(id)) continue;
        _cache.add(
          _Poi(
            id,
            name,
            LatLng(
              (loc['lat'] as num).toDouble(),
              (loc['lng'] as num).toDouble(),
            ),
          ),
        );
      }
      // 필요시 LRU처럼 너무 커지면 잘라내기
      if (_cache.length > 300) _cache.removeRange(0, _cache.length - 300);
    } finally {
      _prefetching = false;
    }
  }

  // 탭 시: 캐시에서 즉시 스냅 → 없으면 폴백 호출
  Future<String?> _snapPoiName(
    LatLng tap, {
    double acceptWithin = 60,
    int fallbackRadius = 50,
  }) async {
    // 1) 캐시에서 즉시 찾기
    final nearest = _cache.isEmpty
        ? null
        : _cache.reduce((a, b) {
            final da = _distMeters(tap, a.pos);
            final db = _distMeters(tap, b.pos);
            return da < db ? a : b;
          });

    if (nearest != null && _distMeters(tap, nearest.pos) <= acceptWithin) {
      return nearest.name;
    }

    // 2) 너무 멀거나 캐시 미스면 한 번만 호출
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${tap.latitude},${tap.longitude}'
      '&radius=$fallbackRadius'
      '&key=$_apiKey',
    );
    final res = await _client.get(url);
    if (res.statusCode != 200) return null;

    final data = json.decode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List?) ?? const [];
    if (results.isEmpty) return null;

    // 가장 가까운 1개
    Map<String, dynamic>? best;
    double bestDist = double.infinity;
    for (final r in results) {
      final loc = r['geometry']?['location'];
      if (loc is! Map) continue;
      final p = LatLng(
        (loc['lat'] as num).toDouble(),
        (loc['lng'] as num).toDouble(),
      );
      final d = _distMeters(tap, p);
      if (d < bestDist) {
        bestDist = d;
        best = r as Map<String, dynamic>;
      }
    }
    if (best == null || bestDist > acceptWithin) return null;

    // 캐시에 넣어두기(다음엔 더 빠르게)
    final id = best['place_id'] as String?;
    final name = best['name'] as String?;
    if (id != null && name != null) {
      _cache.add(
        _Poi(
          id,
          name,
          LatLng(
            (best['geometry']['location']['lat'] as num).toDouble(),
            (best['geometry']['location']['lng'] as num).toDouble(),
          ),
        ),
      );
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialPosition,
            onCameraIdle: _prefetchVisiblePois,
            onTap: (latLng) async {
              // 탭 시 라벨이 있으면 이름 획득
              final name = await _snapPoiName(latLng);
              if (!mounted) return;
              setState(() {
                _selectedName = name;
                tappedLatlng = LatLng(latLng.latitude, latLng.longitude);
                controller.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(latLng.latitude, latLng.longitude),
                  ),
                );
              }); // null이면 라벨 없음으로 간주
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              this.controller = controller;
            },
            markers: {
              if (tappedLatlng != null)
                Marker(markerId: MarkerId('123'), position: tappedLatlng!),
            },
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.25, // 처음 높이 (화면 비율)
            minChildSize: 0.1, // 최소 높이
            maxChildSize: 0.6, // 최대 높이
            snap: true,
            snapAnimationDuration: Duration(milliseconds: 200),
            snapSizes: [0.25, 0.6],
            builder: (context, controller) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
                ),
                child: ListView(
                  controller: controller, // 스크롤 컨트롤러 연결
                  children: [
                    SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 80,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // 모달 안의 내용 넣기
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _selectedName != null
                          ? Text(_selectedName!)
                          : Text('data'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Poi {
  final String id;
  final String name;
  final LatLng pos;
  _Poi(this.id, this.name, this.pos);
}

// /// 탭 좌표 주변 라벨(POI)을 찾아 가장 가까운 1개 반환 (없으면 null)
  // Future<String?> _findNearestPoiName(
  //   LatLng tap, {
  //   int radius = 60,
  //   double acceptWithin = 65,
  // }) async {
  //   final url = Uri.parse(
  //     'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
  //     '?location=${tap.latitude},${tap.longitude}'
  //     '&radius=$radius' // 반경은 상황에 맞게 30~80m
  //     '&key=$_apiKey',
  //   );

  //   final res = await http.get(url);
  //   if (res.statusCode != 200) return null;

  //   final data = json.decode(res.body) as Map<String, dynamic>;
  //   final results = (data['results'] as List?) ?? const [];

  //   if (results.isEmpty) return null;

  //   Map<String, dynamic>? best;
  //   double bestDist = double.infinity;

  //   for (final raw in results) {
  //     final loc = raw['geometry']?['location'];
  //     if (loc is Map) {
  //       final p = LatLng(
  //         (loc['lat'] as num).toDouble(),
  //         (loc['lng'] as num).toDouble(),
  //       );
  //       final d = _distMeters(tap, p);
  //       if (d < bestDist) {
  //         bestDist = d;
  //         best = raw as Map<String, dynamic>;
  //       }
  //     }
  //   }

  //   if (best == null || bestDist > acceptWithin) return null; // 너무 멀면 무시

  //   return best['name'] as String?;
  // }