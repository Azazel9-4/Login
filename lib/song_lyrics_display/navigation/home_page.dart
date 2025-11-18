import 'package:flutter/material.dart';
import '../services/player_manager.dart';
import '../services/mini_player.dart'; // Import the new mini player

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final background = 'assets/logo/bg/bg_icon.jpg';

  final List<Map<String, String>> songs = const [
    {
      'title': 'About You',
      'artist': 'The 1975',
      'musicUrl': 'assets/logo/songs/about_you.mp3',
      'lyricsUrl': 'assets/logo/lyrics/about_you.txt',
      'coverUrl': 'assets/logo/covers/about_you.jpg',
      'albumUrl': 'assets/logo/album_cover/about_you_album.jpg',
    },
    {
      'title': 'The Only Exception',
      'artist': 'Paramore',
      'musicUrl': 'assets/logo/songs/the_only_exception.mp3',
      'lyricsUrl': 'assets/logo/lyrics/the_only_exception.txt',
      'coverUrl': 'assets/logo/covers/the_only_exception.jpg',
      'albumUrl': 'assets/logo/album_cover/the_only_exception_album.jpg',
    },
    {
      'title': 'Robbers',
      'artist': 'The 1975',
      'musicUrl': 'assets/logo/songs/robbers.mp3',
      'lyricsUrl': 'assets/logo/lyrics/robbers.txt',
      'coverUrl': 'assets/logo/covers/robbers.jpg',
      'albumUrl': 'assets/logo/album_cover/robbers_album.jpg',
    },
    {
      'title': 'August',
      'artist': 'Taylor Swift',
      'musicUrl': 'assets/logo/songs/august.mp3',
      'lyricsUrl': 'assets/logo/lyrics/august.txt',
      'coverUrl': 'assets/logo/covers/august.jpg',
      'albumUrl': 'assets/logo/album_cover/august_album.jpg',
    },
    {
      'title': 'Cardigan',
      'artist': 'Taylor Swift',
      'musicUrl': 'assets/logo/songs/cardigan.mp3',
      'lyricsUrl': 'assets/logo/lyrics/cardigan.txt',
      'coverUrl': 'assets/logo/covers/cardigan.jpg',
      'albumUrl': 'assets/logo/album_cover/cardigan_album.jpg',
    },
    {
      'title': 'Luther',
      'artist': 'Kendrick Lamar ft. Sza',
      'musicUrl': 'assets/logo/songs/luther.mp3',
      'lyricsUrl': 'assets/logo/lyrics/luther.txt',
      'coverUrl': 'assets/logo/covers/luther.jpg',
      'albumUrl': 'assets/logo/album_cover/luther_album.jpg',
    },
    {
      'title': 'Falling',
      'artist': 'Harry Styles',
      'musicUrl': 'assets/logo/songs/falling.mp3',
      'lyricsUrl': 'assets/logo/lyrics/falling.txt',
      'coverUrl': 'assets/logo/covers/falling.jpg',
      'albumUrl': 'assets/logo/album_cover/falling_album.jpg',
    },
    {
      'title': 'Birds of a Feather',
      'artist': 'Billie Eilish',
      'musicUrl': 'assets/logo/songs/birds_of_a_feather.mp3',
      'lyricsUrl': 'assets/logo/lyrics/birds_of_a_feather.txt',
      'coverUrl': 'assets/logo/covers/birds_of_a_feather.jpg',
      'albumUrl': 'assets/logo/album_cover/birds_of_a_feather_album.jpg',
    },
    {
      'title': 'So High School',
      'artist': 'Taylor Swift',
      'musicUrl': 'assets/logo/songs/so_high_school.mp3',
      'lyricsUrl': 'assets/logo/lyrics/so_high_school.txt',
      'coverUrl': 'assets/logo/covers/so_high_school.jpg',
      'albumUrl': 'assets/logo/album_cover/so_high_school_album.jpg',
    },
    {
      'title': 'As It Was',
      'artist': 'Harry Styles',
      'musicUrl': 'assets/logo/songs/as_it_was.mp3',
      'lyricsUrl': 'assets/logo/lyrics/as_it_was.txt',
      'coverUrl': 'assets/logo/covers/as_it_was.jpg',
      'albumUrl': 'assets/logo/album_cover/as_it_was_album.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    PlayerManager.init();
  }

  void _openLyrics(int index) {
    Navigator.pushNamed(
      context,
      '/lyrics',
      arguments: {'songs': songs, 'index': index},
    );
  }

  Widget _buildSongTile(int index) {
    final song = songs[index];
    return GestureDetector(
onTap: () {
  PlayerManager.playSong({
    ...song,
    'index': index,
    'songs': songs,
    'albumUrl': song['albumUrl'] ?? song['coverUrl'],
  });
  _openLyrics(index);
},

      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          title: Text(
            song['title'] ?? '',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          subtitle: Text(
            song['artist'] ?? '',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.transparent, // Let background show through
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Aexor',
        style: TextStyle(
          color: Color.fromARGB(255, 3, 253, 24),
          fontSize: 25,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
      centerTitle: true,
    ),
    body: Stack(
      children: [
        // 🖼️ Background Image
        Positioned.fill(
          child: Image.asset(
            'assets/logo/bg/bg_icon.jpg', // <--- replace with your own image
            fit: BoxFit.cover,
          ),
        ),

        // 🌑 Optional dark overlay for better text contrast
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.5),
          ),
        ),

        // 🎵 Song list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: songs.length,
            itemBuilder: (context, i) => _buildSongTile(i),
          ),
        ),

        // 🎚️ Mini Player at the bottom
        const Align(
          alignment: Alignment.bottomCenter,
          child: MiniPlayer(),
        ),
      ],
    ),
  );
}

}
