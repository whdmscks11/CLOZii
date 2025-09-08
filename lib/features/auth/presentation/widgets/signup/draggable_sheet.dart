import 'package:clozii/core/theme/context_extension.dart';
import 'package:flutter/material.dart';

class DraggableSheet extends StatefulWidget {
  const DraggableSheet({super.key, required this.selectedName});

  final String? selectedName;

  @override
  State<DraggableSheet> createState() => DraggableSheetState();
}

class DraggableSheetState extends State<DraggableSheet> {
  final DraggableScrollableController sheetController =
      DraggableScrollableController();

  final double minSize = 0.2;
  final double midSize = 0.5;
  final double maxSize = 0.9;

  void collapse() {
    if (sheetController.isAttached) {
      sheetController.animateTo(
        minSize,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    }
  }

  void expandToMid() {
    if (sheetController.isAttached) {
      sheetController.animateTo(
        midSize,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: sheetController,
      initialChildSize: minSize, // 처음 높이 (화면 비율)
      minChildSize: minSize, // 최소 높이
      maxChildSize: maxSize, // 최대 높이
      snap: true,
      snapAnimationDuration: Duration(milliseconds: 200),
      snapSizes: [0.2, 0.5],
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
                child: widget.selectedName != null
                    ? Text(
                        widget.selectedName!,
                        style: context.textTheme.titleLarge,
                      )
                    : Text(''),
              ),
            ],
          ),
        );
      },
    );
  }
}
