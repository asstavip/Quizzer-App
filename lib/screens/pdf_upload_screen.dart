import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_uploader/screens/quiz_generation_screen.dart';
import 'package:pdf_uploader/theme/app_theme.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:toasty_box/toast_enums.dart';
import 'package:toasty_box/toasty_box.dart';
import 'package:aura_box/aura_box.dart';

class PdfUploadScreen extends StatefulWidget {
  static const id = 'pdf_upload_screen';

  const PdfUploadScreen({super.key});
  @override
  _PdfUploadScreenState createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  /// Upload and read PDF file using FilePicker and PdfTextExtractor.
  /// and this will navigate to the next screen if PDF is successfully read
  ///
  /// This function will:
  /// 1. Open a file picker dialog to select a PDF file
  /// 2. Read the selected PDF file using PdfTextExtractor
  /// 3. If the file is successfully read, navigate to the next screen with the extracted text
  /// 4. If there is an error, show an error message using ScaffoldMessenger
  Future<void> uploadAndReadPDF() async {
    /// Upload and read PDF file using FilePicker and PdfTextExtractor.
    /// and this will navigate to the next screen if PDF is successfully read
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        Uint8List? fileBytes = result.files.first.bytes;
        if (fileBytes == null) throw Exception('No file data available');

        PdfDocument document = PdfDocument(inputBytes: fileBytes);
        String extractedText = PdfTextExtractor(document).extractText();
        extractedText = extractedText.trim();
        document.dispose();

        ToastService.showSuccessToast(
          context,
          length: ToastLength.medium,
          expandedHeight: 100,
          message: "PDF successfully read!",
        );
// *!   Original Code but with SnackBar
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     backgroundColor: Colors.green,
        //     content: Row(
        //       children: [
        //         Icon(Icons.check, color: Colors.white),
        //         SizedBox(width: 8),
        //         Text('PDF successfully read!',
        //             style: TextStyle(color: Colors.white)),
        //       ],
        //     ),
        //   ),
        // );
        Navigator.pushNamed(
          context,
          QuizGenerationScreen.id,
          arguments: extractedText, // Pass text to next screen
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
// *!   Original Code but with SnackBar
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     backgroundColor: Colors.red,
      //     content: Row(
      //       children: [
      //         Icon(Icons.error, color: Colors.white),
      //         SizedBox(width: 8),
      //         Text('Error reading PDF', style: TextStyle(color: Colors.white)),
      //       ],
      //     ),
      //   ),
      // );
      ToastService.showErrorToast(
        context,
        length: ToastLength.medium,
        expandedHeight: 100,
        message: "Error reading PDF",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('PDF Quizzer App')),
        body: AuraBox(
          spots: [
            AuraSpot(
              color: AppTheme.customColors['primary']!,
              radius: 400.0,
              alignment: Alignment.topRight,
              blurRadius: 5.0,
              stops: const [0.0, 0.5],
            ),
            // Places one blue spot in the center
            AuraSpot(
              color: AppTheme.customColors['blue']!,
              radius: 400.0,
              alignment: Alignment.center,
              blurRadius: 5.0,
              stops: const [0.0, 0.5],
            ),
            // Places one red spot in the bottom right
            AuraSpot(
              color: AppTheme.customColors['error']!,
              radius: 300.0,
              alignment: Alignment.bottomRight,
              blurRadius: 10.0,
              stops: const [0.0, 0.7],
            ),
          ],
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: ElevatedButton(
              onPressed: uploadAndReadPDF,
              child: const Text('Upload PDF'),
            ),
          ),
        ));
  }
}
