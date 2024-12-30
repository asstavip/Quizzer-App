# PDF Quizzer 📚🧠
![Pdf_Quizzer](https://github.com/user-attachments/assets/abe393f7-d493-4722-992c-066109b0b669)



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
   - ![upload screen](https://github.com/user-attachments/assets/ede9b8bf-4d59-43ed-8fcd-af1b055f3f8e)

2. **Quiz Generation Screen**
   - Customize quiz parameters
   - Generate questions based on PDF content
   - ![Quiz Generation Screen](https://github.com/user-attachments/assets/74fd3d50-e089-4864-a81e-119704733b93)
   - ![Quiz Generation Screen 2](https://github.com/user-attachments/assets/0dff048f-0102-4bb6-9b03-a35f19de4440)



3. **Quiz Screen**
   - Interactive true/false quiz
   - Timer option
   - Immediate feedback
   - ![Quiz Screen](https://github.com/user-attachments/assets/71cd93ca-aad4-4a72-96a4-e393dcb15807)
   - ![Quiz Screen 2 ](https://github.com/user-attachments/assets/e4ac4bda-ae58-444c-9f72-37e15a93deb0)



4. **Answer Review Screen**
   - Comprehensive quiz results
   - Detailed question breakdown
   - ![Answer Review Screen](https://github.com/user-attachments/assets/f5b312aa-f9a8-4112-8a0e-5d94521ab35e)


5. **Answer Detail Screen**
   - In-depth view of individual questions
   - Shows correct answer, user's response, and explanation
   - ![Answer Detail Screen](https://github.com/user-attachments/assets/1a1b7771-cc7d-417c-9dd2-1b7cfb3d0732)


## Getting Started 🚀

### Prerequisites
- Flutter SDK
- Dart SDK
- Google Cloud Project with Gemini API access

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/asstavip/pdf-quizzer.git
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

Abderrahman El Bissari - pissariabdo@gmail.com

Project Link: [https://github.com/asstavip/pdf-quizzer](https://github.com/yourusername/pdf-quizzer)
