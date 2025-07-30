// ===============================================
// FIXED AUDIO SERVICE - AUDIO PLAYBACK MANAGEMENT
// ===============================================

import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

enum AudioState {
  stopped,
  playing,
  paused,
  loading,
  error
}

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioState _currentState = AudioState.stopped;
  String? _currentAudioUrl;
  Function(AudioState)? _onStateChanged;
  Function(Duration)? _onPositionChanged;
  Function(Duration)? _onDurationChanged;

  // Getters
  AudioState get currentState => _currentState;
  String? get currentAudioUrl => _currentAudioUrl;
  bool get isPlaying => _currentState == AudioState.playing;
  bool get isLoading => _currentState == AudioState.loading;
  bool get hasError => _currentState == AudioState.error;

  // Initialize audio service
  Future<void> initialize() async {
    try {
      // Request audio permissions only for mobile platforms
      await _requestPermissions();
      
      // Setup audio player listeners
      _audioPlayer.onPlayerStateChanged.listen((state) {
        _updateState(_mapPlayerState(state));
      });
      
      _audioPlayer.onPositionChanged.listen((position) {
        _onPositionChanged?.call(position);
      });
      
      _audioPlayer.onDurationChanged.listen((duration) {
        _onDurationChanged?.call(duration);
      });
      
      _audioPlayer.onPlayerComplete.listen((_) {
        _updateState(AudioState.stopped);
      });
      
      print('✅ Audio service initialized successfully');
    } catch (e) {
      print('❌ Audio service initialization error: $e');
      _updateState(AudioState.error);
    }
  }

  // Request audio permissions (fixed for web compatibility)
  Future<void> _requestPermissions() async {
    try {
      // Only request permissions on mobile platforms
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.audio.request();
        if (status != PermissionStatus.granted) {
          print('⚠️ Audio permission not granted');
        }
      }
      // Web doesn't need explicit audio permissions
    } catch (e) {
      print('⚠️ Permission request error (likely web platform): $e');
      // Continue anyway - web doesn't need permissions
    }
  }

  // Validate audio URL
  bool _isValidAudioUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    // Check if URL is properly formatted
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Play audio from URL
  Future<void> playAudio(String audioUrl) async {
    try {
      // Validate audio URL
      if (!_isValidAudioUrl(audioUrl)) {
        print('❌ Invalid audio URL: $audioUrl');
        _updateState(AudioState.error);
        return;
      }

      if (_currentAudioUrl == audioUrl && _currentState == AudioState.playing) {
        return; // Already playing this audio
      }

      print('🎵 Attempting to play audio: $audioUrl');
      _updateState(AudioState.loading);
      _currentAudioUrl = audioUrl;

      // Stop current audio if playing
      if (_currentState == AudioState.playing || _currentState == AudioState.paused) {
        await _audioPlayer.stop();
      }

      // Play the new audio
      await _audioPlayer.play(UrlSource(audioUrl));
      
      print('✅ Audio started playing successfully');
      _updateState(AudioState.playing);
    } catch (e) {
      print('❌ Error playing audio: $e');
      _updateState(AudioState.error);
      rethrow; // Re-throw to handle in UI
    }
  }

  // Pause audio
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      _updateState(AudioState.paused);
    } catch (e) {
      print('❌ Error pausing audio: $e');
      _updateState(AudioState.error);
    }
  }

  // Resume audio
  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.resume();
      _updateState(AudioState.playing);
    } catch (e) {
      print('❌ Error resuming audio: $e');
      _updateState(AudioState.error);
    }
  }

  // Stop audio
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _updateState(AudioState.stopped);
      _currentAudioUrl = null;
    } catch (e) {
      print('❌ Error stopping audio: $e');
      _updateState(AudioState.error);
    }
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('❌ Error seeking audio: $e');
    }
  }

  // Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('❌ Error setting volume: $e');
    }
  }

  // Set playback rate (0.5 to 2.0)
  Future<void> setPlaybackRate(double rate) async {
    try {
      await _audioPlayer.setPlaybackRate(rate.clamp(0.5, 2.0));
    } catch (e) {
      print('❌ Error setting playback rate: $e');
    }
  }

  // Update state and notify listeners
  void _updateState(AudioState newState) {
    _currentState = newState;
    _onStateChanged?.call(newState);
  }

  // Map AudioPlayer state to our AudioState enum
  AudioState _mapPlayerState(PlayerState state) {
    switch (state) {
      case PlayerState.stopped:
        return AudioState.stopped;
      case PlayerState.playing:
        return AudioState.playing;
      case PlayerState.paused:
        return AudioState.paused;
      case PlayerState.completed:
        return AudioState.stopped;
      default:
        return AudioState.error;
    }
  }

  // Set state change listener
  void onStateChanged(Function(AudioState) callback) {
    _onStateChanged = callback;
  }

  // Set position change listener
  void onPositionChanged(Function(Duration) callback) {
    _onPositionChanged = callback;
  }

  // Set duration change listener
  void onDurationChanged(Function(Duration) callback) {
    _onDurationChanged = callback;
  }

  // Dispose resources
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _onStateChanged = null;
      _onPositionChanged = null;
      _onDurationChanged = null;
    } catch (e) {
      print('❌ Error disposing audio service: $e');
    }
  }
}

// ===============================================
// AUDIO WIDGET HELPERS
// ===============================================

class AudioWidgetHelper {
  // Format duration to MM:SS
  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  // Get audio state icon
  static String getAudioStateIcon(AudioState state) {
    switch (state) {
      case AudioState.playing:
        return '⏸️';
      case AudioState.paused:
        return '▶️';
      case AudioState.loading:
        return '⏳';
      case AudioState.error:
        return '❌';
      case AudioState.stopped:
      default:
        return '▶️';
    }
  }

  // Get audio state color
  static String getAudioStateColor(AudioState state) {
    switch (state) {
      case AudioState.playing:
        return '#34C759'; // Green
      case AudioState.paused:
        return '#007AFF'; // Blue
      case AudioState.loading:
        return '#FF9500'; // Orange
      case AudioState.error:
        return '#FF3B30'; // Red
      case AudioState.stopped:
      default:
        return '#8E8E93'; // Gray
    }
  }
}