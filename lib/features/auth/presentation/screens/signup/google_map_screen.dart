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

  final _client = http.Client();
  final List<_Poi> _pois = [];
  double _zoom = 18; // onCameraMove로 갱신

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // ✅ observer 등록
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // ✅ 해제
    _client.close();
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

  Future<void> _prefetchPois() async {
    if (_zoom < 15) {
      _pois.clear();
      setState(() {});
      return;
    } // 멀리선 라벨 안 보이게

    final bounds = await controller.getVisibleRegion();
    final center = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );

    // 줌에 따라 반경/개수 조절 (라벨 밀도 흉내)
    final radius = _zoom >= 18
        ? 80
        : _zoom >= 16
        ? 200
        : 400;

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=${center.latitude},${center.longitude}'
      '&radius=$radius'
      '&key=$_apiKey',
    );
    final res = await _client.get(url);
    if (res.statusCode != 200) return;

    final data = json.decode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List?) ?? const [];
    _pois
      ..clear()
      ..addAll(
        results.map((r) {
          final loc = r['geometry']['location'];
          return _Poi(
            r['place_id'],
            r['name'],
            LatLng(
              (loc['lat'] as num).toDouble(),
              (loc['lng'] as num).toDouble(),
            ),
          );
        }),
      );
    setState(() {});
  }

  // 라벨이 화면에 보이고, 탭 지점이 라벨 근처일 때만 이름 반환
  Future<String?> _hitTestPoiName(LatLng tap) async {
    // 줌이 낮으면 라벨 자체가 안 보인다고 가정
    if (_zoom < 15) return null;

    // 탭 지점을 화면(px) 좌표로
    final scTap = await controller.getScreenCoordinate(tap);

    // 현재 화면에 보이는 영역(뷰포트)만 검사
    final bounds = await controller.getVisibleRegion();

    // 라벨 히트 반경(px) — 줌이 높을수록 조금 넉넉하게
    final hitPx = _zoom >= 18 ? 28 : 22;

    _Poi? hit;
    double best = double.infinity;

    for (final poi in _pois) {
      // 뷰포트 밖이면 스킵
      final p = poi.pos;
      if (p.latitude > bounds.northeast.latitude ||
          p.latitude < bounds.southwest.latitude ||
          p.longitude > bounds.northeast.longitude ||
          p.longitude < bounds.southwest.longitude) {
        continue;
      }

      // POI 위치를 화면(px) 좌표로 바꿔서 탭과의 픽셀 거리 확인
      final scPoi = await controller.getScreenCoordinate(poi.pos);
      final dx = (scPoi.x - scTap.x).toDouble();
      final dy = (scPoi.y - scTap.y).toDouble();
      final d = sqrt(dx * dx + dy * dy);

      if (d < hitPx && d < best) {
        best = d;
        hit = poi;
      }
    }

    return hit?.name; // 없으면 null → 라벨 미탭으로 간주
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: initialPosition,
            onMapCreated: (c) {
              controller = c;
              _prefetchPois();
            },
            onCameraMove: (cp) => _zoom = cp.zoom,
            onCameraIdle: _prefetchPois,
            onTap: (latLng) async {
              final name = await _hitTestPoiName(latLng); // 라벨 탭일 때만 이름 나옴
              if (!mounted) return;
              setState(() {
                tappedLatlng = latLng;
                _selectedName = name; // null이면 모달에 아무 것도 안 보여줌(또는 이전값 제거)
                controller.animateCamera(CameraUpdate.newLatLng(latLng));
              });
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
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
