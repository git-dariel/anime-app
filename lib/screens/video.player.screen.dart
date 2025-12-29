import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String episodeId;
  final String animeTitle;
  final int? episodeNumber;

  const VideoPlayerScreen({
    super.key,
    required this.episodeId,
    required this.animeTitle,
    this.episodeNumber,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();
    // Automatically attempt to open YouTube when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openInYouTube();
    });
  }

  Future<void> _openInYouTube() async {
    if (_isOpening) return;
    
    setState(() => _isOpening = true);
    
    // Try YouTube app first, then browser
    final youtubeAppUrl = 'vnd.youtube://${widget.episodeId}';
    final youtubeWebUrl = 'https://www.youtube.com/watch?v=${widget.episodeId}';
    
    try {
      // Try to open in YouTube app
      final appUri = Uri.parse(youtubeAppUrl);
      if (await canLaunchUrl(appUri)) {
        final launched = await launchUrl(
          appUri,
          mode: LaunchMode.externalApplication,
        );
        
        if (launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening in YouTube app...'),
              duration: Duration(seconds: 2),
              backgroundColor: AppTheme.primaryOrange,
            ),
          );
        }
      } else {
        // Fallback to browser
        final webUri = Uri.parse(youtubeWebUrl);
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Opening in browser...'),
              duration: Duration(seconds: 2),
              backgroundColor: AppTheme.primaryOrange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error opening YouTube: $e');
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
              // YouTube Icon
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
              const Text(
                'Watch on YouTube',
                style: TextStyle(
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
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Videos open in YouTube for the best viewing experience with no buffering or playback issues.',
                            style: TextStyle(
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
              
              // Watch on YouTube button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isOpening ? null : _openInYouTube,
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
                    _isOpening ? 'Opening...' : 'Watch on YouTube',
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
              
              // Why this works better
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
                          'Why YouTube App?',
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
                      '✓ No loading or buffering issues\n'
                      '✓ Better video quality (up to 4K)\n'
                      '✓ Full playback controls\n'
                      '✓ Works with all videos\n'
                      '✓ Save battery and data',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Video ID display (for debugging)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.video_library,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Video ID: ${widget.episodeId}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        fontFamily: 'monospace',
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
