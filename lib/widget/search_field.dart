import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key, required this.onchanged});

  final ValueChanged<String> onchanged;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  void _clearText() {
    setState(() {
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onchanged,
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 208, 208, 208),
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: const Color.fromARGB(255, 144, 144, 144),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: Icon(Icons.search),
        hintText: 'Search',
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(onPressed: _clearText, icon: Icon(Icons.clear))
            : null,
      ),
    );
  }
}
