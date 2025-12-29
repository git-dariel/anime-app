import 'package:flutter/material.dart';
import '../models/gdrive_anime.dart';
import '../services/anime_gdrive.service.dart';
import '../services/anime_youtube.service.dart';
import '../theme/app_theme.dart';
import 'anime_detail.screen.dart';
import 'search.screen.dart';
import 'category_view.screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GDriveAnime> _featuredAnime = [];
  Map<String, List<GDriveAnime>> _categoryAnime = {};
  bool _loading = true;

  // Get available anime from both services
  List<String> get categories {
    final allCategories = <String>[];
    allCategories.addAll(AnimeGDriveService.youtubeAnime.keys); // YouTube first
    allCategories.addAll(AnimeGDriveService.animeFolders.keys); // Google Drive second
    return allCategories;
  }

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _loading = true);

    try {
      // Load featured anime from Google Drive
      final featuredData = await AnimeGDriveService.getFeaturedAnime();
      final featured =
          featuredData.map((json) => GDriveAnime.fromJson(json)).toList();

      // Load anime by each available anime series
      Map<String, List<GDriveAnime>> categoryData = {};
      
      // Load Google Drive anime
      for (String animeName in AnimeGDriveService.animeFolders.keys) {
        final folderId = AnimeGDriveService.animeFolders[animeName];
        if (folderId != null) {
          final data = await AnimeGDriveService.getAnimeByFolder(folderId, animeName);
          categoryData[animeName] =
              data.map((json) => GDriveAnime.fromJson(json)).toList();
        }
      }
      
      // Load YouTube anime
      for (String animeName in AnimeGDriveService.youtubeAnime.keys) {
        final searchQuery = AnimeGDriveService.youtubeAnime[animeName];
        if (searchQuery != null) {
          final data = await AnimeYouTubeService.searchAnime(searchQuery);
          // Convert YouTube data to GDriveAnime format with source='youtube'
          categoryData[animeName] = data.map((json) {
            return GDriveAnime.fromJson({
              ...json,
              'fileId': json['videoId'],
              'animeName': animeName,
              'source': 'youtube',
            });
          }).toList();
        }
      }

      setState(() {
        _featuredAnime = featured;
        _categoryAnime = categoryData;
        _loading = false;
      });
    } catch (e) {
      print('Error loading content: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 40,
              width: 40,
            ),
            const SizedBox(width: 12),
            const Text('KAGE TV'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadContent,
              color: AppTheme.primaryOrange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Section
                    if (_featuredAnime.isNotEmpty) _buildFeaturedSection(),

                    // Categories
                    for (String category in categories)
                      if (_categoryAnime[category]?.isNotEmpty ?? false)
                        _buildCategorySection(
                          category,
                          _categoryAnime[category]!,
                        ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '🔥 Popular & Trending Worldwide',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: _featuredAnime.length, // Show all featured anime
            itemBuilder: (context, index) {
              final anime = _featuredAnime[index];
              return _buildFeaturedCard(anime);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFeaturedCard(GDriveAnime anime) {
    return GestureDetector(
      onTap: () => _navigateToDetail(anime),
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    anime.thumbnail,
                    width: 200,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 180,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.broken_image,
                          color: AppTheme.textSecondary,
                          size: 48,
                        ),
                      );
                    },
                  ),
                ),
                // Play button overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
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
            const SizedBox(height: 8),
            // Title
            Text(
              anime.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Channel and views
            Row(
              children: [
                const Icon(Icons.visibility,
                    size: 12, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    anime.animeName,
                    style: const TextStyle(
                      fontSize: 11,
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
    );
  }

  Widget _buildCategorySection(String category, List<GDriveAnime> animes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryViewScreen(category: category),
                    ),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(color: AppTheme.primaryOrange),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: animes.length, // Show all category anime
            itemBuilder: (context, index) {
              final anime = animes[index];
              return _buildCategoryCard(anime);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategoryCard(GDriveAnime anime) {
    return GestureDetector(
      onTap: () => _navigateToDetail(anime),
      child: Container(
        width: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    anime.thumbnail,
                    width: 160,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 160,
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.broken_image,
                          color: AppTheme.textSecondary,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                // Duration badge
                Positioned(
                  bottom: 6,
                  right: 6,
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
            const SizedBox(height: 6),
            // Title
            Text(
              anime.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            // Anime name
            Text(
              anime.animeName,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetail(GDriveAnime anime) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnimeDetailScreen(anime: anime),
      ),
    );
  }
}
