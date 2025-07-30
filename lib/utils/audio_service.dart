// ===============================================
// IMPROVED AUDIO SERVICE - CROSS-PLATFORM COMPATIBLE
// ===============================================

import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

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

  AudioPlayer? _audioPlayer;
  AudioState _currentState = AudioState.stopped;
  String? _currentAudioUrl;
  Function(AudioState)? _onStateChanged;
  Function(Duration)? _onPositionChanged;
  Function(Duration)? _onDurationChanged;
  bool _isInitialized = false;
  bool _isDisposed = false;

  // Getters
  AudioState get currentState => _currentState;
  String? get currentAudioUrl => _currentAudioUrl;
  bool get isPlaying => _currentState == AudioState.playing;
  bool get isLoading => _currentState == AudioState.loading;
  bool get hasError => _currentState == AudioState.error;
  bool get isInitialized => _isInitialized;
  AudioPlayer? get audioPlayer => _audioPlayer;

  // Initialize audio service with better error handling
  Future<void> initialize() async {
    if (_isInitialized && _audioPlayer != null && !_isDisposed) return;
    
    try {
      print('🔊 [AudioService] Initializing...');
      
      // Clean up existing player if any
      if (_audioPlayer != null) {
        try {
          await _audioPlayer!.dispose();
        } catch (e) {
          print('⚠️ [AudioService] Error disposing old player: $e');
        }
      }
      
      // Create new player
      _audioPlayer = AudioPlayer();
      _isDisposed = false;
      
      // Request audio permissions only for mobile platforms
      if (!kIsWeb) {
        await _requestPermissions();
      }
      
      // Setup audio player listeners with error handling
      _audioPlayer!.onPlayerStateChanged.listen(
        (state) {
          print('🎵 [AudioService] State changed: $state');
          _updateState(_mapPlayerState(state));
        },
        onError: (error) {
          print('❌ [AudioService] State change error: $error');
          _updateState(AudioState.error);
        }
      );
      
      _audioPlayer!.onPositionChanged.listen(
        (position) {
          _onPositionChanged?.call(position);
        },
        onError: (error) {
          print('❌ [AudioService] Position change error: $error');
        }
      );
      
      _audioPlayer!.onDurationChanged.listen(
        (duration) {
          _onDurationChanged?.call(duration);
        },
        onError: (error) {
          print('❌ [AudioService] Duration change error: $error');
        }
      );
      
      _audioPlayer!.onPlayerComplete.listen(
        (_) {
          print('✅ [AudioService] Audio completed');
          _updateState(AudioState.stopped);
        },
        onError: (error) {
          print('❌ [AudioService] Completion error: $error');
        }
      );
      
      // Web-specific initialization
      if (kIsWeb) {
        await _initializeWebAudio();
      }
      
      _isInitialized = true;
      print('✅ [AudioService] Initialized successfully');
    } catch (e) {
      print('❌ [AudioService] Initialization error: $e');
      _updateState(AudioState.error);
      _isInitialized = false;
      _audioPlayer = null;
    }
  }

  // Reinitialize player if needed
  Future<void> _ensurePlayerReady() async {
    if (_audioPlayer == null || _isDisposed) {
      print('🔄 [AudioService] Reinitializing player...');
      await initialize();
    }
  }

  // Web-specific audio initialization
  Future<void> _initializeWebAudio() async {
    try {
      // For web, we need to ensure audio context is ready
      await _audioPlayer!.setReleaseMode(ReleaseMode.stop);
      print('✅ [AudioService] Web audio initialized');
    } catch (e) {
      print('⚠️ [AudioService] Web audio init warning: $e');
    }
  }

  // Request audio permissions with better platform handling
  Future<void> _requestPermissions() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.audio.request();
        if (status != PermissionStatus.granted) {
          print('⚠️ [AudioService] Audio permission not granted: $status');
          // Don't throw error, just log warning
        } else {
          print('✅ [AudioService] Audio permission granted');
        }
      }
    } catch (e) {
      print('⚠️ [AudioService] Permission request error: $e');
      // Continue anyway - some platforms don't need explicit permissions
    }
  }

  // Enhanced URL validation
  bool _isValidAudioUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      
      // Check for valid schemes
      if (!uri.hasScheme) return false;
      
      // Allow HTTP, HTTPS, and data URLs for web
      if (kIsWeb) {
        return uri.scheme == 'http' || 
               uri.scheme == 'https' || 
               uri.scheme == 'data';
      }
      
      // Mobile platforms: HTTP, HTTPS, file, and asset URLs
      return uri.scheme == 'http' || 
             uri.scheme == 'https' || 
             uri.scheme == 'file' ||
             uri.scheme == 'asset';
    } catch (e) {
      print('❌ [AudioService] URL validation error: $e');
      return false;
    }
  }

  // Enhanced play audio with better error handling
  Future<void> playAudio(String audioUrl) async {
    try {
      await _ensurePlayerReady();
      
      // Validate audio URL
      if (!_isValidAudioUrl(audioUrl)) {
        print('❌ [AudioService] Invalid audio URL: $audioUrl');
        _updateState(AudioState.error);
        throw Exception('Invalid audio URL: $audioUrl');
      }

      // Check if already playing the same audio
      if (_currentAudioUrl == audioUrl && _currentState == AudioState.playing) {
        print('ℹ️ [AudioService] Already playing this audio');
        return;
      }

      print('🎵 [AudioService] Attempting to play: ${audioUrl.length > 50 ? audioUrl.substring(0, 50) + '...' : audioUrl}');
      _updateState(AudioState.loading);
      _currentAudioUrl = audioUrl;

      // Stop current audio if playing
      if (_currentState == AudioState.playing || _currentState == AudioState.paused) {
        try {
          await _audioPlayer!.stop();
        } catch (e) {
          print('⚠️ [AudioService] Error stopping current audio: $e');
          // Continue anyway
        }
      }

      // Create audio source based on platform
      Source audioSource;
      if (audioUrl.startsWith('data:')) {
        // Handle data URLs (web)
        audioSource = UrlSource(audioUrl);
      } else if (audioUrl.startsWith('asset:')) {
        // Handle asset URLs
        audioSource = AssetSource(audioUrl.substring(6));
      } else {
        // Handle regular URLs
        audioSource = UrlSource(audioUrl);
      }

      // Play the audio with timeout and retry logic
      try {
        await _audioPlayer!.play(audioSource).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw Exception('Audio playback timeout');
          }
        );
        
        print('✅ [AudioService] Audio started playing successfully');
        _updateState(AudioState.playing);
      } catch (playError) {
        print('❌ [AudioService] Play error: $playError');
        
        // For web, try to reinitialize and retry once
        if (kIsWeb && playError.toString().contains('disposed')) {
          print('🔄 [AudioService] Web player disposed, reinitializing...');
          _isInitialized = false;
          _audioPlayer = null;
          await _ensurePlayerReady();
          
          // Retry once
          try {
            await _audioPlayer!.play(audioSource).timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception('Audio playback timeout on retry');
              }
            );
            print('✅ [AudioService] Audio started playing successfully on retry');
            _updateState(AudioState.playing);
          } catch (retryError) {
            print('❌ [AudioService] Retry failed: $retryError');
            _updateState(AudioState.error);
            rethrow;
          }
        } else {
          _updateState(AudioState.error);
          rethrow;
        }
      }
    } catch (e) {
      print('❌ [AudioService] Error playing audio: $e');
      _updateState(AudioState.error);
      rethrow;
    }
  }

  // Pause audio with error handling
  Future<void> pauseAudio() async {
    try {
      await _ensurePlayerReady();
      if (_currentState == AudioState.playing) {
        await _audioPlayer!.pause();
        _updateState(AudioState.paused);
        print('⏸️ [AudioService] Audio paused');
      }
    } catch (e) {
      print('❌ [AudioService] Error pausing audio: $e');
      _updateState(AudioState.error);
    }
  }

  // Resume audio with error handling
  Future<void> resumeAudio() async {
    try {
      await _ensurePlayerReady();
      if (_currentState == AudioState.paused) {
        await _audioPlayer!.resume();
        _updateState(AudioState.playing);
        print('▶️ [AudioService] Audio resumed');
      }
    } catch (e) {
      print('❌ [AudioService] Error resuming audio: $e');
      _updateState(AudioState.error);
    }
  }

  // Stop audio with error handling
  Future<void> stopAudio() async {
    try {
      // Check if player is disposed before trying to stop
      if (_audioPlayer == null || _isDisposed) {
        print('ℹ️ [AudioService] Player already disposed, skipping stop');
        _updateState(AudioState.stopped);
        _currentAudioUrl = null;
        return;
      }
      
      await _audioPlayer!.stop();
      _updateState(AudioState.stopped);
      _currentAudioUrl = null;
      print('⏹️ [AudioService] Audio stopped');
    } catch (e) {
      print('❌ [AudioService] Error stopping audio: $e');
      // Even if stop fails, update state to stopped
      _updateState(AudioState.stopped);
      _currentAudioUrl = null;
    }
  }

  // Seek to position with validation
  Future<void> seekTo(Duration position) async {
    try {
      await _ensurePlayerReady();
      if (position.isNegative) {
        print('⚠️ [AudioService] Invalid seek position: $position');
        return;
      }
      await _audioPlayer!.seek(position);
      print('🔍 [AudioService] Seeked to: ${position.inSeconds}s');
    } catch (e) {
      print('❌ [AudioService] Error seeking audio: $e');
    }
  }

  // Set volume with validation
  Future<void> setVolume(double volume) async {
    try {
      await _ensurePlayerReady();
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer!.setVolume(clampedVolume);
      print('🔊 [AudioService] Volume set to: ${(clampedVolume * 100).round()}%');
    } catch (e) {
      print('❌ [AudioService] Error setting volume: $e');
    }
  }

  // Set playback rate with validation
  Future<void> setPlaybackRate(double rate) async {
    try {
      await _ensurePlayerReady();
      final clampedRate = rate.clamp(0.5, 2.0);
      await _audioPlayer!.setPlaybackRate(clampedRate);
      print('⚡ [AudioService] Playback rate set to: ${clampedRate}x');
    } catch (e) {
      print('❌ [AudioService] Error setting playback rate: $e');
    }
  }

  // Update state and notify listeners
  void _updateState(AudioState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _onStateChanged?.call(newState);
    }
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

  // Get current position
  Future<Duration> getCurrentPosition() async {
    try {
      await _ensurePlayerReady();
      return await _audioPlayer!.getCurrentPosition() ?? Duration.zero;
    } catch (e) {
      print('❌ [AudioService] Error getting position: $e');
      return Duration.zero;
    }
  }

  // Get total duration
  Future<Duration> getDuration() async {
    try {
      await _ensurePlayerReady();
      return await _audioPlayer!.getDuration() ?? Duration.zero;
    } catch (e) {
      print('❌ [AudioService] Error getting duration: $e');
      return Duration.zero;
    }
  }

  // Check if audio is ready to play
  bool get isReady => _isInitialized && _currentState != AudioState.error;

  // Dispose resources with error handling
  Future<void> dispose() async {
    if (_isDisposed) return;
    
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.dispose();
      }
      _onStateChanged = null;
      _onPositionChanged = null;
      _onDurationChanged = null;
      _isInitialized = false;
      _isDisposed = true;
      _audioPlayer = null;
      print('🧹 [AudioService] Disposed successfully');
    } catch (e) {
      print('❌ [AudioService] Error disposing: $e');
      // Mark as disposed anyway
      _isDisposed = true;
      _audioPlayer = null;
    }
  }

  // Reset audio service for new exercise
  Future<void> resetForNewExercise() async {
    try {
      print('🔄 [AudioService] Resetting for new exercise...');
      
      // Only stop audio if player is not disposed
      if (_audioPlayer != null && !_isDisposed) {
        try {
          await _audioPlayer!.stop();
        } catch (e) {
          print('⚠️ [AudioService] Error stopping audio during reset: $e');
          // Continue with reset even if stop fails
        }
      }
      
      // Reset state
      _currentAudioUrl = null;
      _updateState(AudioState.stopped);
      
      // Clear listeners temporarily
      _onPositionChanged = null;
      _onDurationChanged = null;
      
      print('✅ [AudioService] Reset completed for new exercise');
    } catch (e) {
      print('❌ [AudioService] Error resetting for new exercise: $e');
    }
  }

  // Force reinitialize audio service
  Future<void> forceReinitialize() async {
    try {
      print('🔄 [AudioService] Force reinitializing...');
      
      // Mark as not initialized
      _isInitialized = false;
      
      // Dispose current player if exists
      if (_audioPlayer != null) {
        try {
          await _audioPlayer!.dispose();
        } catch (e) {
          print('⚠️ [AudioService] Error disposing during force reinit: $e');
        }
      }
      
      // Reset state
      _currentAudioUrl = null;
      _updateState(AudioState.stopped);
      _isDisposed = false;
      
      // Initialize fresh
      await initialize();
      
      print('✅ [AudioService] Force reinitialization completed');
    } catch (e) {
      print('❌ [AudioService] Error during force reinitialization: $e');
      _updateState(AudioState.error);
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

  // Check if platform supports audio
  static bool get isAudioSupported {
    return !kIsWeb || (kIsWeb && _isWebAudioSupported());
  }

  // Check web audio support
  static bool _isWebAudioSupported() {
    try {
      // Basic check for web audio support
      return true; // Most modern browsers support audio
    } catch (e) {
      return false;
    }
  }
}