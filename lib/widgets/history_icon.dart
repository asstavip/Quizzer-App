import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pdf_uploader/screens/quiz_history_screen.dart';
import 'package:pdf_uploader/utils/strings.dart';

class HistoryIcon extends StatelessWidget {
  const HistoryIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.history),
      tooltip: AppStrings.viewHistory.tr(),
      onPressed: () {
        Navigator.pushNamed(context, QuizHistoryScreen.id);
      },
    );
  }
}