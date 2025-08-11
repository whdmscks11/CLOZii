import 'package:flutter/material.dart';

/// 검색 입력 필드 위젯
/// - 매 입력마다 콜백 호출(onchanged)
/// - 입력된 텍스트가 있을 때만 clear(지우기) 버튼 표시
class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.onchanged});

  /// 텍스트 변경 시 호출되는 콜백 함수
  final ValueChanged<String> onchanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  /// 텍스트 필드 내 텍스트 지우기 함수
  void _clearText() {
    setState(() {
      _controller.clear(); // 텍스트 삭제
    });
  }

  /// TODO: 검색 필드 기본 상태 readOnly = true 
  /// - 탭하면 readOnly = false
  /// - 다른 곳 탭하면 readOnly = true

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onchanged, // 텍스트 변경 시 주소 필터링
      decoration: InputDecoration(
        // 비활성 상태(포커스 없을 때) 검색 필드 스타일
        // 밑줄 색 연한 회색
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 208, 208, 208),
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        // 활성 상태(포커스 있을 때) 검색 필드 스타일
        // 밑줄 색 좀 더 진한 회색
        // 밑줄 좀 더 굵게
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 144, 144, 144),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: Icon(Icons.search), // 왼쪽 돋보기 아이콘
        hintText: 'Search', // 입력 안내 텍스트
        // 텍스트가 있으면 오른쪽에 clear 버튼 표시
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(onPressed: _clearText, icon: Icon(Icons.clear))
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 메모리 누수 방지를 위해 컨트롤러 해제
    super.dispose();
  }
}
