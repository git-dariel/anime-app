import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimeGDriveService {
  static const String _baseUrl = 'https://www.googleapis.com/drive/v3';
  static const String _apiKey = 'AIzaSyB_gG5jmhGieBFK3sktEySkbimLT8UCb6k';

  // Anime folder IDs from Google Drive
  static const Map<String, String> animeFolders = {
    'Samurai Champloo': '13OwXl4kJTMMtuhtFAIAD6I6PUc6Vcagf',
  };

  // YouTube anime search queries
  static const Map<String, String> youtubeAnime = {
    'Ghost Fighter Tagalog': 'Ghost Fighter Tagalog full episode',
    'Hunter x Hunter Tagalog': 'Hunter x Hunter Tagalog dub full episode',
    'One Piece Tagalog': 'One Piece Tagalog full episode',
    'Black Clover Tagalog Complete': 'Black Clover Tagalog full episode complete'
  };

  /// Get featured anime from all Google Drive folders
  static Future<List<Map<String, dynamic>>> getFeaturedAnime() async {
    try {
      List<Map<String, dynamic>> allAnime = [];

      // Fetch from all anime folders
      for (var entry in animeFolders.entries) {
        final animeName = entry.key;
        final folderId = entry.value;

        final episodes = await getAnimeByFolder(folderId, animeName);
        allAnime.addAll(episodes);
      }

      // Sort by episode number and take first few episodes from each series
      allAnime.sort((a, b) {
        final epA = a['episodeNumber'] as int? ?? 999999;
        final epB = b['episodeNumber'] as int? ?? 999999;
        return epA.compareTo(epB);
      });

      print('Featured: Returning ${allAnime.length} episodes from Google Drive');
      return allAnime;
    } catch (e) {
      print('Error getting featured anime: $e');
      return _getSampleAnimeData();
    }
  }

  /// Get all episodes from a specific Google Drive folder (no subfolder search)
  static Future<List<Map<String, dynamic>>> getAnimeByFolder(
    String folderId,
    String animeName,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/files').replace(
        queryParameters: {
          'q': "'$folderId' in parents and trashed=false and mimeType contains 'video/'",
          'key': _apiKey,
          'fields': 'files(id,name,mimeType,size,createdTime,modifiedTime,thumbnailLink,webViewLink,webContentLink,description)',
          'pageSize': '1000',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 403) {
        print('Google Drive API quota exceeded or permission denied (403)');
        return _getSampleAnimeData();
      } else if (response.statusCode != 200) {
        print('Google Drive API returned ${response.statusCode}');
        return [];
      }

      final data = json.decode(response.body);
      final files = data['files'] as List<dynamic>? ?? [];

      if (files.isEmpty) {
        print('No video files found in folder: $folderId');
        return [];
      }

      final results = files.map<Map<String, dynamic>>((file) {
        final fileName = file['name'] as String? ?? 'Untitled';
        final episodeNumber = _parseEpisodeNumber(fileName);

        return {
          'fileId': file['id'] ?? '',
          'title': fileName,
          'thumbnail': file['thumbnailLink'] ?? _generateThumbnail(file['id'] ?? ''),
          'description': file['description'] ?? 'Watch $animeName',
          'animeName': animeName,
          'webViewLink': file['webViewLink'] ?? '',
          'webContentLink': file['webContentLink'] ?? '',
          'createdTime': file['createdTime'] ?? '',
          'modifiedTime': file['modifiedTime'] ?? '',
          'fileSize': file['size']?.toString() ?? '0',
          'mimeType': file['mimeType'] ?? '',
          'episodeNumber': episodeNumber,
        };
      }).toList();

      // Sort by episode number
      results.sort((a, b) {
        final epA = a['episodeNumber'] as int? ?? 999999;
        final epB = b['episodeNumber'] as int? ?? 999999;
        return epA.compareTo(epB);
      });

      print('Loaded ${results.length} episodes for $animeName');
      return results;
    } catch (e) {
      print('Error getting anime by folder: $e');
      return [];
    }
  }

  /// Get anime by category (maps to different anime series)
  static Future<List<Map<String, dynamic>>> getAnimeByCategory(
    String category,
  ) async {
    try {
      // First check if it's a Google Drive anime
      if (animeFolders.containsKey(category)) {
        final folderId = animeFolders[category];
        if (folderId != null) {
          return await getAnimeByFolder(folderId, category);
        }
      }
      
      // Then check if it's a YouTube anime - return empty for now
      // The category_view screen will need to be updated to handle YouTube
      if (youtubeAnime.containsKey(category)) {
        // For now, return empty - YouTube anime will be handled differently
        print('YouTube anime requested: $category');
        return [];
      }

      // Fallback: return featured anime
      return getFeaturedAnime();
    } catch (e) {
      print('Error getting anime by category: $e');
      return [];
    }
  }

  /// Search for anime episodes
  static Future<List<Map<String, dynamic>>> searchAnime(String query) async {
    try {
      List<Map<String, dynamic>> allResults = [];

      // Search in all anime folders
      for (var entry in animeFolders.entries) {
        final animeName = entry.key;
        final folderId = entry.value;

        // Check if query matches anime name
        if (animeName.toLowerCase().contains(query.toLowerCase())) {
          final episodes = await getAnimeByFolder(folderId, animeName);
          allResults.addAll(episodes);
        } else {
          // Search within folder files
          final uri = Uri.parse('$_baseUrl/files').replace(
            queryParameters: {
              'q': "'$folderId' in parents and trashed=false and mimeType contains 'video/' and name contains '$query'",
              'key': _apiKey,
              'fields': 'files(id,name,mimeType,size,createdTime,modifiedTime,thumbnailLink,webViewLink,webContentLink,description)',
              'orderBy': 'name',
              'pageSize': '100',
            },
          );

          final response = await http.get(uri);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final files = data['files'] as List<dynamic>? ?? [];

            final results = files.map<Map<String, dynamic>>((file) {
              final fileName = file['name'] as String? ?? 'Untitled';
              final episodeNumber = _parseEpisodeNumber(fileName);

              return {
                'fileId': file['id'] ?? '',
                'title': fileName,
                'thumbnail': file['thumbnailLink'] ?? _generateThumbnail(file['id'] ?? ''),
                'description': file['description'] ?? 'Watch $animeName',
                'animeName': animeName,
                'webViewLink': file['webViewLink'] ?? '',
                'webContentLink': file['webContentLink'] ?? '',
                'createdTime': file['createdTime'] ?? '',
                'modifiedTime': file['modifiedTime'] ?? '',
                'fileSize': file['size']?.toString() ?? '0',
                'mimeType': file['mimeType'] ?? '',
                'episodeNumber': episodeNumber,
              };
            }).toList();

            allResults.addAll(results);
          }
        }
      }

      // Sort by anime name and episode number
      allResults.sort((a, b) {
        final animeCompare = (a['animeName'] as String).compareTo(b['animeName'] as String);
        if (animeCompare != 0) return animeCompare;

        final epA = a['episodeNumber'] as int? ?? 999999;
        final epB = b['episodeNumber'] as int? ?? 999999;
        return epA.compareTo(epB);
      });

      print('Search "$query": Found ${allResults.length} results');
      return allResults;
    } catch (e) {
      print('Error searching anime: $e');
      return [];
    }
  }

  /// Get episodes for a specific anime title
  static Future<List<Map<String, dynamic>>> getAnimeEpisodes(
    String animeTitle,
  ) async {
    try {
      // Find matching anime folder
      for (var entry in animeFolders.entries) {
        if (entry.key.toLowerCase().contains(animeTitle.toLowerCase()) ||
            animeTitle.toLowerCase().contains(entry.key.toLowerCase())) {
          return await getAnimeByFolder(entry.value, entry.key);
        }
      }

      // If no exact match, try searching
      return await searchAnime(animeTitle);
    } catch (e) {
      print('Error getting episodes: $e');
      return [];
    }
  }

  /// Parse episode number from filename
  static int? _parseEpisodeNumber(String filename) {
    try {
      // Common patterns for episode numbers
      final patterns = [
        RegExp(r'\bE(\d+)\b', caseSensitive: false), // E1, E10, E26
        RegExp(r'[Ee][Pp](\d+)', caseSensitive: false), // EP1, EP2, ep1, ep2
        RegExp(r'[Ee]pisode?\s*(\d+)', caseSensitive: false),
        RegExp(r'[Ee]p\.?\s*(\d+)', caseSensitive: false),
        RegExp(r'#(\d+)'),
        RegExp(r'\s(\d+)\s'),
        RegExp(r'-\s*(\d+)'),
        RegExp(r'_(\d+)'),
        RegExp(r'\[(\d+)\]'),
        RegExp(r'\((\d+)\)'),
      ];

      for (var pattern in patterns) {
        final match = pattern.firstMatch(filename);
        if (match != null) {
          final episodeStr = match.group(1);
          if (episodeStr != null) {
            final episode = int.tryParse(episodeStr);
            if (episode != null && episode > 0 && episode < 10000) {
              return episode;
            }
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Generate thumbnail URL for Google Drive file
  static String _generateThumbnail(String fileId) {
    if (fileId.isEmpty) return '';
    return 'https://drive.google.com/thumbnail?id=$fileId&sz=w400';
  }

  /// Get sample anime data when API is unavailable
  static List<Map<String, dynamic>> _getSampleAnimeData() {
    return [
      {
        'fileId': 'sample1',
        'title': 'One Piece - Episode 1',
        'thumbnail': 'https://via.placeholder.com/400x225?text=One+Piece+Ep+1',
        'description': 'Watch One Piece Episode 1',
        'animeName': 'One Piece',
        'webViewLink': '',
        'webContentLink': '',
        'createdTime': DateTime.now().toIso8601String(),
        'modifiedTime': DateTime.now().toIso8601String(),
        'fileSize': '500000000',
        'mimeType': 'video/mp4',
        'episodeNumber': 1,
      },
      {
        'fileId': 'sample2',
        'title': 'Samurai Champloo - Episode 1',
        'thumbnail': 'https://via.placeholder.com/400x225?text=Samurai+Champloo+Ep+1',
        'description': 'Watch Samurai Champloo Episode 1',
        'animeName': 'Samurai Champloo',
        'webViewLink': '',
        'webContentLink': '',
        'createdTime': DateTime.now().toIso8601String(),
        'modifiedTime': DateTime.now().toIso8601String(),
        'fileSize': '400000000',
        'mimeType': 'video/mp4',
        'episodeNumber': 1,
      },
    ];
  }

  /// Format file size to human readable format
  static String formatFileSize(String bytes) {
    try {
      final size = int.parse(bytes);
      if (size >= 1073741824) {
        return '${(size / 1073741824).toStringAsFixed(2)} GB';
      } else if (size >= 1048576) {
        return '${(size / 1048576).toStringAsFixed(2)} MB';
      } else if (size >= 1024) {
        return '${(size / 1024).toStringAsFixed(2)} KB';
      } else {
        return '$size bytes';
      }
    } catch (e) {
      return bytes;
    }
  }

  /// Format duration (placeholder - Google Drive API doesn't provide duration directly)
  static String parseDuration(String duration) {
    // This would need additional processing or metadata
    // For now, return a placeholder
    return '24:00';
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

  /// Format view count (placeholder for consistency with YouTube service)
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
}
