import 'dart:async';

import 'package:carrot_login/core/data/dummydata.dart';
import 'package:carrot_login/core/widgets/custom_button.dart';
import 'package:carrot_login/features/auth/presentation/screens/signup/google_map_screen.dart';
import 'package:carrot_login/features/auth/presentation/widgets/signup/address_list_tile.dart';
import 'package:carrot_login/features/auth/presentation/widgets/signup/search_field.dart';
import 'package:flutter/material.dart';

/// 위치 선택 화면 (거래 장소 선택 화면)
/// - 주소 검색 기능 포함
/// - 입력 딜레이를 위한 디바운서(debouncer) 사용
/// - 주소 목록을 필터링하여 보여줌
class SelectLocationScreen extends StatefulWidget {
  const SelectLocationScreen({super.key});

  @override
  State<SelectLocationScreen> createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  /// 입력 딜레이(디바운싱)를 위한 타이머
  Timer? _debouncer;

  /// 필터링된 주소 리스트 (초기값: 더미 데이터 전체)
  List<String> _filteredAddress = dummyAddress;

  /// 검색어 입력 시 호출
  /// - 디바운서를 이용해 입력이 멈춘 뒤 500ms 후에 필터링 실행
  /// - 원래는 매 입력마다 _filterAddress() 가 실행됐는데
  /// - 디바운서로 인해 입력 후 500ms 전에 다음 입력이 생기면 이전 타이머가 무시됨
  void _onSearchTextTyped(String text) {
    setState(() {
      // 기존 타이머가 활성화 상태면 취소
      if (_debouncer?.isActive ?? false) _debouncer?.cancel();

      // 500ms 후에 _filterAddress 호출 (디바운싱)
      _debouncer = Timer(const Duration(milliseconds: 500), () {
        _filterAddress(text);
      });
    });
  }

  /// 주소 리스트 필터링 로직
  /// - 주소에 검색어가 포함된 항목만 리스트에 남김
  void _filterAddress(String text) {
    setState(() {
      _filteredAddress = dummyAddress
          .where((addr) => addr.contains(text))
          .toList();
    });
  }

  void _showMap() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => GoogleMapScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 앱바에 커스텀 검색 필드 삽입, 텍스트 입력 시 _onSearchTextTyped 호출
      appBar: AppBar(title: SearchField(onchanged: _onSearchTextTyped)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 현재 위치에서 찾기 버튼 (아이콘+텍스트)
            CustomButton(
              icon: Icons.my_location_outlined,
              text: 'Search from current location',

              // TODO: 지도 화면과 연결 (Marker로 지정한 LatLng 리턴💡)
              onTap: _showMap,
            ),

            const SizedBox(height: 18.0),

            // "NearBy Areas" 섹션 제목
            Container(
              padding: EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'NearBy Areas',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),

            const SizedBox(height: 10.0),

            // 주소 목록 또는 "검색 결과 없음" 메시지 출력
            Expanded(
              child: _filteredAddress.isNotEmpty
                  // 검색어가 포함된 주소가 있으면 ListView.builder로 출력
                  ? ListView.builder(
                      itemCount: _filteredAddress.length,
                      itemBuilder: (BuildContext context, int index) =>
                          Container(
                            padding: EdgeInsets.only(left: 8.0),

                            /// 필터링된 주소 항목
                            child: AddressListTile(
                              address: _filteredAddress[index],
                            ),
                          ),
                    )
                  // 검색어가 포함된 주소가 없으면 "검색 결과 없음" 안내
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 50.0),
                      child: Text('No search results found.'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 화면 종료 시 타이머 해제하여 메모리 누수 방지
    _debouncer?.cancel();
    super.dispose();
  }
}
