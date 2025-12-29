import 'package:flutter/material.dart';
import '../models/gdrive_anime.dart';
import '../services/anime_gdrive.service.dart';
import '../services/anime_youtube.service.dart';
import '../theme/app_theme.dart';
import 'video.player.screen.dart';

class AnimeDetailScreen extends StatefulWidget {
  final GDriveAnime anime;

  const AnimeDetailScreen({super.key, required this.anime});

  @override
  State<AnimeDetailScreen> createState() => _AnimeDetailScreenState();
}

class _AnimeDetailScreenState extends State<AnimeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<GDriveAnime> _episodes = [];
  bool _loadingEpisodes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEpisodes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEpisodes() async {
    setState(() => _loadingEpisodes = true);

    try {
      List<Map<String, dynamic>> episodesData;
      
      // Check source and load accordingly
      if (widget.anime.source == 'youtube') {
        // For YouTube, search for related videos
        episodesData = await AnimeYouTubeService.searchAnime(widget.anime.animeName);
        // Convert to GDriveAnime format
        episodesData = episodesData.map((json) {
          return {
            ...json,
            'fileId': json['videoId'],
            'animeName': widget.anime.animeName,
            'source': 'youtube',
          };
        }).toList();
      } else {
        // For Google Drive, use existing method
        episodesData = await AnimeGDriveService.getAnimeEpisodes(widget.anime.animeName);
      }
      
      final episodes = episodesData.map((json) => GDriveAnime.fromJson(json)).toList();

      setState(() {
        _episodes = episodes;
        _loadingEpisodes = false;
      });
    } catch (e) {
      print('Error loading episodes: $e');
      setState(() {
        _episodes = [];
        _loadingEpisodes = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildAnimeInfo(),
                _buildTabBar(),
              ],
            ),
          ),
          _buildTabBarView(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppTheme.darkBackground,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.anime.animeName,
          style: const TextStyle(
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black87,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              widget.anime.thumbnail,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.cardBackground,
                  child: const Icon(
                    Icons.broken_image,
                    size: 80,
                    color: AppTheme.textSecondary,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.darkBackground.withOpacity(0.7),
                    AppTheme.darkBackground,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimeInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Channel and date
          Row(
            children: [
              const Icon(Icons.verified, size: 16, color: AppTheme.primaryOrange),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.anime.animeName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryOrange,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AnimeGDriveService.formatPublishedDate(widget.anime.createdTime),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatChip(
                Icons.video_library,
                widget.anime.animeName,
              ),
              _buildStatChip(
                Icons.storage,
                AnimeGDriveService.formatFileSize(widget.anime.fileSize),
              ),
              _buildStatChip(
                Icons.video_file,
                'Episode ${widget.anime.episodeNumber ?? "?"}',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Play Now Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(
                      episodeId: widget.anime.fileId,
                      animeTitle: widget.anime.animeName,
                      episodeNumber: widget.anime.episodeNumber,
                      source: widget.anime.source,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text(
                'Play Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          if (widget.anime.description.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.anime.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryOrange),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.darkBackground,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.primaryOrange,
        labelColor: AppTheme.primaryOrange,
        unselectedLabelColor: AppTheme.textSecondary,
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.list),
                const SizedBox(width: 8),
                Text(_episodes.isNotEmpty
                    ? 'Episodes (${_episodes.length})'
                    : 'Episodes'),
              ],
            ),
          ),
          const Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 8),
                Text('Details'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildEpisodesList(),
          _buildDetailsTab(),
        ],
      ),
    );
  }

  Widget _buildEpisodesList() {
    if (_loadingEpisodes) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryOrange),
      );
    }

    if (_episodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_off,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No related episodes found',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for more episodes',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _episodes.length,
      itemBuilder: (context, index) {
        final episode = _episodes[index];
        return _buildEpisodeCard(episode, index);
      },
    );
  }

  Widget _buildEpisodeCard(GDriveAnime episode, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                episodeId: episode.fileId,
                animeTitle: widget.anime.animeName,
                episodeNumber: episode.episodeNumber ?? (index + 1),
                source: episode.source,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      episode.thumbnail,
                      width: 120,
                      height: 68,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.broken_image,
                            color: AppTheme.textSecondary,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ),
                  // Duration
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AnimeGDriveService.formatFileSize(episode.fileSize),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Play icon overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.3),
                      ),
                      child: const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Episode number if available
                    if (episode.episodeNumber != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'EP ${episode.episodeNumber}',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    
                    // Title
                    Text(
                      episode.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Views and date
                    Row(
                      children: [
                        const Icon(Icons.visibility,
                            size: 12, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Episode ${episode.episodeNumber ?? index + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AnimeGDriveService.formatPublishedDate(
                                episode.createdTime),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('File ID', widget.anime.fileId),
          _buildDetailRow('Anime', widget.anime.animeName),
          _buildDetailRow(
              'Created',
              AnimeGDriveService.formatPublishedDate(
                  widget.anime.createdTime)),
          _buildDetailRow('File Size',
              AnimeGDriveService.formatFileSize(widget.anime.fileSize)),
          _buildDetailRow('Episode',
              widget.anime.episodeNumber?.toString() ?? 'Unknown'),
          const SizedBox(height: 16),
          
          if (widget.anime.description.isNotEmpty) ...[
            const Text(
              'Full Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.anime.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

