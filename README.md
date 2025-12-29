# 🎌 KAGE TV

A beautiful Flutter application for watching anime content from both Google Drive and YouTube, featuring a modern UI and seamless video playback.

![Flutter](https://img.shields.io/badge/Flutter-3.3.4+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-green.svg)

## ✨ Features

- 🎬 **Dual Source Integration** - Watch anime from both Google Drive and YouTube
- 🔍 **Smart Search** - Search trending and popular anime on YouTube
- 📺 **External App Playback** - Opens videos in Google Drive or YouTube app for the best experience
- 🎨 **Beautiful UI** - Modern dark theme with orange accents
- 🚀 **Animated Splash Screen** - Eye-catching logo animation on app launch
- 📱 **Cross-platform** - Works on Android and iOS
- 🎯 **Curated Content** - Handpicked anime collections including Ghost Fighter, Hunter x Hunter, and more
- 📊 **Episode Management** - Browse all episodes with sorting and metadata

## 📚 Available Anime

### YouTube Collection (Tagalog Dub)

- 👻 **Ghost Fighter** - Classic Filipino dubbed anime
- 🎯 **Hunter x Hunter** - Action-packed adventure series
- ⚓ **One Piece** - Epic pirate adventure
- ⚔️ **Black Clover** - Magic and adventure series

### Google Drive Collection

- 🥋 **Samurai Champloo** - Stylish samurai anime

## 📱 Screenshots

_Coming soon_

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (>=3.3.4)
- Dart SDK
- Google Drive API key (for Google Drive content)
- YouTube Data API v3 key (for YouTube content)

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

3. **Set up API keys:**

   - **Google Drive API:** Replace `_apiKey` in `lib/services/anime_gdrive.service.dart`
   - **YouTube API:** Replace `_apiKey` in `lib/services/anime_youtube.service.dart`

4. **Run the app:**

```bash
flutter run
```

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                          # App entry point with splash screen
├── models/                            # Data models
│   ├── gdrive_anime.dart             # Unified anime model for both sources
│   └── youtube_anime.dart            # YouTube-specific model (legacy)
├── screens/                           # UI screens
│   ├── splash.screen.dart            # Animated splash screen
│   ├── home.screen.dart              # Main screen with categories
│   ├── anime_detail.screen.dart      # Anime details & episodes
│   ├── category_view.screen.dart     # Category/series episode list
│   ├── search.screen.dart            # Search with recommendations
│   └── video.player.screen.dart      # External app launcher
├── services/                          # API services
│   ├── anime_gdrive.service.dart     # Google Drive API integration
│   └── anime_youtube.service.dart    # YouTube API integration
├── theme/                             # App theming
│   └── app_theme.dart                # Dark theme configuration
└── assets/
    └── images/
        └── logo.png                   # App logo
```

### Data Flow

1. **Home Screen** → Loads from Google Drive + YouTube
2. **Category View** → Shows all episodes from selected source
3. **Search** → YouTube search with recommendations
4. **Video Playback** → Opens in external app (YouTube/Google Drive)

## 🎯 Key Components

### Splash Screen

- Animated logo with fade-in and scale effects
- App branding with "Dar Anime" title
- Auto-navigation to home screen after 2.5 seconds

### Home Screen

- Dynamic categories from both Google Drive and YouTube
- Featured anime section
- Quick access to search
- Categorized anime collections

### Anime Detail Screen

- Comprehensive anime information
- Episode list with sorting
- Play button for immediate viewing
- Related episodes from same series

### Search Screen

- YouTube-powered search
- Recommended trending anime when idle
- Grid view of search results
- Direct playback from search results

### Video Player Screen

- Opens videos in external apps (YouTube/Google Drive)
- Fallback to web browser if apps not installed
- Toast notifications for user feedback
- Supports both video sources seamlessly

## 🔧 Configuration

### Adding New Anime

#### Google Drive Anime

Add to `lib/services/anime_gdrive.service.dart`:

```dart
static const Map<String, String> animeFolders = {
  'Anime Name': 'Google Drive Folder ID',
};
```

#### YouTube Anime

Add to `lib/services/anime_gdrive.service.dart`:

```dart
static const Map<String, String> youtubeAnime = {
  'Anime Name': 'Search query for YouTube',
};
```

### API Keys Setup

1. **Google Drive API:**

   - Visit [Google Cloud Console](https://console.cloud.google.com/)
   - Create a project and enable Drive API v3
   - Create an API key
   - Update in `anime_gdrive.service.dart`

2. **YouTube Data API v3:**
   - Same Google Cloud project
   - Enable YouTube Data API v3
   - Use the same or different API key
   - Update in `anime_youtube.service.dart`

## 🎨 Theme & Design

- **Primary Color:** Orange (#FF6B35)
- **Background:** Dark (#0A0E27)
- **Card Background:** Dark Blue (#1A1F3A)
- **Design System:** Material Design 3
- **Typography:** System default with custom sizing
- **Icons:** Material Icons

## 📊 Features in Detail

### Multi-Source Integration

- Seamlessly combines Google Drive and YouTube content
- Single unified interface for both sources
- Automatic source detection for playback
- Consistent UI across all sources

### Smart Episode Parsing

- Extracts episode numbers from filenames
- Supports multiple naming conventions (E1, EP1, Episode 1)
- Automatic sorting by episode number
- Handles special cases and edge cases

### External Playback

- Opens videos in native apps for better performance
- Supports deep linking to YouTube and Google Drive apps
- Fallback to web browser if apps unavailable
- Better battery life and streaming quality

## 🛡️ Legal & Ethics

### ✅ What we do (Legal):

- Use official APIs (Google Drive, YouTube)
- Link to publicly available content
- Respect terms of service
- No content hosting or downloading

### 📝 Disclaimers:

- Content is sourced from Google Drive and YouTube
- Users are responsible for their viewing choices
- App doesn't host any copyrighted content
- All content belongs to respective copyright holders

## 🐛 Known Issues

- Google Drive large folder structures may load slowly
- API quota limits may affect heavy usage
- Video availability depends on geographical restrictions
- YouTube search results depend on video availability

## 🔮 Future Enhancements

- [ ] Download for offline viewing
- [ ] User favorites and watchlists
- [ ] Push notifications for new episodes
- [ ] Continue watching feature
- [ ] Multiple language support
- [ ] Advanced search filters
- [ ] Chromecast integration
- [ ] Custom playlists

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Google Drive API](https://developers.google.com/drive) - Cloud storage integration
- [YouTube Data API](https://developers.google.com/youtube/v3) - Video content
- [Flutter](https://flutter.dev/) - UI framework
- All anime studios and content creators

## 📞 Support

- Create an [Issue](../../issues) for bugs
- Check [Discussions](../../discussions) for questions
- Read API setup guides for configuration help

---

Made with ❤️ by Dariel using Flutter
