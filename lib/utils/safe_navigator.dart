// lib/utils/safe_navigator.dart - BULLETPROOF NAVIGATION UTILS
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SafeNavigator {
  static final Map<String, DateTime> _lastNavigationTimes = {};
  static const Duration _debounceTime = Duration(milliseconds: 300);
  
  // 🔥 BULLETPROOF: Safe navigation with debouncing
  static Future<T?> safePush<T extends Object?>(
    BuildContext context, 
    String route, {
    String? debugName,
  }) async {
    final key = debugName ?? route;
    final now = DateTime.now();
    
    // Check debounce
    if (_lastNavigationTimes.containsKey(key)) {
      final lastTime = _lastNavigationTimes[key]!;
      if (now.difference(lastTime) < _debounceTime) {
        print('🚫 Navigation debounced for $key');
        return null;
      }
    }
    
    // Check if context is still valid
    if (!context.mounted) {
      print('🚫 Context not mounted for $key');
      return null;
    }
    
    _lastNavigationTimes[key] = now;
    
    try {
      print('🚀 Safe navigation to: $route');
      final result = await context.push<T>(route);
      print('✅ Navigation completed: $route');
      return result;
    } catch (e) {
      print('❌ Navigation error: $e');
      return null;
    } finally {
      // Clear debounce after delay
      Future.delayed(_debounceTime, () {
        _lastNavigationTimes.remove(key);
      });
    }
  }
  
  // 🔥 BULLETPROOF: Safe pop with checks
  static Future<bool> safePop<T extends Object?>(BuildContext context, [T? result]) async {
    if (!context.mounted) {
      print('🚫 Context not mounted for pop');
      return false;
    }
    
    // Check if we can pop using GoRouter
    if (GoRouter.of(context).canPop()) {
      try {
        print('🔙 Safe pop with GoRouter');
        GoRouter.of(context).pop(result);
        return true;
      } catch (e) {
        print('❌ GoRouter pop error: $e');
      }
    }
    
    // Fallback to Navigator
    if (Navigator.of(context).canPop()) {
      try {
        print('🔙 Safe pop with Navigator');
        Navigator.of(context).pop<T>(result);
        return true;
      } catch (e) {
        print('❌ Navigator pop error: $e');
      }
    }
    
    print('🚫 Cannot pop - no routes in stack');
    return false;
  }
}

// 🔥 BULLETPROOF: Safe tap widget with built-in debouncing
class SafeTapWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration debounceDuration;
  final bool enabled;
  
  const SafeTapWidget({
    super.key,
    required this.child,
    this.onTap,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.enabled = true,
  });

  @override
  State<SafeTapWidget> createState() => _SafeTapWidgetState();
}

class _SafeTapWidgetState extends State<SafeTapWidget> {
  DateTime? _lastTapTime;
  bool _isProcessing = false;

  bool get _canTap {
    if (!widget.enabled || _isProcessing) return false;
    
    final now = DateTime.now();
    if (_lastTapTime != null) {
      final difference = now.difference(_lastTapTime!);
      if (difference < widget.debounceDuration) {
        return false;
      }
    }
    return true;
  }

  Future<void> _handleTap() async {
    if (!_canTap || widget.onTap == null) return;
    
    setState(() {
      _isProcessing = true;
      _lastTapTime = DateTime.now();
    });
    
    try {
      widget.onTap!();
    } finally {
      // Reset processing state after a delay
      Future.delayed(widget.debounceDuration, () {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: widget.child,
    );
  }
}