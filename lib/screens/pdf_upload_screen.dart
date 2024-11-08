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


// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
//
// class PdfUploadScreen extends StatefulWidget {
//   @override
//   _PdfUploadScreenState createState() => _PdfUploadScreenState();
// }
//
// class _PdfUploadScreenState extends State<PdfUploadScreen> {
//   String pdfText = '';
//
//   Future<void> uploadAndReadPDF() async {
//     try {
//       // Pick file
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf'],
//         withData: true, // This ensures we get the file bytes
//       );
//       if (result != null && result.files.isNotEmpty) {
//         // Get file bytes - this works on both web and mobile
//         Uint8List? fileBytes = result.files.first.bytes;
//
//         if (fileBytes == null) {
//           throw Exception('No file data available');
//         }
//         // Load the PDF document using bytes
//         PdfDocument document = PdfDocument(inputBytes: fileBytes);
//         // Extract text from all pages
//         String text = '';
//         PdfTextExtractor extractor = PdfTextExtractor(document);
//         text += extractor.extractText();
//         // clean the text from unwanted characters
//         text = text
//             .replaceAll('\n', ' ')
//             .replaceAll('\t', ' ')
//             .replaceAll(RegExp(r'\s+'), ' ')
//             .replaceAll(RegExp(r'[^ -~]'), '')
//             .trim();
//         // Clean up
//         document.dispose();
//         // Update UI
//         updateUi(text);
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('PDF successfully read!')),
//         );
//       }
//     } catch (e) {
//       // Show error message
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error reading PDF: ${e.toString()}')),
//       );
//       print('Error reading PDF: $e');
//     }
//   }
//
//   void updateUi(String text) {
//     setState(() {
//       // Update UI
//       pdfText = text;
//     });
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('PDF Upload')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               ElevatedButton(
//                 onPressed: uploadAndReadPDF,
//                 child: Text('Upload PDF'),
//               ),
//               SizedBox(height: 20),
//               if (pdfText.isNotEmpty) ...[
//                 Text('Preview of extracted text:'),
//                 SizedBox(height: 10),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     child: Text(pdfText),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pushNamed(context, '/quiz');
//                   },
//                   child: Text('Generate Quiz'),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }