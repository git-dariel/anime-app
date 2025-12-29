import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiTestUtil {
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Test if YouTube API key is working
  static Future<Map<String, dynamic>> testYouTubeApiKey(String apiKey) async {
    try {
      // Simple test: search for "test" with minimal quota usage
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'part': 'snippet',
          'q': 'test',
          'type': 'video',
          'maxResults': '1',
          'key': apiKey,
        },
      );

      print('Testing YouTube API with: $uri');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'message': 'API key is working correctly!',
          'quota_used': 100, // Search costs 100 units
          'items_found': (data['items'] as List?)?.length ?? 0,
        };
      } else if (response.statusCode == 403) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error']['message'] ?? 'Access denied';

        return {
          'success': false,
          'error_code': 403,
          'message': 'API key access denied: $errorMessage',
          'suggestions': [
            'Check if YouTube Data API v3 is enabled',
            'Verify API key restrictions',
            'Check daily quota usage',
            'Ensure API key is not restricted to specific IPs/apps',
          ],
        };
      } else if (response.statusCode == 400) {
        return {
          'success': false,
          'error_code': 400,
          'message': 'Invalid API key format',
          'suggestions': [
            'Check if API key is copied correctly',
            'Remove any extra spaces or characters',
            'Generate a new API key if needed',
          ],
        };
      } else {
        return {
          'success': false,
          'error_code': response.statusCode,
          'message': 'Unexpected error: ${response.statusCode}',
          'response_body': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error_code': 'NETWORK_ERROR',
        'message': 'Network error: $e',
        'suggestions': [
          'Check internet connection',
          'Verify firewall settings',
          'Try again in a few moments',
        ],
      };
    }
  }

  /// Test quota usage estimation
  static Map<String, dynamic> estimateQuotaUsage({
    int searchesPerDay = 50,
    int videoDetailsPerDay = 20,
  }) {
    final searchCost = searchesPerDay * 100; // 100 units per search
    final detailsCost = videoDetailsPerDay * 1; // 1 unit per video details
    final totalCost = searchCost + detailsCost;
    final dailyLimit = 10000; // Free tier daily limit

    return {
      'searches_per_day': searchesPerDay,
      'video_details_per_day': videoDetailsPerDay,
      'search_cost': searchCost,
      'details_cost': detailsCost,
      'total_daily_cost': totalCost,
      'daily_limit': dailyLimit,
      'remaining_quota': dailyLimit - totalCost,
      'quota_usage_percentage':
          (totalCost / dailyLimit * 100).toStringAsFixed(1),
      'within_limits': totalCost <= dailyLimit,
      'max_searches_possible': (dailyLimit / 100).floor(),
    };
  }

  /// Generate helpful API setup instructions
  static List<Map<String, String>> getSetupInstructions() {
    return [
      {
        'step': '1',
        'title': 'Go to Google Cloud Console',
        'description':
            'Visit console.cloud.google.com and sign in with your Google account',
        'url': 'https://console.cloud.google.com/'
      },
      {
        'step': '2',
        'title': 'Create or Select Project',
        'description':
            'Create a new project or select an existing one for your anime app',
        'action': 'Click "New Project" and give it a name like "Anime App"'
      },
      {
        'step': '3',
        'title': 'Enable YouTube Data API v3',
        'description': 'Go to API Library and enable the YouTube Data API v3',
        'url':
            'https://console.cloud.google.com/apis/library/youtube.googleapis.com'
      },
      {
        'step': '4',
        'title': 'Create API Key',
        'description': 'Go to Credentials and create a new API key',
        'url': 'https://console.cloud.google.com/apis/credentials'
      },
      {
        'step': '5',
        'title': 'Configure Restrictions (Optional)',
        'description':
            'Restrict the API key to YouTube Data API v3 for security',
        'action': 'Click "Restrict Key" and select "YouTube Data API v3"'
      },
      {
        'step': '6',
        'title': 'Add Key to App',
        'description':
            'Copy the API key and paste it in lib/services/anime_youtube.service.dart',
        'file': 'anime_youtube.service.dart',
        'line': 'static const String _apiKey = "YOUR_KEY_HERE";'
      },
      {
        'step': '7',
        'title': 'Restart App',
        'description': 'Restart your Flutter app to use the new API key',
        'action': 'Run: flutter hot restart'
      },
    ];
  }

  /// Get troubleshooting tips for common issues
  static Map<String, List<String>> getTroubleshootingTips() {
    return {
      'API_KEY_INVALID': [
        'Double-check the API key is copied correctly',
        'Ensure no extra spaces or characters',
        'Try generating a new API key',
        'Check if the key is enabled for YouTube Data API v3',
      ],
      'QUOTA_EXCEEDED': [
        'Wait until quota resets (midnight Pacific Time)',
        'Reduce the number of API calls in your app',
        'Consider implementing caching to store results',
        'Monitor usage in Google Cloud Console',
      ],
      'API_ACCESS_DENIED': [
        'Enable YouTube Data API v3 in Google Cloud Console',
        'Check API key restrictions',
        'Verify project billing is set up (if needed)',
        'Ensure API key has proper permissions',
      ],
      'NO_VIDEOS_FOUND': [
        'Try different anime titles',
        'Some anime may not have YouTube content',
        'Check if the anime name is spelled correctly',
        'Try searching with English and Japanese titles',
      ],
      'NETWORK_ERRORS': [
        'Check internet connection',
        'Verify firewall/antivirus settings',
        'Try using a different network',
        'Check if YouTube is accessible in your region',
      ],
    };
  }

  /// Format API test results for display
  static String formatTestResult(Map<String, dynamic> result) {
    if (result['success'] == true) {
      return '''
✅ SUCCESS: ${result['message']}
• Quota used: ${result['quota_used']} units
• Videos found: ${result['items_found']}
• Daily limit: 10,000 units
• Status: API key is working correctly!
''';
    } else {
      String message = '''
❌ ERROR: ${result['message']}
• Error code: ${result['error_code']}
''';

      if (result['suggestions'] != null) {
        message += '\n💡 Suggestions:\n';
        for (String suggestion in result['suggestions']) {
          message += '  • $suggestion\n';
        }
      }

      return message;
    }
  }
}
