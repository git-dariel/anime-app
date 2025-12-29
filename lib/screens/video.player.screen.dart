import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String episodeId;
  final String animeTitle;
  final int? episodeNumber;
  final String source; // 'gdrive' or 'youtube'

  const VideoPlayerScreen({
    super.key,
    required this.episodeId,
    required this.animeTitle,
    this.episodeNumber,
    this.source = 'gdrive',
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    // Automatically attempt to open Google Drive when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openInGoogleDrive();
    });
  }

  Future<void> _openInGoogleDrive() async {
    if (_isOpening) return;
    
    setState(() => _isOpening = true);
    
    try {
      if (widget.source == 'youtube') {
        // YouTube URLs - using multiple formats for better compatibility
        final youtubeAppUrl = 'youtube://watch?v=${widget.episodeId}';
        final youtubeWebUrl = 'https://www.youtube.com/watch?v=${widget.episodeId}';
        
        bool launched = false;
        
        // Try to open in YouTube app
        try {
          final appUri = Uri.parse(youtubeAppUrl);
          launched = await launchUrl(
            appUri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          print('YouTube app not available: $e');
        }
        
        if (!launched) {
          // Fallback to web URL
          final webUri = Uri.parse(youtubeWebUrl);
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opening in YouTube...'),
                duration: Duration(seconds: 2),
                backgroundColor: AppTheme.primaryOrange,
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening in YouTube app...'),
              duration: Duration(seconds: 2),
              backgroundColor: AppTheme.primaryOrange,
            ),
          );
        }
      } else {
        // Google Drive URLs
        final driveAppUrl = 'google-drive://file?id=${widget.episodeId}';
        final driveWebUrl = 'https://drive.google.com/file/d/${widget.episodeId}/view';
        
        bool launched = false;
        
        // Try to open in Google Drive app first
        try {
          final appUri = Uri.parse(driveAppUrl);
          launched = await launchUrl(
            appUri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          print('Google Drive app not available: $e');
        }
        
        if (!launched) {
          // Fallback to web URL
          final webUri = Uri.parse(driveWebUrl);
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Opening in Google Drive...'),
                duration: Duration(seconds: 2),
                backgroundColor: AppTheme.primaryOrange,
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening in Google Drive app...'),
              duration: Duration(seconds: 2),
              backgroundColor: AppTheme.primaryOrange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error opening video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOpening = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.animeTitle,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.episodeNumber != null)
              Text(
                'Episode ${widget.episodeNumber}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Google Drive Icon
              Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  size: 90,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                widget.source == 'youtube' ? 'Watch on YouTube' : 'Watch on Google Drive',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryOrange.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.animeTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.episodeNumber != null) ...[ 
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Episode ${widget.episodeNumber}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.source == 'youtube' 
                                ? 'Videos open in YouTube app for the best viewing experience.'
                                : 'Videos open in Google Drive app for the best viewing experience.',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Watch button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isOpening ? null : _openInGoogleDrive,
                  icon: _isOpening
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow, size: 28),
                  label: Text(
                    widget.source == 'youtube' 
                        ? (_isOpening ? 'Opening...' : 'Watch on YouTube')
                        : (_isOpening ? 'Opening...' : 'Watch on Google Drive'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppTheme.primaryOrange,
                    disabledBackgroundColor:
                        AppTheme.primaryOrange.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Go back button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text(
                    'Go Back',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: AppTheme.primaryOrange,
                      width: 2,
                    ),
                    foregroundColor: AppTheme.primaryOrange,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Why Google Drive
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.primaryOrange,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Why Google Drive?',
                          style: TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '✓ Direct streaming from Google Drive\n'
                      '✓ High quality video playback\n'
                      '✓ Full playback controls\n'
                      '✓ Works with all your anime\n'
                      '✓ Reliable and fast',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
