import 'package:flutter/material.dart';
import '../models/gdrive_anime.dart';
import '../services/anime_gdrive.service.dart';
import '../services/anime_youtube.service.dart';
import '../theme/app_theme.dart';
import 'anime_detail.screen.dart';

class CategoryViewScreen extends StatefulWidget {
  final String category;

  const CategoryViewScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryViewScreen> createState() => _CategoryViewScreenState();
}

class _CategoryViewScreenState extends State<CategoryViewScreen> {
  List<GDriveAnime> _animes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnimes();
  }

  Future<void> _loadAnimes() async {
    setState(() => _loading = true);

    try {
      List<Map<String, dynamic>> data;
      
      // Check if it's a Google Drive anime
      if (AnimeGDriveService.animeFolders.containsKey(widget.category)) {
        data = await AnimeGDriveService.getAnimeByCategory(widget.category);
      }
      // Check if it's a YouTube anime
      else if (AnimeGDriveService.youtubeAnime.containsKey(widget.category)) {
        final searchQuery = AnimeGDriveService.youtubeAnime[widget.category];
        if (searchQuery != null) {
          data = await AnimeYouTubeService.searchAnime(searchQuery);
          // Convert to GDriveAnime format with source='youtube'
          data = data.map((json) {
            return {
              ...json,
              'fileId': json['videoId'],
              'animeName': widget.category,
              'source': 'youtube',
            };
          }).toList();
        } else {
          data = [];
        }
      } else {
        data = await AnimeGDriveService.getAnimeByCategory(widget.category);
      }
      
      final animes = data.map((json) => GDriveAnime.fromJson(json)).toList();

      setState(() {
        _animes = animes;
        _loading = false;
      });
    } catch (e) {
      print('Error loading category: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Anime'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : RefreshIndicator(
              onRefresh: _loadAnimes,
              color: AppTheme.primaryOrange,
              child: _animes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 80,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ${widget.category} anime found',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _animes.length,
                      itemBuilder: (context, index) {
                        final anime = _animes[index];
                        return _buildAnimeCard(anime);
                      },
                    ),
            ),
    );
  }

  Widget _buildAnimeCard(GDriveAnime anime) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AnimeDetailScreen(anime: anime),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    anime.thumbnail,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: AppTheme.cardBackground,
                        child: const Icon(
                          Icons.broken_image,
                          color: AppTheme.textSecondary,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
                // Duration badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AnimeGDriveService.formatFileSize(anime.fileSize),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      anime.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.visibility,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            anime.animeName,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
