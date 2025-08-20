import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

// Simple Video Player using WebView for all video types
class InstructorRecordClassVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String title;

  const InstructorRecordClassVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.title,
  });

  @override
  State<InstructorRecordClassVideoPlayer> createState() =>
      _InstructorRecordClassVideoPlayerState();
}

class _InstructorRecordClassVideoPlayerState
    extends State<InstructorRecordClassVideoPlayer> {
  WebViewController? _webController;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.videoUrl));
  }

  Future<void> _openInExternalApp() async {
    try {
      final uri = Uri.parse(widget.videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch video URL');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: _openInExternalApp,
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Open in external app',
          ),
        ],
      ),
      body: Column(
        children: [
          // WebView Video Player
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[900],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    if (_webController != null && !_hasError)
                      WebViewWidget(controller: _webController!),

                    // Loading overlay
                    if (_isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.8),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF7A54FF),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Loading video...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Error overlay
                    if (_hasError)
                      Container(
                        color: Colors.black.withOpacity(0.8),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load video',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _hasError = false;
                                  });
                                  _initializeWebView();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF7A54FF),
                                ),
                                icon: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Retry',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _openInExternalApp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                ),
                                icon: const Icon(
                                  Icons.open_in_new,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Open Externally',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // External link button overlay
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: _openInExternalApp,
                          icon: Icon(
                            Icons.open_in_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: 'Open in external app',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Video Information
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Video URL: ${widget.videoUrl}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
