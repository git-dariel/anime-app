class GDriveAnime {
  final String fileId;
  final String title;
  final String thumbnail;
  final String description;
  final String animeName;
  final String webViewLink;
  final String webContentLink;
  final String createdTime;
  final String modifiedTime;
  final String fileSize;
  final String mimeType;
  final int? episodeNumber;
  final String source; // 'gdrive' or 'youtube'

  GDriveAnime({
    required this.fileId,
    required this.title,
    required this.thumbnail,
    required this.description,
    required this.animeName,
    required this.webViewLink,
    required this.webContentLink,
    required this.createdTime,
    required this.modifiedTime,
    required this.fileSize,
    required this.mimeType,
    this.episodeNumber,
    this.source = 'gdrive', // default to gdrive
  });

  factory GDriveAnime.fromJson(Map<String, dynamic> json) {
    return GDriveAnime(
      fileId: json['fileId']?.toString() ?? '',
      title: json['title'] ?? 'Untitled',
      thumbnail: json['thumbnail'] ?? '',
      description: json['description'] ?? '',
      animeName: json['animeName'] ?? 'Unknown',
      webViewLink: json['webViewLink'] ?? '',
      webContentLink: json['webContentLink'] ?? '',
      createdTime: json['createdTime'] ?? '',
      modifiedTime: json['modifiedTime'] ?? '',
      fileSize: json['fileSize']?.toString() ?? '0',
      mimeType: json['mimeType'] ?? '',
      episodeNumber: json['episodeNumber'],
      source: json['source'] ?? 'gdrive',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'title': title,
      'thumbnail': thumbnail,
      'description': description,
      'animeName': animeName,
      'webViewLink': webViewLink,
      'webContentLink': webContentLink,
      'createdTime': createdTime,
      'modifiedTime': modifiedTime,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'episodeNumber': episodeNumber,
      'source': source,
    };
  }

  // Get display title with episode number
  String get displayTitle {
    if (episodeNumber != null) {
      return '$animeName - Episode $episodeNumber';
    }
    return title;
  }

  // Get direct streaming URL
  String get streamUrl {
    // Google Drive direct download/stream URL
    return 'https://drive.google.com/uc?export=download&id=$fileId';
  }

  // Get embed URL for iframe player
  String get embedUrl {
    return 'https://drive.google.com/file/d/$fileId/preview';
  }
}
