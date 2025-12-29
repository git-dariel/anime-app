# 🎌 Anime App

A beautiful Flutter application for discovering and watching anime content through YouTube integration.

## ✨ Features

- 🔍 **Smart Anime Search** - Search anime using MyAnimeList database
- 📺 **YouTube Integration** - Watch official anime content from YouTube
- 🎬 **Episode Lists** - Browse through anime episodes with detailed information
- 🌟 **Beautiful UI** - Modern Material Design with anime-focused aesthetics
- 📱 **Cross-platform** - Works on Android, iOS, and Desktop
- 🎯 **Official Content** - Prioritizes official channels like Muse Asia, Crunchyroll
- 📊 **Rich Metadata** - Ratings, genres, release dates, and more

## 📱 Screenshots

*Add screenshots of your app here*

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (>=3.3.4)
- Dart SDK
- YouTube Data API v3 key

### Installation

1. **Clone the repository:**
```bash
git clone <repository-url>
cd anime_app
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Set up YouTube API:**
   - Follow the guide in [YOUTUBE_API_SETUP.md](YOUTUBE_API_SETUP.md)
   - Get your free API key from Google Cloud Console
   - Replace `YOUR_YOUTUBE_API_KEY` in `lib/services/youtube.service.dart`

4. **Run the app:**
```bash
flutter run
```

## 🏗️ Architecture

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── anime.dart           # Anime model
│   └── episode.dart         # Episode model
├── screens/                  # UI screens
│   ├── anime.list.screen.dart    # Main search & list
│   ├── anime.detail.screen.dart  # Anime details & episodes
│   └── video.player.screen.dart  # YouTube video player
└── services/                 # API services
    ├── consumet.service.dart # MyAnimeList API integration
    └── youtube.service.dart  # YouTube API integration
```

### Data Flow
1. **Search** → MyAnimeList API → Anime results
2. **Select Anime** → Fetch episodes from MyAnimeList
3. **Play Episode** → Search YouTube → Show video options
4. **Watch** → YouTube Player → Stream content

## 🔧 Configuration

### YouTube API Setup

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable YouTube Data API v3
3. Create an API key
4. Update the key in `lib/services/youtube.service.dart`:

```dart
static const String _apiKey = 'your-api-key-here';
```

See [YOUTUBE_API_SETUP.md](YOUTUBE_API_SETUP.md) for detailed instructions.

## 📚 API Integration

### MyAnimeList (via Jikan API)
- **Search**: Anime database search
- **Details**: Episode information, ratings, genres
- **Free**: No API key required
- **Rate Limit**: Generous free tier

### YouTube Data API v3
- **Search**: Find anime videos and episodes
- **Official Channels**: Muse Asia, Crunchyroll, Ani-One Asia
- **Free Tier**: 10,000 units/day
- **Cost**: 100 units per search

## 🎯 Key Components

### AnimeListScreen
- Search anime by title
- Infinite scroll pagination
- Beautiful grid/list view
- Real-time search

### AnimeDetailScreen
- Comprehensive anime information
- Episode list with metadata
- Tabbed interface (Episodes/Details)
- Genre tags and ratings

### VideoPlayerScreen
- YouTube video integration
- Multiple video sources
- Auto-play next episode
- Video quality indicators

## 🔍 Search Strategy

The app uses intelligent search to find the best anime content:

1. **Specific Episode Search**: `{anime} episode {number}`
2. **General Content**: `{anime} anime episode full`
3. **Official Channels**: Prioritized search in verified channels
4. **Deduplication**: Removes duplicate videos
5. **Quality Sorting**: Orders by relevance and video quality

## 🎨 UI/UX Features

- **Material Design 3** - Modern design system
- **Responsive Layout** - Adapts to different screen sizes
- **Smooth Animations** - Engaging transitions
- **Error Handling** - Graceful failure states
- **Loading States** - Clear loading indicators
- **Dark/Light Theme** - System theme support

## 📊 Performance

- **Efficient Caching** - Reduces API calls
- **Lazy Loading** - Images and data loaded on demand
- **Memory Management** - Proper disposal of controllers
- **Network Optimization** - Compressed images and data

## 🛡️ Legal & Ethics

### ✅ What we do (Legal):
- Use official APIs (MyAnimeList, YouTube)
- Embed only publicly available content
- Respect terms of service
- Prioritize official/licensed content

### 📝 Disclaimers:
- Content is sourced from YouTube's public database
- Users are responsible for their viewing choices
- App doesn't host any copyrighted content
- All content belongs to respective copyright holders

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to branch: `git push origin feature/new-feature`
5. Submit a Pull Request

## 🐛 Known Issues

- Some anime might not have YouTube content
- API quota limits may affect heavy usage
- Video availability depends on geographical restrictions

## 🔮 Future Enhancements

- [ ] Offline mode with cached data
- [ ] User favorites and watchlists
- [ ] Push notifications for new episodes
- [ ] Social features (reviews, ratings)
- [ ] Advanced search filters
- [ ] Multiple language support
- [ ] Chromecast integration
- [ ] Download for offline viewing

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [MyAnimeList](https://myanimelist.net/) - Anime database
- [Jikan API](https://jikan.moe/) - Unofficial MAL API
- [YouTube Data API](https://developers.google.com/youtube/v3) - Video content
- [Flutter](https://flutter.dev/) - UI framework
- Official anime channels for providing legal content

## 📞 Support

- Create an [Issue](../../issues) for bugs
- Check [Discussions](../../discussions) for questions
- Read [YouTube API Setup](YOUTUBE_API_SETUP.md) for configuration help

---

Made with ❤️ and Flutter