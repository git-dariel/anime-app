class YouTubeAnime {
  final String videoId;
  final String title;
  final String thumbnail;
  final String description;
  final String channelTitle;
  final String channelId;
  final String publishedAt;
  final String viewCount;
  final String likeCount;
  final String duration;
  final int? episodeNumber;

  YouTubeAnime({
    required this.videoId,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.channelTitle,
    required this.channelId,
    required this.publishedAt,
    required this.viewCount,
    required this.likeCount,
    required this.duration,
    this.episodeNumber,
  });

  factory YouTubeAnime.fromJson(Map<String, dynamic> json) {
    return YouTubeAnime(
      videoId: json['videoId']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',
      thumbnail: json['thumbnail'] ?? '',
      description: json['description'] ?? '',
      channelTitle: json['channelTitle'] ?? 'Unknown',
      channelId: json['channelId'] ?? '',
      publishedAt: json['publishedAt'] ?? '',
      viewCount: json['viewCount']?.toString() ?? '0',
      likeCount: json['likeCount']?.toString() ?? '0',
      duration: json['duration'] ?? '',
      episodeNumber: json['episodeNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'thumbnail': thumbnail,
      'description': description,
      'channelTitle': channelTitle,
      'channelId': channelId,
      'publishedAt': publishedAt,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'duration': duration,
      'episodeNumber': episodeNumber,
    };
  }

  // Extract anime name from title (removes episode info)
  String get animeName {
    // Try to extract the base anime name by removing episode info
    final cleanTitle = title
        .replaceAll(RegExp(r'[Ee]pisode?\s*\d+'), '')
        .replaceAll(RegExp(r'Ep\.?\s*\d+'), '')
        .replaceAll(RegExp(r'#\d+'), '')
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll(RegExp(r'\(.*?\)'), '')
        .trim();

    return cleanTitle.isNotEmpty ? cleanTitle : title;
  }
}
