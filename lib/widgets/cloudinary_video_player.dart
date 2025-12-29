import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../services/anime_cloudinary.service.dart';
import '../theme/app_theme.dart';

class CloudinaryVideoPlayer extends StatefulWidget {
  final String publicId;

  const CloudinaryVideoPlayer({
    super.key,
    required this.publicId,
  });

  @override
  State<CloudinaryVideoPlayer> createState() => _CloudinaryVideoPlayerState();
}

class _CloudinaryVideoPlayerState extends State<CloudinaryVideoPlayer> {
  late WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      final videoUrl = AnimeCloudinaryService.getVideoUrl(widget.publicId);

      // Create HTML content for video player with fullscreen support
      final htmlContent = '''
      <!DOCTYPE html>
      <html>
      <head>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
              * {
                  margin: 0;
                  padding: 0;
                  box-sizing: border-box;
              }
              body {
                  background-color: #000;
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  height: 100vh;
                  overflow: hidden;
              }
              video {
                  width: 100%;
                  height: 100%;
                  object-fit: contain;
                  outline: none;
              }
              video::-webkit-media-controls-fullscreen-button {
                  display: block !important;
                  -webkit-appearance: media-controls-fullscreen-button;
              }
              video::-webkit-media-controls {
                  overflow: visible !important;
              }
              video::-webkit-media-controls-panel {
                  display: flex !important;
              }
          </style>
      </head>
      <body>
          <video 
              id="videoPlayer"
              controls 
              autoplay 
              preload="auto"
              playsinline
              webkit-playsinline
              allowfullscreen
              webkitallowfullscreen
              mozallowfullscreen>
              <source src="$videoUrl" type="video/mp4">
              Your browser does not support the video tag.
          </video>
          
          <script>
              const video = document.getElementById('videoPlayer');
              
              // Handle fullscreen properly without errors
              video.addEventListener('fullscreenchange', function(e) {
                  try {
                      console.log('Fullscreen changed:', !!document.fullscreenElement);
                  } catch (err) {
                      console.log('Fullscreen change handled:', err);
                  }
              });
              
              video.addEventListener('webkitfullscreenchange', function(e) {
                  try {
                      console.log('Webkit fullscreen changed:', !!document.webkitFullscreenElement);
                  } catch (err) {
                      console.log('Webkit fullscreen change handled:', err);
                  }
              });
              
              // Handle fullscreen errors gracefully
              video.addEventListener('fullscreenerror', function(e) {
                  console.log('Fullscreen error handled gracefully');
              });
              
              video.addEventListener('webkitfullscreenerror', function(e) {
                  console.log('Webkit fullscreen error handled gracefully');
              });
              
              // Handle video errors gracefully
              video.addEventListener('error', function(e) {
                  console.log('Video error handled:', e);
                  // Don't reload automatically, just log the error
              });
              
              // Prevent context menu
              video.addEventListener('contextmenu', function(e) {
                  e.preventDefault();
              });
              
              // Handle orientation changes for fullscreen
              window.addEventListener('orientationchange', function() {
                  setTimeout(function() {
                      if (document.fullscreenElement || document.webkitFullscreenElement) {
                          video.style.width = '100vw';
                          video.style.height = '100vh';
                      }
                  }, 500);
              });
              
              // Prevent double-tap zoom outside fullscreen
              let lastTouchEnd = 0;
              document.addEventListener('touchend', function(event) {
                  if (!document.fullscreenElement && !document.webkitFullscreenElement) {
                      const now = (new Date()).getTime();
                      if (now - lastTouchEnd <= 300) {
                          event.preventDefault();
                      }
                      lastTouchEnd = now;
                  }
              }, false);
          </script>
      </body>
      </html>
      ''';

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                _isLoading = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              print('WebView error: ${error.description}');
              // Don't show error for minor issues, just log them
              if (error.errorType == WebResourceErrorType.hostLookup ||
                  error.errorType == WebResourceErrorType.timeout) {
                setState(() {
                  _errorMessage =
                      'Network error. Please check your connection.';
                  _isLoading = false;
                });
              }
            },
            onNavigationRequest: (NavigationRequest request) {
              // Prevent navigation away from video
              if (request.url.contains('cloudinary.com') ||
                  request.url.startsWith('data:')) {
                return NavigationDecision.navigate;
              }
              return NavigationDecision.prevent;
            },
          ),
        )
        ..loadHtmlString(htmlContent);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing video: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _initializeWebView();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryOrange,
                  ),
                  SizedBox(height: 16),
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
        ],
      ),
    );
  }
}
