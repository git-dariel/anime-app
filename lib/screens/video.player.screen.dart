import 'package:flutter/material.dart';
import '../widgets/cloudinary_video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  final String publicId;
  final String animeTitle;
  final int? episodeNumber;

  const VideoPlayerScreen({
    super.key,
    required this.publicId,
    required this.animeTitle,
    this.episodeNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              animeTitle,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
            if (episodeNumber != null)
              Text(
                'Episode $episodeNumber',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: CloudinaryVideoPlayer(publicId: publicId),
      ),
    );
  }
}
