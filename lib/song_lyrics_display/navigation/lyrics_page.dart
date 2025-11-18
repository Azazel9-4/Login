import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../services/player_manager.dart'; // we use RepeatMode from here

class LyricsPage extends StatefulWidget {
  const LyricsPage({super.key});

  @override
  State<LyricsPage> createState() => _LyricsPageState();
}

class _LyricsPageState extends State<LyricsPage> {
  bool _isShuffle = false;

  String _lyrics = "Loading lyrics...";
  String _currentTitle = '';
  String _currentArtist = '';
  String _currentMusicUrl = '';
  String _currentCoverUrl = '';

  List<Map<String, String>> _songs = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    PlayerManager.init();

    // Keep UI synced with playback
    PlayerManager.position.addListener(() {
      if (mounted) setState(() {});
    });
    PlayerManager.duration.addListener(() {
      if (mounted) setState(() {});
    });
    PlayerManager.isPlaying.addListener(() {
      if (mounted) setState(() {});
    });

    // 👇 ADD THIS: Detect when song ends
    PlayerManager.position.addListener(() {
      final pos = PlayerManager.position.value;
      final dur = PlayerManager.duration.value;

      // If playback reaches end
      if (dur.inSeconds > 0 && pos >= dur - const Duration(milliseconds: 500)) {
        // Avoid multiple triggers by checking if playing stopped
        if (!PlayerManager.isPlaying.value) {
          // Let PlayerManager handle repeat logic
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              if (PlayerManager.repeatMode.value == RepeatMode.one) {
                // replay same song
                _playCurrentSong();
              } else {
                // move to next
                _playNextSong();
              }
            }
          });
        }
      }
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    _songs = (args['songs'] as List).cast<Map<String, String>>();
    _currentIndex = args['index'] ?? 0;
    final resume = args['resume'] ?? false;

    final song = _songs[_currentIndex];
    _currentTitle = song['title'] ?? '';
    _currentArtist = song['artist'] ?? '';
    _currentMusicUrl = song['musicUrl'] ?? '';
    _currentCoverUrl = song['coverUrl'] ?? '';

    _loadLyrics(_currentTitle);

    if (!resume) {
      _playCurrentSong();
    }
  }

  Future<void> _loadLyrics(String title) async {
    try {
      final filename = title.toLowerCase().replaceAll(" ", "_");
      final data = await rootBundle.loadString('assets/logo/lyrics/$filename.txt');
      setState(() => _lyrics = data);
    } catch (e) {
      setState(() => _lyrics = "Lyrics not found for $title.");
    }
  }

  Future<void> _playCurrentSong() async {
    final song = {
      'title': _currentTitle,
      'artist': _currentArtist,
      'musicUrl': _currentMusicUrl,
      'coverUrl': _currentCoverUrl,
      'albumUrl': _songs[_currentIndex]['albumUrl'] ?? _currentCoverUrl,
      'index': _currentIndex,
      'songs': _songs,
    };
    await PlayerManager.playSong(song);
  }

  void _playNextSong() {
    setState(() {
      _currentIndex = _isShuffle
          ? Random().nextInt(_songs.length)
          : (_currentIndex + 1) % _songs.length;
    });
    _updateSong();
  }

  void _playPreviousSong() {
    setState(() {
      _currentIndex = _isShuffle
          ? Random().nextInt(_songs.length)
          : (_currentIndex - 1 + _songs.length) % _songs.length;
    });
    _updateSong();
  }

  void _updateSong() {
    final song = _songs[_currentIndex];
    _currentTitle = song['title'] ?? '';
    _currentArtist = song['artist'] ?? '';
    _currentMusicUrl = song['musicUrl'] ?? '';
    _currentCoverUrl = song['coverUrl'] ?? '';
    _loadLyrics(_currentTitle);
    _playCurrentSong();
  }

  void _toggleShuffle() => setState(() => _isShuffle = !_isShuffle);

  String _formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          if (_currentCoverUrl.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_currentCoverUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        _currentTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "by $_currentArtist",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Color.fromARGB(200, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 🎤 Lyrics
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _lyrics,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        height: 1.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black54,
                            offset: Offset(1, 1),
                          )
                        ],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🎚️ Slider + Time
                ValueListenableBuilder(
                  valueListenable: PlayerManager.position,
                  builder: (_, pos, __) {
                    final dur = PlayerManager.duration.value;
                    final pos = PlayerManager.position.value;
                    return Column(
                      children: [
                        Slider(
                          activeColor: Colors.white,
                          inactiveColor: Colors.white30,
                          value: pos.inSeconds
                              .toDouble()
                              .clamp(0, dur.inSeconds.toDouble()),
                          max: dur.inSeconds.toDouble() > 0
                              ? dur.inSeconds.toDouble()
                              : 1,
                          onChanged: (value) =>
                              PlayerManager.seek(Duration(seconds: value.toInt())),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_formatTime(pos),
                                style: const TextStyle(color: Colors.white70)),
                            Text(_formatTime(dur),
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 15),

                // 🎧 Controls
                ValueListenableBuilder(
                  valueListenable: PlayerManager.isPlaying,
                  builder: (_, playing, __) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 🔁 Repeat button (synced with PlayerManager)
                        ValueListenableBuilder<RepeatMode>(
                          valueListenable: PlayerManager.repeatMode,
                          builder: (context, repeatMode, _) {
                            IconData icon;
                            Color color;

                            switch (repeatMode) {
                              case RepeatMode.off:
                                icon = Icons.repeat;
                                color = Colors.white70;
                                break;
                              case RepeatMode.one:
                                icon = Icons.repeat_one;
                                color = const Color.fromARGB(255, 10, 255, 2);
                                break;
                              case RepeatMode.all:
                                icon = Icons.repeat;
                                color = const Color.fromARGB(255, 10, 255, 2);
                                break;
                            }

                            return IconButton(
                              icon: Icon(icon, color: color),
                              iconSize: 30,
                              onPressed: PlayerManager.toggleRepeatMode,
                            );
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.skip_previous, color: Colors.white),
                          iconSize: 50,
                          onPressed: _playPreviousSong,
                        ),
                        InkWell(
                          onTap: PlayerManager.togglePlayPause,
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 4, 250, 78),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              playing ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 55,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.skip_next, color: Colors.white),
                          iconSize: 50,
                          onPressed: _playNextSong,
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: _isShuffle
                                ? const Color.fromARGB(255, 10, 255, 2)
                                : Colors.white70,
                          ),
                          iconSize: 30,
                          onPressed: _toggleShuffle,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}