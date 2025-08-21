import 'package:flutter/material.dart';

/// CustomButton
/// 재사용 가능한 커스텀 버튼 위젯
/// - 텍스트와 아이콘, 클릭 이벤트(onTap)를 지정 가능
/// - onTap이 null이면 버튼이 비활성화 상태로 렌더링됨
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text, // 버튼에 표시될 텍스트
    required this.onTap, // 버튼 클릭 시 실행할 콜백 함수
    this.icon,           // 버튼 왼쪽에 표시할 아이콘 (선택)
  });

  final String text;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // 버튼이 활성 상태인지 여부 판단 (onTap이 null이면 비활성 상태)
    bool isButtonEnabled = onTap != null ? true : false;

    return GestureDetector(
      // 버튼 클릭 시 동작 (null이면 동작하지 않음)
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0), // 버튼 주변 여백
        child: Container(
          width: double.infinity, // 가로를 최대 너비로 확장
          height: 40.0,           // 버튼 높이
          decoration: BoxDecoration(
            // 활성 상태: 주황색
            // 비활성 상태: 회색
            color: isButtonEnabled ? Colors.amber[800] : Colors.grey[350],
            borderRadius: BorderRadius.circular(8.0), // 모서리를 둥글게
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // 가운데 정렬
            children: [
              // 아이콘이 있을 경우에만 표시
              if (icon != null) Icon(icon, color: Colors.white),
              const SizedBox(width: 4.0), // 아이콘과 텍스트 사이 간격
              Text(
                text, // 버튼 텍스트
                style: TextStyle(
                  // 활성 상태: 흰색 텍스트, 비활성 상태: 회색 텍스트
                  color: isButtonEnabled ? Colors.white : Colors.grey[500],
                  fontWeight: FontWeight.w700, // 굵은 폰트
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}