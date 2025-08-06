import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class StudyMaterialViewer extends StatefulWidget {
  final String url;
  final String title;
  final String type;

  const StudyMaterialViewer({
    super.key,
    required this.url,
    required this.title,
    required this.type,
  });

  @override
  State<StudyMaterialViewer> createState() => _StudyMaterialViewerState();
}

class _StudyMaterialViewerState extends State<StudyMaterialViewer> {
  bool _isLoading = true;
  String? _error;
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeViewer();
  }

  void _initializeViewer() {
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF7A54FF),
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        // Removed download and bookmark buttons as requested
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7A54FF)),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading ${widget.type.toUpperCase()}...',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load document',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _initializeViewer();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7A54FF),
                ),
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    switch (widget.type.toLowerCase()) {
      case 'pdf':
        return _buildPdfViewer();
      case 'image':
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return _buildImageViewer();
      case 'doc':
      case 'docx':
        return _buildDocViewer();
      default:
        return _buildUnsupportedType();
    }
  }

  Widget _buildPdfViewer() {
    return Container(
      child: SfPdfViewer.network(
        widget.url,
        key: _pdfViewerKey,
        onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
          setState(() {
            _error = details.error;
            _isLoading = false;
          });
        },
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'PDF loaded: ${details.document.pages.count} pages',
              ),
              backgroundColor: Color(0xFF7A54FF),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageViewer() {
    return Center(
      child: InteractiveViewer(
        panEnabled: true,
        boundaryMargin: EdgeInsets.all(20),
        minScale: 0.5,
        maxScale: 4.0,
        child: Image.network(
          widget.url,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF7A54FF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Loading image...'),
                ],
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('Failed to load image', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    'Please check the image URL',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocViewer() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description, size: 80, color: Color(0xFF7A54FF)),
            const SizedBox(height: 24),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7A54FF),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'This document will open in your default browser or Google Docs app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openDocInBrowser(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF7A54FF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.open_in_new,
                  color: Colors.white,
                  size: 24,
                ),
                label: const Text(
                  'Open Document',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF7A54FF)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(Icons.arrow_back, color: Color(0xFF7A54FF), size: 20),
              label: Text(
                'Go Back',
                style: TextStyle(
                  color: Color(0xFF7A54FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnsupportedType() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.file_present, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Unsupported file type',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'File type: ${widget.type}',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openInBrowser,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7A54FF),
              ),
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              label: const Text(
                'Open in Browser',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openInBrowser() async {
    try {
      final uri = Uri.parse(widget.url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch URL';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open URL: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openDocInBrowser() async {
    String url = widget.url;

    // Handle Google Docs URLs - convert edit links to preview for better compatibility
    if (url.contains('docs.google.com') && url.contains('/edit')) {
      url = url.replaceAll('/edit?usp=sharing', '/preview');
      url = url.replaceAll('/edit', '/preview');
    }

    try {
      // Parse the URL
      final uri = Uri.parse(url);

      // Show opening message (like online session)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening document in browser...'),
          backgroundColor: Color(0xFF7A54FF),
          duration: Duration(seconds: 2),
        ),
      );

      // Launch the URL in browser using the same method as online session
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault, // Same as online session
      );

      if (!launched) {
        // Fallback: copy link to clipboard (same as online session)
        _copyToClipboard(context, url, 'Document link');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open browser. Link copied to clipboard.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Error handling: copy link to clipboard as fallback (same as online session)
      _copyToClipboard(context, url, 'Document link');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening browser. Link copied to clipboard.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _copyToClipboard(BuildContext context, String text, String label) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          backgroundColor: Color(0xFF7A54FF),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy $label'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
