import 'package:clozii/features/auth/presentation/widgets/signup/terms_and_conditions.dart';
import 'package:flutter/material.dart';

/// 주소 목록에서 각 항목을 보여주는 리스트 타일 위젯
/// - 주소 텍스트 표시
/// - 항목 탭 시 하단 모달 시트로 약관 화면 표시
class AddressListTile extends StatelessWidget {
  const AddressListTile({super.key, required this.address});

  /// 표시할 주소 문자열
  final String address;

  /// 리스트 타일 탭 시 호출
  /// - 하단에서 약관 모달 시트 띄움
  void _onSelectAddress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // 모달이 화면 높이만큼 채워짐
      // - 하지만 약관 위젯에서 Wrap 위젯 사용해서 내부 요소만큼만 모달이 채워짐
      builder: (context) =>
          TermsAndConditions(address: address), // 모달 내용: 약관 위젯
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // 기본 패딩을 왼쪽으로 약간 음수 조정 (리스트 아이템 간격 조절)
      contentPadding: EdgeInsets.only(left: -10.0),

      // 최소 높이 지정
      minTileHeight: 50.0,

      // 타이틀: 왼쪽 정렬된 주소 텍스트
      title: Align(alignment: Alignment.centerLeft, child: Text(address)),

      // 탭 시 약관 모달 시트 표시
      onTap: () => _onSelectAddress(context),
    );
  }
}
