class Anime {
  final String id;
  final String title;
  final String thumbnail;
  final String description;
  final String animeName;
  final String videoUrl;
  final String createdTime;
  final String modifiedTime;
  final String fileSize;
  final int? episodeNumber;

  Anime({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.animeName,
    required this.videoUrl,
    required this.createdTime,
    required this.modifiedTime,
    required this.fileSize,
    this.episodeNumber,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      id: json['fileId']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',
      thumbnail: json['thumbnail'] ?? '',
      description: json['description'] ?? '',
      animeName: json['animeName'] ?? 'Unknown',
      videoUrl: json['webContentLink'] ?? json['webViewLink'] ?? '',
      createdTime: json['createdTime'] ?? '',
      modifiedTime: json['modifiedTime'] ?? '',
      fileSize: json['fileSize']?.toString() ?? '0',
      episodeNumber: json['episodeNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': id,
      'title': title,
      'thumbnail': thumbnail,
      'description': description,
      'animeName': animeName,
      'webContentLink': videoUrl,
      'webViewLink': videoUrl,
      'createdTime': createdTime,
      'modifiedTime': modifiedTime,
      'fileSize': fileSize,
      'episodeNumber': episodeNumber,
    };
  }

  // Get display title with episode number
  String get displayTitle {
    if (episodeNumber != null) {
      return '$animeName - Episode $episodeNumber';
    }
    return title;
  }

  // Get Cloudinary public ID from the id field
  String get publicId => id;
}
