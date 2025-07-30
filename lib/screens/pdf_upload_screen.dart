import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf_uploader/screens/pdf_preview_screen.dart';
import 'package:pdf_uploader/screens/quiz_history_screen.dart';
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

// first page
class _PdfUploadScreenState extends State<PdfUploadScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  // Variables to track pointer position
  Offset _pointerPosition = Offset.zero;
  bool _isPointerActive = false;

  @override
  void initState() {
    super.initState();

    // Create animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    // Create animations with different curves for more dynamic effect
    _animation1 = Tween<double>(begin: -0.3, end: 0.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animation2 = Tween<double>(begin: 0.3, end: -0.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animation3 = Tween<double>(begin: 350.0, end: 450.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  // Convert screen coordinates to Alignment (-1 to 1 range)
  Alignment _getAlignmentFromPosition(Offset position, Size size) {
    // Convert to -1 to 1 range
    double dx = (position.dx / size.width) * 2 - 1;
    double dy = (position.dy / size.height) * 2 - 1;
    return Alignment(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.pdfQuizzerUploader.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: AppStrings.viewHistory.tr(),
            onPressed: () {
              Navigator.pushNamed(context, QuizHistoryScreen.id);
            },
          ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Listener(
            onPointerDown: (event) {
              setState(() {
                _pointerPosition = event.position;
                _isPointerActive = true;
                _animationController.stop();
              });
            },
            onPointerMove: (event) {
              setState(() {
                _pointerPosition = event.position;
              });
            },
            onPointerUp: (event) {
              setState(() {
                _isPointerActive = false;
                _animationController.repeat(reverse: true);
              });
            },
            onPointerCancel: (event) {
              setState(() {
                _isPointerActive = false;
                _animationController.repeat(reverse: true);
              });
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                // Use either pointer position or animation based on pointer state
                final alignment1 = _isPointerActive
                    ? _getAlignmentFromPosition(
                        _pointerPosition, constraints.biggest)
                    : Alignment(_animation1.value, _animation2.value);

                final alignment2 = _isPointerActive
                    ? Alignment(-alignment1.x * 0.7, -alignment1.y * 0.7)
                    : Alignment(_animation2.value, _animation1.value);

                final alignment3 = _isPointerActive
                    ? Alignment(alignment1.x * 0.5, 0.8)
                    : Alignment(_animation1.value, 0.8);

                return AuraBox(
                  spots: [
                    AuraSpot(
                      color: AppTheme.customColors['primary']!,
                      radius: _animation3.value,
                      alignment: alignment1,
                      blurRadius: 5.0,
                      stops: const [0.0, 0.5],
                    ),
                    AuraSpot(
                      color: AppTheme.customColors['blue']!,
                      radius: _animation3.value - 50,
                      alignment: alignment2,
                      blurRadius: 5.0,
                      stops: const [0.0, 0.5],
                    ),
                    AuraSpot(
                      color: AppTheme.customColors['error']!,
                      radius: 300.0 + (_animation1.value * 50),
                      alignment: alignment3,
                      blurRadius: 10.0,
                      stops: const [0.0, 0.7],
                    ),
                  ],
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  child: child!,
                );
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton.icon(
                        onPressed: uploadAndReadPDF,
                        icon: const Icon(
                          Icons.upload_file,
                          size: 28,
                          color: Colors.white,
                        ),
                        label: Text(AppStrings.uploadPdf.tr()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
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
        },
      ),
    );
  }
}
