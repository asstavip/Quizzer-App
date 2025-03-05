import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:pdf_uploader/domain/quiz_history.dart';
import 'package:pdf_uploader/screens/answer_review_screen.dart';
import 'package:pdf_uploader/utils/strings.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';

class QuizHistoryScreen extends StatefulWidget {
  static const String id = 'quiz_history_screen';

  const QuizHistoryScreen({super.key});

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  late Future<List<QuizHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = HistoryService.getQuizHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.quizHistory.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear History',
            onPressed: () => _showClearConfirmation(),
          ),
        ],
      ),
      body: FutureBuilder<List<QuizHistory>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No quiz history found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final historyList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history =
                  historyList[historyList.length - 1 - index]; // Reverse order
              return _buildHistoryCard(history);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(QuizHistory history) {
    final DateTime quizDate = DateTime.parse(history.date);
    final String formattedDate =
        DateFormat('MMM d, yyyy | HH:mm').format(quizDate);

    final double percentage = history.score / history.totalQuestions;
    final Color progressColor = percentage >= 0.7
        ? Colors.green
        : (percentage >= 0.4 ? Colors.orange : Colors.red);

    return Dismissible(
      key: Key(history.date),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return _confirmDeleteHistory(history);
      },
      onDismissed: (direction) {
        _deleteHistory(history);
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: history.questionsData != null
              ? () => _showHistoryDetail(history)
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _truncatePdfName(history.pdfName),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.customColors['secondary']!
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        history.difficulty.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.customColors['secondary'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Type: ${history.quizType.toUpperCase()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Score: ${history.score}/${history.totalQuestions}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: percentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                if (history.questionsData != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Center(
                      child: Text(
                        AppStrings.tapToViewDetails.tr(),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to truncate PDF name
  String _truncatePdfName(String pdfName) {
    if (pdfName.length > 30) {
      return pdfName.substring(0, 27) + '...';
    }
    return pdfName;
  }

  // Show history detail
  void _showHistoryDetail(QuizHistory history) {
    if (history.questionsData == null) return;

    Navigator.pushNamed(
      context,
      QuizReviewScreen.id,
      arguments: {
        'questions': history.questionsData,
        'userAnswers': history.userAnswers, // Pass the stored user answers
        'score': history.score,
        'isHistoryView': true,
      },
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History?'),
        content: const Text(
            'Are you sure you want to clear your quiz history? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              await HistoryService.clearHistory();
              Navigator.pop(context);
              setState(() {
                _loadHistory();
              });
            },
            child: const Text('CLEAR', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDeleteHistory(QuizHistory history) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deleteHistoryItem.tr()),
        content: Text(AppStrings.deleteHistoryItemConfirm.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.delete.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  void _deleteHistory(QuizHistory history) async {
    // Remove the item from the history list
    await HistoryService.deleteQuizHistoryItem(history);

    // Refresh the history list
    setState(() {
      _loadHistory();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.historyItemDeleted.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
