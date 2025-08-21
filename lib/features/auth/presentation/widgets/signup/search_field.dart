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
  final FocusNode _focusNode = FocusNode();
  bool _readOnly = true;

  /// 텍스트 필드 내 텍스트 지우기 함수
  void _clearText() {
    setState(() {
      _controller.clear(); // 텍스트 삭제
      widget.onchanged(_controller.text); // 텍스트 삭제 후 다시 주소 필터링 하기 위해
    });
  }

  /// TODO: 검색 필드 기본 상태 readOnly = true
  void onTap() {
    setState(() {
      _readOnly = false;
    });

    _focusNode.requestFocus();
  }

  void onTapOutside(PointerDownEvent event) {
    setState(() {
      _readOnly = true;
    });

    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: _focusNode,
      readOnly: _readOnly,
      onTap: onTap,
      onTapOutside: onTapOutside,
      controller: _controller,
      onChanged: widget.onchanged, // 텍스트 변경 시 주소 필터링
      decoration: InputDecoration(
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.black45),
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
