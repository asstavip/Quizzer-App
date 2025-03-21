class AppStrings {
  // SnackBar texts
  static const String pdfSuccess = 'pdfSuccess';
  static const String pdfError = 'pdfError';
  static const String error = 'error';
  static const String success = 'success';

  // QuizGenerationScreen texts
  static const String quizSettings = 'quizSettings';
  static const String numberOfQuestions = 'numberOfQuestions';
  static const String questionsLabel = 'questionsLabel';
  static const String difficultyLevel = 'difficultyLevel';
  static const String timedMode = 'timedMode';
  static const String timePerQuestion = 'timePerQuestion';
  static const String secondsLabel = 'secondsLabel';
  static const String secondsPerQuestion = 'secondsPerQuestion';
  static const String generating = 'generating';
  static const String generateQuiz = 'generateQuiz';

  // Difficulty levels
  static const String easy = 'easy';
  static const String medium = 'medium';
  static const String hard = 'hard';

  // PdfUploadScreen texts
  static const String pdfQuizzerUploader = 'pdfQuizzerUploader';
  static const String uploadPdf = 'uploadPdf';
  static const String pdfOnlyFiles = 'pdfOnlyFiles';

  // QuizScreen texts
  static const String questionNumberText = 'questionNumberText';
  static const String trueLabel = 'trueLabel';
  static const String falseLabel = 'falseLabel';
  static const String quizCompleteTitle = 'quizCompleteTitle';
  static const String reviewAnswers = 'reviewAnswers';
  static const String newQuiz = 'newQuiz';
  static const String timesUp = 'timesUp';

  // AnswerReviewScreen texts
  static const String quizReview = 'quizReview';
  static const String scoreText = 'scoreText';

  // AnswerDetailScreen texts
  static const String questionLabel = 'questionLabel';
  static const String yourAnswerLabel = 'yourAnswerLabel';
  static const String noAnswer = 'noAnswer';
  static const String correctAnswerLabel = 'correctAnswerLabel';
  static const String explanationLabel = 'explanationLabel';
  static const String questionDetailsTitlePrefix = 'questionDetailsTitlePrefix';

  // Difficulty prompts - These should not be translated as they are for API use
  static const String easyPrompt =
      "Generate basic, straightforward true/false questions focusing on main concepts and explicit information from the text. Include simple explanations that directly reference the text.";
  static const String mediumPrompt =
      "Generate moderately challenging true/false questions that require understanding relationships between concepts and implicit information from the text. Include explanations that show the logical connection between text elements.";
  static const String hardPrompt =
      "Generate challenging true/false questions that require deep understanding, analysis, and connecting multiple concepts from the text. Include detailed explanations that demonstrate complex reasoning and multiple supporting points from the text.";

  static const String easyPromptMultiple =
      "Generate basic multiple-choice questions with 4 options (A, B, C, D) focusing on main concepts and explicit information from the text. Keep options clear and distinct. One option must be correct, and distractors should be plausible but clearly incorrect. Include simple explanations that directly reference the text.";
  static const String mediumPromptMultiple =
      "Generate moderately challenging multiple-choice questions with 4 options (A, B, C, D) that require understanding relationships between concepts and implicit information. Options should test deeper comprehension, with well-crafted distractors based on common misconceptions. Include explanations that show the logical connection between text elements.";
  static const String hardPromptMultiple =
      "Generate challenging multiple-choice questions with 4 options (A, B, C, D) that require deep understanding, analysis, and connecting multiple concepts. Create sophisticated distractors that test critical thinking and subtle distinctions. Include detailed explanations that demonstrate complex reasoning and multiple supporting points from the text.";
  // PDF Preview Screen texts
  static const String selectPages = 'selectPages';
  static const String generateQuizSelected = 'generateQuizSelected';
  static const String selectAll = 'selectAll';
  static const String clearSelection = 'clearSelection';
  static const String page = 'page';

  static const String startPage = 'startPage';
  static const String endPage = 'endPage';
  static const String to = 'to';
  static const String pageRange = 'pageRange';
  static const String addRange = 'addRange';
  static const String cancel = 'cancel';
  static const String invalidPageRange = 'invalidPageRange';

  static const String saveQuiz = 'saveQuiz';
  static const String quizSaved = 'quizSaved';
  static const String quizHistory = 'quizHistory';
  static const String viewHistory = 'viewHistory';

  // New additions
  static const String tapToViewDetails = 'tapToViewDetails';
  static const String deleteHistoryItem = 'deleteHistoryItem';
  static const String deleteHistoryItemConfirm = 'deleteHistoryItemConfirm';
  static const String historyItemDeleted = 'historyItemDeleted';
  static const String delete = 'delete';
}
