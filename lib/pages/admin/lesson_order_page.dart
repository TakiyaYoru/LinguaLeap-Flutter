import 'package:flutter/material.dart';
import '../../widgets/lesson_reorder_widget.dart';

class LessonOrderPage extends StatelessWidget {
  final String unitId;
  final String unitTitle;

  const LessonOrderPage({
    Key? key,
    required this.unitId,
    required this.unitTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LessonReorderWidget(
      unitId: unitId,
      unitTitle: unitTitle,
    );
  }
} 