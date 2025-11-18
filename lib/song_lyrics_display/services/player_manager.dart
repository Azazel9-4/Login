// services/player_manager.dart
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum RepeatMode { off, one, all }

class PlayerManager {
  static final AudioPlayer player = AudioPlayer();

  // Notifiers
  static final ValueNotifier<Map<String, dynamic>?> current =
      ValueNotifier<Map<String, dynamic>?>(null);
  static final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  static final ValueNotifier<Duration> position =
      ValueNotifier<Duration>(Duration.zero);
  static final ValueNotifier<Duration> duration =
      ValueNotifier<Duration>(Duration.zero);
  static final ValueNotifier<RepeatMode> repeatMode =
      ValueNotifier<RepeatMode>(RepeatMode.off);

  static void init() {
    player.onPlayerComplete.listen((_) {
      _handleSongCompletion();
    });

    player.onDurationChanged.listen((d) {
      duration.value = d;
    });

    player.onPositionChanged.listen((p) {
      position.value = p;
    });
  }

  // 🔹 PLAY SONG
  static Future<void> playSong(Map<String, dynamic> song) async {
    try {
      await player.stop();
    } catch (_) {}

    final musicUrl = (song['musicUrl'] ?? '') as String;
    final sourcePath = musicUrl.replaceFirst('assets/', '');
    try {
      await player.play(AssetSource(sourcePath));
      current.value = song;
      isPlaying.value = true;
    } catch (e) {
      isPlaying.value = false;
    }
  }

  // 🔹 PLAY / PAUSE TOGGLE
  static Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await player.pause();
      isPlaying.value = false;
    } else {
      if (current.value != null) {
        await player.resume();
        isPlaying.value = true;
      }
    }
  }

  // 🔹 SEEK
  static Future<void> seek(Duration pos) async {
    await player.seek(pos);
  }

  // 🔹 STOP
  static Future<void> stop() async {
    await player.stop();
    isPlaying.value = false;
  }

  // 🔹 TOGGLE REPEAT MODE
  static void toggleRepeatMode() {
    switch (repeatMode.value) {
      case RepeatMode.off:
        repeatMode.value = RepeatMode.one;
        break;
      case RepeatMode.one:
        repeatMode.value = RepeatMode.all;
        break;
      case RepeatMode.all:
        repeatMode.value = RepeatMode.off;
        break;
    }
  }

  // 🔹 HANDLE WHEN SONG ENDS
  static Future<void> _handleSongCompletion() async {
    isPlaying.value = false;
    final mode = repeatMode.value;
    final currentSong = current.value;

    if (currentSong == null) return;

    final songs = currentSong['songs'] as List<Map<String, String>>?;
    final index = currentSong['index'] as int?;

    if (songs == null || index == null) return;

    if (mode == RepeatMode.one) {
      // 🔁 Replay the same song
      await playSong({
        ...songs[index],
        'index': index,
        'songs': songs,
      });
    } else if (mode == RepeatMode.all) {
      // ⏭ Play next song, looping back to start if needed
      final nextIndex = (index + 1) % songs.length;
      await playSong({
        ...songs[nextIndex],
        'index': nextIndex,
        'songs': songs,
      });
    } else {
      // ❌ Repeat off — just stop
      isPlaying.value = false;
    }
  }
}
