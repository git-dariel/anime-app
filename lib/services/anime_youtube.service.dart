import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimeYouTubeService {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';
  static const String _apiKey = 'AIzaSyB_gG5jmhGieBFK3sktEySkbimLT8UCb6k';

  // Official anime channels that provide legal content
  static const Map<String, String> officialChannels = {
    'UC0YX_CEK6X5NyGh8_9PdFhw': 'Muse Asia',
    'UC1opHUrw8rvnsadT-iGp7Cg': 'Ani-One Asia',
    'UCwcqxpbtBrPAEk6Qig8XUbQ': 'Crunchyroll Collection',
    'UCDK505KMJweWz5kREJeRMMw': 'Crunchyroll Dubs',
    'UCF1JIsfucWvCMzvGZ_7EFWw': 'Funimation',
    'UCIwFGIsJwRpb63r6nMcR_8A': 'Gundam Info',
  };

  /// Get featured anime (popular and trending worldwide) - FAST VERSION
  static Future<List<Map<String, dynamic>>> getFeaturedAnime() async {
    try {
      // SINGLE OPTIMIZED SEARCH for speed
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'part': 'snippet',
          'q': 'trending anime 2024', // Single broad search
          'type': 'video',
          'maxResults': '10', // Get 10 videos in one call
          'key': _apiKey,
          'order': 'viewCount', // Most popular
          'videoEmbeddable': 'true',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 403) {
        print('Featured: API quota exceeded (403)');
        return _getSampleAnimeData();
      } else if (response.statusCode != 200) {
        print('Featured: Search returned ${response.statusCode}');
        return _getSampleAnimeData();
      }

      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>? ?? [];

      if (items.isEmpty) {
        print('Featured: No videos found');
        return _getSampleAnimeData();
      }

      final videoIds = items
          .where((item) => item['id']?['videoId'] != null)
          .map((item) => item['id']['videoId'])
          .join(',');

      if (videoIds.isEmpty) return _getSampleAnimeData();

      // Get video details in one batch call
      final videosUri = Uri.parse('$_baseUrl/videos').replace(
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoIds,
          'key': _apiKey,
        },
      );

      final videosResponse = await http.get(videosUri);
      if (videosResponse.statusCode != 200) return _getSampleAnimeData();

      final videosData = json.decode(videosResponse.body);
      final videos = videosData['items'] as List<dynamic>? ?? [];

      final results = videos.map<Map<String, dynamic>>((video) {
        final snippet = video['snippet'] as Map<String, dynamic>;
        final statistics = video['statistics'] as Map<String, dynamic>? ?? {};
        final contentDetails =
            video['contentDetails'] as Map<String, dynamic>? ?? {};

        return {
          'videoId': video['id'],
          'title': snippet['title'] ?? 'Untitled',
          'description': snippet['description'] ?? '',
          'thumbnail': snippet['thumbnails']?['high']?['url'] ??
              snippet['thumbnails']?['medium']?['url'] ??
              snippet['thumbnails']?['default']?['url'] ??
              '',
          'channelTitle': snippet['channelTitle'] ?? 'Unknown',
          'channelId': snippet['channelId'] ?? '',
          'publishedAt': snippet['publishedAt'] ?? '',
          'viewCount': statistics['viewCount'] ?? '0',
          'likeCount': statistics['likeCount'] ?? '0',
          'duration': contentDetails['duration'] ?? '',
        };
      }).toList();

      // Sort by view count
      results.sort((a, b) {
        final viewsA = int.tryParse(a['viewCount']?.toString() ?? '0') ?? 0;
        final viewsB = int.tryParse(b['viewCount']?.toString() ?? '0') ?? 0;
        return viewsB.compareTo(viewsA);
      });

      print('Featured: Returning ${results.length} videos (fast load)');
      return results;
    } catch (e) {
      print('Error getting featured anime: $e');
      return _getSampleAnimeData();
    }
  }

  /// Search for trending anime content
  static Future<List<Map<String, dynamic>>> _searchTrendingAnime(
    String animeTitle, {
    int maxResults = 5,
  }) async {
    try {
      final query = '$animeTitle anime full episode';
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': maxResults.toString(),
          'key': _apiKey,
          'order': 'viewCount', // Sort by most viewed for trending
          'videoEmbeddable': 'true',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 403) {
        print('YouTube API quota exceeded (403).');
        return [];
      } else if (response.statusCode != 200) {
        print('Search failed: ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>? ?? [];

      // Get video IDs to fetch full details
      final videoIds = items
          .where((item) => item['id']?['videoId'] != null)
          .map((item) => item['id']['videoId'])
          .join(',');

      if (videoIds.isEmpty) return [];

      final videosUri = Uri.parse('$_baseUrl/videos').replace(
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoIds,
          'key': _apiKey,
        },
      );

      final videosResponse = await http.get(videosUri);
      if (videosResponse.statusCode != 200) return [];

      final videosData = json.decode(videosResponse.body);
      final videos = videosData['items'] as List<dynamic>? ?? [];

      return videos.map<Map<String, dynamic>>((video) {
        final snippet = video['snippet'] as Map<String, dynamic>;
        final statistics = video['statistics'] as Map<String, dynamic>? ?? {};
        final contentDetails =
            video['contentDetails'] as Map<String, dynamic>? ?? {};

        return {
          'videoId': video['id'],
          'title': snippet['title'] ?? 'Untitled',
          'description': snippet['description'] ?? '',
          'thumbnail': snippet['thumbnails']?['high']?['url'] ??
              snippet['thumbnails']?['medium']?['url'] ??
              snippet['thumbnails']?['default']?['url'] ??
              '',
          'channelTitle': snippet['channelTitle'] ?? 'Unknown',
          'channelId': snippet['channelId'] ?? '',
          'publishedAt': snippet['publishedAt'] ?? '',
          'viewCount': statistics['viewCount'] ?? '0',
          'likeCount': statistics['likeCount'] ?? '0',
          'duration': contentDetails['duration'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error searching trending anime: $e');
      return [];
    }
  }

  /// Get date string for X months ago (for publishedAfter filter)
  static String _getDateMonthsAgo(int months) {
    final date = DateTime.now().subtract(Duration(days: months * 30));
    // YouTube API requires RFC 3339 format
    return date.toUtc().toIso8601String();
  }

  /// Get sample anime data when API is unavailable
  static List<Map<String, dynamic>> _getSampleAnimeData() {
    return [
      {
        'videoId': 'j2hiC9BmJlQ',
        'title': 'One Piece - Official Trailer',
        'description': 'Watch One Piece anime',
        'thumbnail': 'https://i.ytimg.com/vi/j2hiC9BmJlQ/hqdefault.jpg',
        'channelTitle': 'Crunchyroll Collection',
        'channelId': 'UCwcqxpbtBrPAEk6Qig8XUbQ',
        'publishedAt': '2023-01-01T00:00:00Z',
        'viewCount': '1000000',
        'likeCount': '50000',
        'duration': 'PT23M45S',
      },
      {
        'videoId': 'bwaBZgqHgXE',
        'title': 'Demon Slayer - Episode 1',
        'description': 'Watch Demon Slayer anime',
        'thumbnail': 'https://i.ytimg.com/vi/bwaBZgqHgXE/hqdefault.jpg',
        'channelTitle': 'Ani-One Asia',
        'channelId': 'UC1opHUrw8rvnsadT-iGp7Cg',
        'publishedAt': '2023-01-01T00:00:00Z',
        'viewCount': '2000000',
        'likeCount': '80000',
        'duration': 'PT24M12S',
      },
      {
        'videoId': 'wJl0RxTPVeU',
        'title': 'Attack on Titan - Season 1',
        'description': 'Watch Attack on Titan anime',
        'thumbnail': 'https://i.ytimg.com/vi/wJl0RxTPVeU/hqdefault.jpg',
        'channelTitle': 'Crunchyroll',
        'channelId': 'UCwcqxpbtBrPAEk6Qig8XUbQ',
        'publishedAt': '2023-01-01T00:00:00Z',
        'viewCount': '5000000',
        'likeCount': '150000',
        'duration': 'PT24M32S',
      },
    ];
  }

  /// Get anime by category/genre (trending in that category) - FAST VERSION
  static Future<List<Map<String, dynamic>>> getAnimeByCategory(
      String category) async {
    try {
      // Optimized search - reduced results for speed
      final query = '$category anime trending';

      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': '10', // Only 10 videos per category for fast load
          'key': _apiKey,
          'order': 'viewCount', // Most popular
          'videoEmbeddable': 'true',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 403) {
        print('Category $category: API quota exceeded (403)');
        return _getSampleAnimeData();
      } else if (response.statusCode != 200) {
        print('Category $category: Search returned ${response.statusCode}');
        return _getSampleAnimeData();
      }

      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>? ?? [];

      final videoIds = items
          .where((item) => item['id']?['videoId'] != null)
          .map((item) => item['id']['videoId'])
          .join(',');

      if (videoIds.isEmpty) return _getSampleAnimeData();

      final videosUri = Uri.parse('$_baseUrl/videos').replace(
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoIds,
          'key': _apiKey,
        },
      );

      final videosResponse = await http.get(videosUri);
      if (videosResponse.statusCode != 200) return _getSampleAnimeData();

      final videosData = json.decode(videosResponse.body);
      final videos = videosData['items'] as List<dynamic>? ?? [];

      final results = videos.map<Map<String, dynamic>>((video) {
        final snippet = video['snippet'] as Map<String, dynamic>;
        final statistics = video['statistics'] as Map<String, dynamic>? ?? {};
        final contentDetails =
            video['contentDetails'] as Map<String, dynamic>? ?? {};

        return {
          'videoId': video['id'],
          'title': snippet['title'] ?? 'Untitled',
          'description': snippet['description'] ?? '',
          'thumbnail': snippet['thumbnails']?['high']?['url'] ??
              snippet['thumbnails']?['medium']?['url'] ??
              snippet['thumbnails']?['default']?['url'] ??
              '',
          'channelTitle': snippet['channelTitle'] ?? 'Unknown',
          'channelId': snippet['channelId'] ?? '',
          'publishedAt': snippet['publishedAt'] ?? '',
          'viewCount': statistics['viewCount'] ?? '0',
          'likeCount': statistics['likeCount'] ?? '0',
          'duration': contentDetails['duration'] ?? '',
        };
      }).toList();

      if (results.isEmpty) {
        return _getSampleAnimeData();
      }

      print('Category $category: Loaded ${results.length} videos');
      return results;
    } catch (e) {
      print('Error getting anime by category: $e');
      return _getSampleAnimeData();
    }
  }

  /// Get popular anime from specific channel
  static Future<List<Map<String, dynamic>>> _getChannelPopularVideos(
    String channelId, {
    int maxResults = 10,
  }) async {
    try {
      // First, get channel's uploads playlist
      final channelUri = Uri.parse('$_baseUrl/channels').replace(
        queryParameters: {
          'part': 'contentDetails',
          'id': channelId,
          'key': _apiKey,
        },
      );

      final channelResponse = await http.get(channelUri);
      if (channelResponse.statusCode != 200) return [];

      final channelData = json.decode(channelResponse.body);
      final items = channelData['items'] as List<dynamic>? ?? [];
      if (items.isEmpty) return [];

      final uploadsPlaylistId =
          items[0]['contentDetails']['relatedPlaylists']['uploads'] as String?;
      if (uploadsPlaylistId == null) return [];

      // Get videos from uploads playlist
      final playlistUri = Uri.parse('$_baseUrl/playlistItems').replace(
        queryParameters: {
          'part': 'snippet,contentDetails',
          'playlistId': uploadsPlaylistId,
          'maxResults': maxResults.toString(),
          'key': _apiKey,
        },
      );

      final playlistResponse = await http.get(playlistUri);
      if (playlistResponse.statusCode != 200) return [];

      final playlistData = json.decode(playlistResponse.body);
      final playlistItems = playlistData['items'] as List<dynamic>? ?? [];

      // Get video IDs and fetch their details
      final videoIds = playlistItems
          .map((item) => item['contentDetails']['videoId'])
          .join(',');

      if (videoIds.isEmpty) return [];

      final videosUri = Uri.parse('$_baseUrl/videos').replace(
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoIds,
          'key': _apiKey,
        },
      );

      final videosResponse = await http.get(videosUri);
      if (videosResponse.statusCode != 200) return [];

      final videosData = json.decode(videosResponse.body);
      final videos = videosData['items'] as List<dynamic>? ?? [];

      return videos.map<Map<String, dynamic>>((video) {
        final snippet = video['snippet'] as Map<String, dynamic>;
        final statistics = video['statistics'] as Map<String, dynamic>? ?? {};
        final contentDetails =
            video['contentDetails'] as Map<String, dynamic>? ?? {};

        return {
          'videoId': video['id'],
          'title': snippet['title'] ?? 'Untitled',
          'description': snippet['description'] ?? '',
          'thumbnail': snippet['thumbnails']?['high']?['url'] ??
              snippet['thumbnails']?['medium']?['url'] ??
              snippet['thumbnails']?['default']?['url'] ??
              '',
          'channelTitle': snippet['channelTitle'] ?? 'Unknown',
          'channelId': channelId,
          'publishedAt': snippet['publishedAt'] ?? '',
          'viewCount': statistics['viewCount'] ?? '0',
          'likeCount': statistics['likeCount'] ?? '0',
          'duration': contentDetails['duration'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error getting channel videos: $e');
      return [];
    }
  }

  /// Search for anime videos
  static Future<List<Map<String, dynamic>>> _searchVideos({
    required String query,
    int maxResults = 50,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'part': 'snippet',
          'q': query,
          'type': 'video',
          'maxResults': maxResults.toString(),
          'key': _apiKey,
          'order':
              'relevance', // Changed to relevance for better search results
          // Removed videoDuration filter to show ALL video lengths
          'videoEmbeddable': 'true',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 403) {
        print('YouTube API quota exceeded (403). Using sample data.');
        return [];
      } else if (response.statusCode != 200) {
        print('Search failed: ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      final items = data['items'] as List<dynamic>? ?? [];

      // Get video IDs to fetch full details
      final videoIds = items
          .where((item) => item['id']?['videoId'] != null)
          .map((item) => item['id']['videoId'])
          .join(',');

      if (videoIds.isEmpty) return [];

      final videosUri = Uri.parse('$_baseUrl/videos').replace(
        queryParameters: {
          'part': 'snippet,contentDetails,statistics',
          'id': videoIds,
          'key': _apiKey,
        },
      );

      final videosResponse = await http.get(videosUri);
      if (videosResponse.statusCode != 200) return [];

      final videosData = json.decode(videosResponse.body);
      final videos = videosData['items'] as List<dynamic>? ?? [];

      return videos.map<Map<String, dynamic>>((video) {
        final snippet = video['snippet'] as Map<String, dynamic>;
        final statistics = video['statistics'] as Map<String, dynamic>? ?? {};
        final contentDetails =
            video['contentDetails'] as Map<String, dynamic>? ?? {};

        return {
          'videoId': video['id'],
          'title': snippet['title'] ?? 'Untitled',
          'description': snippet['description'] ?? '',
          'thumbnail': snippet['thumbnails']?['high']?['url'] ??
              snippet['thumbnails']?['medium']?['url'] ??
              snippet['thumbnails']?['default']?['url'] ??
              '',
          'channelTitle': snippet['channelTitle'] ?? 'Unknown',
          'channelId': snippet['channelId'] ?? '',
          'publishedAt': snippet['publishedAt'] ?? '',
          'viewCount': statistics['viewCount'] ?? '0',
          'likeCount': statistics['likeCount'] ?? '0',
          'duration': contentDetails['duration'] ?? '',
        };
      }).toList();
    } catch (e) {
      print('Error searching videos: $e');
      return [];
    }
  }

  /// Search for specific anime series
  static Future<List<Map<String, dynamic>>> searchAnime(String query) async {
    try {
      // Use user's exact search query without adding extra words
      return await _searchVideos(query: query, maxResults: 50);
    } catch (e) {
      print('Error searching anime: $e');
      return [];
    }
  }

  /// Get anime episodes for a specific title
  static Future<List<Map<String, dynamic>>> getAnimeEpisodes(
      String animeTitle) async {
    try {
      final query = '$animeTitle anime full episode';
      final results = await _searchVideos(query: query, maxResults: 50);

      // Try to extract episode numbers from titles
      return results.map((video) {
        final title = video['title'] as String;
        final episodeMatch = RegExp(r'[Ee]pisode?\s*(\d+)|Ep\.?\s*(\d+)|#(\d+)')
            .firstMatch(title);

        int? episodeNumber;
        if (episodeMatch != null) {
          episodeNumber = int.tryParse(episodeMatch.group(1) ??
              episodeMatch.group(2) ??
              episodeMatch.group(3) ??
              '');
        }

        return {
          ...video,
          'episodeNumber': episodeNumber,
        };
      }).toList()
        ..sort((a, b) {
          final epA = a['episodeNumber'] as int? ?? 999999;
          final epB = b['episodeNumber'] as int? ?? 999999;
          return epA.compareTo(epB);
        });
    } catch (e) {
      print('Error getting episodes: $e');
      return [];
    }
  }

  /// Parse ISO 8601 duration to readable format
  static String parseDuration(String isoDuration) {
    try {
      final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?');
      final match = regex.firstMatch(isoDuration);

      if (match == null) return '0:00';

      final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
      final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
      final seconds = int.tryParse(match.group(3) ?? '0') ?? 0;

      if (hours > 0) {
        return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else {
        return '$minutes:${seconds.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return '0:00';
    }
  }

  /// Format view count
  static String formatViewCount(String viewCount) {
    try {
      final count = int.parse(viewCount);
      if (count >= 1000000) {
        return '${(count / 1000000).toStringAsFixed(1)}M';
      } else if (count >= 1000) {
        return '${(count / 1000).toStringAsFixed(1)}K';
      } else {
        return count.toString();
      }
    } catch (e) {
      return viewCount;
    }
  }

  /// Format published date
  static String formatPublishedDate(String publishedAt) {
    try {
      final date = DateTime.parse(publishedAt);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return publishedAt;
    }
  }
}
