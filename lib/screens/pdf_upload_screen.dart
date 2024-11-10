import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_uploader/screens/quiz_generation_screen.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfUploadScreen extends StatefulWidget {
  static const id = 'pdf_upload_screen';
  @override
  _PdfUploadScreenState createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Row(
              children: [
                Icon(Icons.check, color: Colors.white),
                SizedBox(width: 8),
                Text('PDF successfully read!', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        );
        Navigator.pushNamed(
          context,
          QuizGenerationScreen.id,
          arguments: extractedText, // Pass text to next screen
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Error reading PDF', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Quizzer App')),
      body: Center(
        child: ElevatedButton(
          onPressed: uploadAndReadPDF,
          child: Text('Upload PDF'),
        ),
      ),
    );
  }
}


