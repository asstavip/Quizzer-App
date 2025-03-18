import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf_uploader/screens/quiz_generation_screen.dart';
import 'package:pdf_uploader/utils/strings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../theme/app_theme.dart';

class PdfPreviewScreen extends StatefulWidget {
  static const String id = 'pdf_preview_screen';
  final Uint8List pdfBytes;
  final String fileName;

  const PdfPreviewScreen({
    super.key, 
    required this.pdfBytes,
    required this.fileName,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late int _totalPages;
  String? _localPath;
  final Set<int> _selectedPages = {};
  bool _isLoading = true;
  int _currentPage = 1;

  // Range selection variables
  bool _isRangeSelectionMode = false;
  int _rangeStart = 0;
  int _rangeEnd = 0;

  // Handle range selection
  void _handleRangeSelection() {
    if (_rangeStart > 0 && _rangeEnd > 0) {
      setState(() {
        // Make sure start is less than end
        int start = _rangeStart < _rangeEnd ? _rangeStart : _rangeEnd;
        int end = _rangeStart < _rangeEnd ? _rangeEnd : _rangeStart;

        // Add all pages in range to selected pages
        for (int i = start; i <= end; i++) {
          _selectedPages.add(i);
        }

        // Reset range selection mode
        _isRangeSelectionMode = false;
        _rangeStart = 0;
        _rangeEnd = 0;
      });
    }
  }

  // Select a page in range mode
  void _selectPageInRangeMode(int page) {
    setState(() {
      if (_rangeStart == 0) {
        _rangeStart = page;
      } else {
        _rangeEnd = page;
        _handleRangeSelection();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _initializePdf();
  }

  Future<void> _initializePdf() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp.pdf');
      await file.writeAsBytes(widget.pdfBytes);
      _localPath = file.path;

      final document = PdfDocument(inputBytes: widget.pdfBytes);
      _totalPages = document.pages.count;
      document.dispose();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading PDF: $e')),
        );
      }
    }
  }

  Future<String> _extractSelectedPagesText() async {
    final document = PdfDocument(inputBytes: widget.pdfBytes);
    String extractedText = '';

    List<int> sortedPages = _selectedPages.toList()..sort();
    for (int pageNumber in sortedPages) {
      final text = PdfTextExtractor(document).extractText(
        startPageIndex: pageNumber - 1,
        endPageIndex: pageNumber - 1,
      );
      extractedText += '$text\n';
    }

    document.dispose();
    return extractedText.trim();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${AppStrings.page.tr()} $_currentPage/$_totalPages',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // PDF Viewer section remains the same
          Expanded(
            flex: 3,
            child: _localPath == null
                ? const Center(child: CircularProgressIndicator())
                : PDFView(
              filePath: _localPath!,
              enableSwipe: true,
              swipeHorizontal: true,
              autoSpacing: true,
              pageFling: true,
              pageSnap: true,
              defaultPage: 0,
              fitPolicy: FitPolicy.WIDTH,
              fitEachPage: true,
              preventLinkNavigation: false,
              onPageChanged: (page, total) {
                setState(() {
                  _currentPage = page! + 1;
                });
              },
              onRender: (pages) {
                setState(() {
                  _totalPages = pages!;
                });
              },
              onError: (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.toString())),
                  );
                }
              },
              onPageError: (page, error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error on page $page: $error')),
                  );
                }
              },
            ),
          ),
          // Page Selection and Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Range selection indicator
                if (_isRangeSelectionMode)
                  Container(
                    color: Colors.amber.shade100,
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    width: double.infinity,
                    child: Text(
                      _rangeStart > 0
                          ? 'Select ending page for range (started with page $_rangeStart)'
                          : 'Select starting page for range',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                // Page Selection Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      for (int i = 1; i <= _totalPages; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text('${AppStrings.page.tr()} $i',style: TextStyle(
                              color: _selectedPages.contains(i) ? Colors.white : Colors.black,
                            ),),
                            selected: _selectedPages.contains(i) ||
                                (_isRangeSelectionMode && _rangeStart == i),
                            backgroundColor: _isRangeSelectionMode && _rangeStart == i
                                ? Colors.amber.shade200
                                : null,
                            selectedColor: AppTheme.customColors['primary'],
                            onSelected: (bool selected) {
                              if (_isRangeSelectionMode) {
                                _selectPageInRangeMode(i);
                              } else {
                                setState(() {
                                  if (selected) {
                                    _selectedPages.add(i);
                                  } else {
                                    _selectedPages.remove(i);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                // Bottom Actions
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextButton.icon(
                              onPressed: _isRangeSelectionMode ? null : () {
                                setState(() {
                                  if (_selectedPages.length == _totalPages) {
                                    _selectedPages.clear();
                                  } else {
                                    _selectedPages.clear();
                                    for (int i = 1; i <= _totalPages; i++) {
                                      _selectedPages.add(i);
                                    }
                                  }
                                });
                              },
                              icon: Icon(_selectedPages.length == _totalPages ? Icons.deselect : Icons.select_all),
                              label: Text(_selectedPages.length == _totalPages ? AppStrings.clearSelection.tr() : AppStrings.selectAll.tr()),
                            ),
                          ),
                          // Range selection toggle button
                          Expanded(
                            child: TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _isRangeSelectionMode = !_isRangeSelectionMode;
                                  _rangeStart = 0;
                                  _rangeEnd = 0;
                                });
                              },
                              icon: Icon(_isRangeSelectionMode ? Icons.close : Icons.linear_scale),
                              label: Text(_isRangeSelectionMode ? 'Cancel Range' : 'Select Range'),
                              style: ButtonStyle(
                                foregroundColor: MaterialStateProperty.all(
                                  _isRangeSelectionMode ? Colors.red : Colors.blue,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _selectedPages.isEmpty || _isRangeSelectionMode
                            ? null
                            : () async {
                          final extractedText = await _extractSelectedPagesText();
                          if (mounted) {
                            Navigator.pushNamed(
                              context,
                              QuizGenerationScreen.id,
                              arguments: {
                                'text': extractedText,
                                'fileName': widget.fileName,
                                'selectedPages': _selectedPages.toList(),
                              },
                            );
                          }
                        },
                        icon: const Icon(Icons.quiz, size: 18, color: Colors.white),
                        label: Text(
                          AppStrings.generateQuizSelected.tr(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    if (_localPath != null) {
      File(_localPath!).delete().then(
        (_) {},
        onError: (e) => debugPrint('Error deleting temp file: $e'),
      );
    }
    super.dispose();
  }
}