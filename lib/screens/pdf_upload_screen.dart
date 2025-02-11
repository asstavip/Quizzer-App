import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_uploader/screens/pdf_preview_screen.dart';
import 'package:pdf_uploader/theme/app_theme.dart';
import 'package:aura_box/aura_box.dart';
import 'package:pdf_uploader/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';

class PdfUploadScreen extends StatefulWidget {
  static const id = 'pdf_upload_screen';

  const PdfUploadScreen({super.key});
  @override
  _PdfUploadScreenState createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  bool _isLoading = false;

  void _showSnackBar(String message, bool isError) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> uploadAndReadPDF() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        
        if (bytes == null) {
          throw Exception('Could not read file data');
        }

        _showSnackBar(AppStrings.pdfSuccess.tr(), false);

        if (!mounted) return;

        // Navigate to PDF preview screen instead of quiz generation
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfPreviewScreen(
              pdfBytes: bytes,
              fileName: file.name,
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reading PDF: $e');
      }
      _showSnackBar(AppStrings.pdfError.tr(), true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.pdfQuizzerUploader.tr()),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            onSelected: (locale) async {
              await context.setLocale(locale);
              if (mounted) {
                setState(() {});
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: Locale('en'),
                child: Text("English"),
              ),
              PopupMenuItem(
                value: Locale('fr'),
                child: Text("Français"),
              ),
              PopupMenuItem(
                value: Locale('ar'),
                child: Text("العربية"),
              ),
            ],
          ),
        ],
      ),
      body: AuraBox(
        spots: [
          AuraSpot(
            color: AppTheme.customColors['primary']!,
            radius: 400.0,
            alignment: Alignment.topRight,
            blurRadius: 5.0,
            stops: const [0.0, 0.5],
          ),
          AuraSpot(
            color: AppTheme.customColors['blue']!,
            radius: 400.0,
            alignment: Alignment.center,
            blurRadius: 5.0,
            stops: const [0.0, 0.5],
          ),
          AuraSpot(
            color: AppTheme.customColors['error']!,
            radius: 300.0,
            alignment: Alignment.bottomRight,
            blurRadius: 10.0,
            stops: const [0.0, 0.7],
          ),
        ],
        decoration: const BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.rectangle,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: uploadAndReadPDF,
                  icon: const Icon(Icons.upload_file),
                  label: Text(AppStrings.uploadPdf.tr()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                AppStrings.pdfOnlyFiles.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
