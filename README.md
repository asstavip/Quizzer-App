# PDF Quizzer 📚🧠


## Overview

PDF Quizzer is an innovative mobile application that transforms PDF documents into interactive true/false quizzes. With just a few taps, users can upload a PDF and generate customizable quizzes to test their comprehension and knowledge.


## Features 🌟

### PDF Text Extraction
- Upload PDF files directly from your device
- Automatically extract text content using advanced PDF parsing

### Intelligent Quiz Generation
- AI-powered quiz generation using Google's Gemini 1.5 Flash model
- Customizable quiz settings:
  * Number of questions (5-20)
  * Difficulty levels (Easy, Medium, Hard)
  * Timed or untimed mode

### Comprehensive Quiz Experience
- True/False question format
- Immediate answer feedback
- Detailed explanations for each question
- Score tracking
- Quiz review mode

## Technology Stack 💻

- **Framework**: Flutter
- **Language**: Dart
- **AI Integration**: Google Gemini API
- **Key Packages**:
  * file_picker
  * syncfusion_flutter_pdf
  * http
  * flutter_dotenv
  * rflutter_alert

## Screens and Navigation 🚦

1. **PDF Upload Screen**
   - Initial screen for uploading PDF documents
   - Supports file selection and text extraction

2. **Quiz Generation Screen**
   - Customize quiz parameters
   - Generate questions based on PDF content

3. **Quiz Screen**
   - Interactive true/false quiz
   - Timer option
   - Immediate feedback

4. **Answer Review Screen**
   - Comprehensive quiz results
   - Detailed question breakdown

5. **Answer Detail Screen**
   - In-depth view of individual questions
   - Shows correct answer, user's response, and explanation

## Getting Started 🚀

### Prerequisites
- Flutter SDK
- Dart SDK
- Google Cloud Project with Gemini API access

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/yourusername/pdf-quizzer.git
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Set up environment variables
   - Create a `.env` file in the root directory
   - Add your Gemini API key:
     ```
     API_KEY=your_gemini_api_key_here
     ```

4. Run the app
   ```bash
   flutter run
   ```

## Configuration 🔧

### Quiz Settings
- **Question Count**: 5-20 questions
- **Difficulty Levels**:
  * Easy: Basic, straightforward questions
  * Medium: Moderately challenging questions
  * Hard: Complex, analysis-driven questions
- **Timed Mode**: Optional time limit per question (10-60 seconds)

## Error Handling 🛡️

The app includes robust error handling for:
- PDF parsing errors
- Network connectivity issues
- API request failures
- Invalid question generation

## Future Roadmap 🗺️

- Support for multiple question types
- More advanced AI-powered question generation
- Offline quiz mode
- User progress tracking
- Export/share quiz results

## Contributing 🤝

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License 📄

Distributed under the MIT License. See `LICENSE` for more information.

## Contact 📧

Your Name - youremail@example.com

Project Link: [https://github.com/yourusername/pdf-quizzer](https://github.com/yourusername/pdf-quizzer)
