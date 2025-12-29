# 🎌 KAGE TV

A beautiful Flutter application for streaming anime content directly from Cloudinary, featuring in-app video playback with a modern UI and seamless experience.

![Flutter](https://img.shields.io/badge/Flutter-3.3.4+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-green.svg)

## ✨ Features

- 🎬 **Cloudinary Integration** - Stream anime videos directly from Cloudinary CDN
- 📺 **In-App Video Player** - Watch videos directly within the app with custom controls
- 🔍 **Smart Search** - Search through your entire anime collection
- 🎨 **Beautiful UI** - Modern dark theme with orange accents
- 🚀 **Animated Splash Screen** - Eye-catching logo animation on app launch
- 📱 **Cross-platform** - Works on Android and iOS
- 🎯 **Curated Content** - Organized anime collections with episodes
- 📊 **Episode Management** - Browse all episodes with sorting and metadata
- ⚡ **Fast Loading** - Optimized video delivery through Cloudinary CDN
- 🎮 **Intuitive Controls** - Play/pause, seek, and progress tracking

## 📚 Why Cloudinary?

Cloudinary provides the best video streaming experience:

- ✓ **No Playback Restrictions** - Play videos directly in the app
- ✓ **Automatic Quality Optimization** - Adaptive bitrate streaming
- ✓ **Fast CDN Delivery** - Lightning-fast video loading
- ✓ **Format Auto-Detection** - Serves the best format for each device
- ✓ **Video Transformations** - On-the-fly video processing
- ✓ **Reliable Infrastructure** - 99.9% uptime guarantee
- ✓ **Thumbnail Generation** - Automatic thumbnail creation

## 📱 Screenshots

_Coming soon_

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (>=3.3.4)
- Dart SDK
- Cloudinary Account (free tier available)

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/git-dariel/anime-app.git
cd anime_app
```

2. **Install dependencies:**

```bash
flutter pub get
```

3. **Set up Cloudinary:**

   - Create a free account at [Cloudinary](https://cloudinary.com/)
   - Upload your anime videos to Cloudinary
   - Organize videos in folders (e.g., `samurai-champloo/`, `one-piece/`)
   - Update credentials in `lib/services/anime_cloudinary.service.dart`:
     - `_cloudName`: Your cloud name
     - `_apiKey`: Your API key
     - `_apiSecret`: Your API secret
   - Update credentials in `lib/main.dart` (Cloudinary initialization)

4. **Run the app:**

```bash
flutter run
```

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                          # App entry point with Cloudinary setup
├── models/                            # Data models
│   └── anime.dart                     # Unified anime model
├── screens/                           # UI screens
│   ├── splash.screen.dart            # Animated splash screen
│   ├── home.screen.dart              # Main screen with categories
│   ├── anime_detail.screen.dart      # Anime details & episodes
│   ├── category_view.screen.dart     # Category/series episode list
│   ├── search.screen.dart            # Search functionality
│   └── video.player.screen.dart      # Video player screen
├── services/                          # API services
│   └── anime_cloudinary.service.dart # Cloudinary API integration
├── widgets/                           # Custom widgets
│   └── cloudinary_video_player.dart  # Video player widget
├── theme/                             # App theming
│   └── app_theme.dart                # Dark theme configuration
└── assets/
    └── images/
        └── logo.png                   # App logo
```

### Data Flow

1. **Home Screen** → Loads all videos from Cloudinary, groups by anime name
2. **Category View** → Shows all episodes from selected anime series
3. **Search** → Client-side search through all videos
4. **Video Playback** → Streams directly from Cloudinary CDN in the app

## 🎯 Key Components

### Cloudinary Service

- Fetches videos using Cloudinary Admin API
- Generates optimized video URLs with transformations
- Provides automatic thumbnail generation
- Parses episode numbers from filenames
- Utility functions for formatting file sizes and dates

### Video Player

- Built on `video_player` package
- Custom controls (play/pause, seek, progress)
- Error handling and loading states
- Fullscreen support
- Responsive aspect ratio

### Home Screen

- Dynamic categories from Cloudinary folders
- Featured anime section
- Quick access to search
- Categorized anime collections
- Pull-to-refresh functionality

### Anime Detail Screen

- Comprehensive anime information
- Episode list with thumbnails
- Tabbed interface (Episodes & Details)
- Play button for immediate viewing
- Related episodes from same series

### Search Screen

- Search across all anime titles and episode names
- Recommended anime when idle
- Grid view of search results
- Direct playback from search results

## 🔧 Configuration

### Organizing Videos in Cloudinary

Upload your videos with this folder structure:

```
cloudinary-root/
├── samurai-champloo/
│   ├── Samurai_Champloo_Episode_01.mp4
│   ├── Samurai_Champloo_Episode_02.mp4
│   └── ...
├── one-piece/
│   ├── One_Piece_Episode_01.mp4
│   ├── One_Piece_Episode_02.mp4
│   └── ...
└── hunter-x-hunter/
    ├── Hunter_x_Hunter_Episode_01.mp4
    └── ...
```

**Naming Convention:**
- Use underscores or hyphens in filenames
- Include "Episode" or "Ep" followed by the number
- Example: `Anime_Name_Episode_01.mp4`

### Episode Number Parsing

The app automatically extracts episode numbers from filenames using these patterns:
- `Episode_01`, `Episode_1`
- `Ep_01`, `Ep_1`
- `E01`, `E1`
- Numbers at the end of filename

### Cloudinary API Setup

1. **Get API Credentials:**
   - Visit [Cloudinary Console](https://console.cloudinary.com/)
   - Navigate to Dashboard
   - Copy Cloud Name, API Key, and API Secret

2. **Update Configuration:**

In `lib/services/anime_cloudinary.service.dart`:
```dart
static const String _cloudName = 'your-cloud-name';
static const String _apiKey = 'your-api-key';
static const String _apiSecret = 'your-api-secret';
```

In `lib/main.dart`:
```dart
CloudinaryContext.cloudinary = Cloudinary.fromCloudName(
  cloudName: 'your-cloud-name',
  apiKey: 'your-api-key',
);
```

## 🎨 Theme & Design

- **Primary Color:** Orange (#FF6B35)
- **Background:** Dark (#0A0E27)
- **Card Background:** Dark Blue (#1A1F3A)
- **Design System:** Material Design 3
- **Typography:** System default with custom sizing
- **Icons:** Material Icons

## 📊 Features in Detail

### Cloudinary Video Delivery

- **Adaptive Streaming** - Automatically adjusts quality based on network
- **Format Optimization** - Serves optimal format (MP4, WebM, etc.)
- **Lazy Loading** - Videos load only when needed
- **Thumbnail Caching** - Fast thumbnail loading
- **CDN Distribution** - Global content delivery network

### Smart Episode Parsing

- Extracts episode numbers from filenames
- Supports multiple naming conventions
- Automatic sorting by episode number
- Handles special cases and edge cases

### In-App Playback

- Native video player with custom controls
- Play/pause functionality
- Seek bar for navigation
- Video progress indicator
- Automatic orientation handling
- Background audio support

## 🛡️ Legal & Ethics

### ✅ What we do (Legal):

- Use official Cloudinary API
- Stream from authorized Cloudinary account
- Respect Cloudinary terms of service
- No content piracy or unauthorized distribution

### 📝 Disclaimers:

- Users are responsible for content they upload to Cloudinary
- Ensure you have rights to stream the content
- App is a demonstration of Cloudinary video streaming
- All content belongs to respective copyright holders

## 🐛 Known Issues

- Large video libraries may take time to load initially
- Video quality depends on original upload quality
- Cloudinary free tier has bandwidth limits
- Very large files may require upgraded Cloudinary plan

## 🔮 Future Enhancements

- [ ] Download for offline viewing
- [ ] User favorites and watchlists
- [ ] Continue watching feature
- [ ] Watch history tracking
- [ ] Multiple language support
- [ ] Advanced search filters
- [ ] Chromecast integration
- [ ] Custom playlists
- [ ] Quality selector in player
- [ ] Subtitle support
- [ ] Multiple video sources
- [ ] User authentication

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Cloudinary](https://cloudinary.com/) - Video hosting and delivery
- [Flutter](https://flutter.dev/) - UI framework
- [Video Player](https://pub.dev/packages/video_player) - Video playback
- All anime studios and content creators

## 📞 Support

- Create an [Issue](../../issues) for bugs
- Check [Discussions](../../discussions) for questions
- Read Cloudinary documentation for API help

## 🔑 Environment Variables (Optional)

For better security, consider using environment variables:

```dart
// Create .env file (add to .gitignore)
CLOUDINARY_CLOUD_NAME=your-cloud-name
CLOUDINARY_API_KEY=your-api-key
CLOUDINARY_API_SECRET=your-api-secret
```

Use a package like `flutter_dotenv` to load these values.

---

Made with ❤️ by Dariel using Flutter & Cloudinary

**Migrated from Google Drive to Cloudinary for better streaming experience! 🎉**
