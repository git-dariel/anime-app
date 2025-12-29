import 'dart:convert';
import 'package:http/http.dart' as http;

class AnimeCloudinaryService {
  static const String _cloudName = 'grid-dev';
  static const String _apiKey = '391895512995585';
  static const String _apiSecret = 'xRgAjhQwT-oN1u0-o4dGKDvJ8V0';
  static const String _baseUrl = 'https://api.cloudinary.com/v1_1/$_cloudName';

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

  /// Generate a Cloudinary URL for a given public ID
  /// Applies f_auto (auto format) and q_auto (auto quality)
  static String getVideoUrl(String publicId) {
    try {
      // Generate optimized video URL with automatic quality and format
      return 'https://res.cloudinary.com/$_cloudName/video/upload/q_auto,f_auto/$publicId';
    } catch (e) {
      print('Error generating Cloudinary URL: $e');
      return 'https://res.cloudinary.com/$_cloudName/video/upload/$publicId';
    }
  }

  static Future<List<Map<String, dynamic>>> fetchVideos(
      {String prefix = ''}) async {
    try {
      final String credentials =
          base64Encode(utf8.encode('$_apiKey:$_apiSecret'));

      // Build query parameters
      Map<String, String> queryParams = {
        'resource_type': 'video',
        'type': 'upload',
        'max_results': '100', // Fetch up to 100 videos
      };

      if (prefix.isNotEmpty) {
        queryParams['prefix'] = prefix;
      }

      final uri = Uri.parse('$_baseUrl/resources/video/upload')
          .replace(queryParameters: queryParams);

      print('Fetching Cloudinary videos: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Basic $credentials',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final resources = data['resources'] as List<dynamic>;

        return resources.map((res) {
          // Parse title and episode from public_id or display_name or filename
          // Cloudinary Public ID: "folder/filename" example "samurai-champloo/Samurai_Champloo_Episode_01"
          final publicId = res['public_id'] as String;
          final filename = publicId.split('/').last;

          return {
            'fileId': publicId, // Use Public ID as ID
            'title':
                filename.replaceAll('_', ' '), // "Samurai Champloo Episode 01"
            'thumbnail': _getThumbnailUrl(publicId),
            'description': 'Watch this episode on Cloudinary',
            // Extract anime name from filename
            'animeName': _extractAnimeName(filename),
            'webViewLink': res['secure_url'],
            'webContentLink': res['secure_url'],
            'createdTime': res['created_at'],
            'modifiedTime': res['created_at'],
            'fileSize': res['bytes'].toString(),
            'mimeType': 'video/mp4', // Formatting helper assumes videos
            'episodeNumber': _parseEpisodeNumber(filename),
            'source': 'cloudinary', // Explicitly mark as cloudinary source
          };
        }).toList();
      } else {
        print(
            'Failed to fetch videos. Status: ${response.statusCode}, Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching Cloudinary videos: $e');
      return [];
    }
  }

  static String _getThumbnailUrl(String publicId) {
    // Generate a simple thumbnail URL (using .jpg extension)
    // https://res.cloudinary.com/<cloud_name>/video/upload/<public_id>.jpg
    return 'https://res.cloudinary.com/$_cloudName/video/upload/w_400,h_225,c_fill/$publicId.jpg';
  }

  static String _extractAnimeName(String filename) {
    try {
      // Extract anime name from filename patterns like:
      // "Samurai_Champloo_E21_-_Elegy_of_Entrapment_Verse_2_ttz0zw"
      // "Samurai_Champloo_E23_-_Baseball_Blues_ht4iab"

      // Remove common episode patterns to isolate anime name
      String cleanName = filename;

      // Remove episode patterns: E21, E23, Episode_01, Ep_01, etc.
      cleanName = cleanName.replaceAll(
          RegExp(r'[_\s]*[Ee](\d+)[_\s]*', caseSensitive: false), '_EPISODE_');
      cleanName = cleanName.replaceAll(
          RegExp(r'[_\s]*[Ee]pisode[_\s]*(\d+)[_\s]*', caseSensitive: false),
          '_EPISODE_');
      cleanName = cleanName.replaceAll(
          RegExp(r'[_\s]*[Ee]p[_\s]*(\d+)[_\s]*', caseSensitive: false),
          '_EPISODE_');

      // Split by _EPISODE_ and take the first part (anime name)
      final parts = cleanName.split('_EPISODE_');
      if (parts.isNotEmpty && parts[0].isNotEmpty) {
        String animeName = parts[0];

        // Clean up the anime name
        animeName = animeName.replaceAll('_', ' ');
        animeName = animeName.trim();

        // Convert to title case
        return _toTitleCase(animeName);
      }

      // Fallback: try to extract from common patterns
      // Look for pattern before first episode indicator
      final episodePattern = RegExp(
          r'^(.+?)(?:[_\s]*[Ee](?:pisode)?[_\s]*\d+|[_\s]*\d+[_\s]*)',
          caseSensitive: false);
      final match = episodePattern.firstMatch(filename);
      if (match != null) {
        String animeName = match.group(1) ?? '';
        animeName = animeName.replaceAll('_', ' ').trim();
        return _toTitleCase(animeName);
      }

      // Last fallback: take first few words
      final words = filename.replaceAll('_', ' ').split(' ');
      if (words.length >= 2) {
        return _toTitleCase('${words[0]} ${words[1]}');
      }

      return _toTitleCase(words.isNotEmpty ? words[0] : 'Unknown Anime');
    } catch (e) {
      return 'Unknown Anime';
    }
  }

  static String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  static int? _parseEpisodeNumber(String filename) {
    try {
      // More specific patterns for episode numbers
      final patterns = [
        RegExp(r'[Ee](\d+)(?:_|\.|\s|$)',
            caseSensitive: false), // E21, E23, etc.
        RegExp(r'[Ee]pisode[_\s]*(\d+)',
            caseSensitive: false), // Episode_21, Episode 21
        RegExp(r'[Ee]p[_\s]*(\d+)', caseSensitive: false), // Ep_21, Ep 21
        RegExp(r'_(\d+)_', caseSensitive: false), // _21_
        RegExp(r'(\d+)(?:_[a-zA-Z]|\.)',
            caseSensitive: false), // 21_something or 21.ext
      ];

      for (var pattern in patterns) {
        final match = pattern.firstMatch(filename);
        if (match != null) {
          final episodeStr = match.group(1);
          if (episodeStr != null) {
            final episode = int.tryParse(episodeStr);
            if (episode != null && episode > 0 && episode < 1000) {
              return episode;
            }
          }
        }
      }

      // Fallback: look for any number in the filename
      final RegExp fallbackRegex = RegExp(r'(\d+)');
      final matches = fallbackRegex.allMatches(filename);
      if (matches.isNotEmpty) {
        // Try to find the most likely episode number (usually between 1-999)
        for (var match in matches) {
          final num = int.tryParse(match.group(0)!);
          if (num != null && num > 0 && num < 1000) {
            return num;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
