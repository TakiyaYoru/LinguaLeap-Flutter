// lib/network/google_auth_service.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  /// Sign in with Google
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🔐 [GoogleAuthService] Starting Google Sign-In...');
      
      // Start the sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ [GoogleAuthService] User cancelled Google Sign-In');
        return null;
      }

      print('✅ [GoogleAuthService] Google Sign-In successful');
      print('📧 [GoogleAuthService] Email: ${googleUser.email}');
      print('👤 [GoogleAuthService] Display Name: ${googleUser.displayName}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      print('🔑 [GoogleAuthService] Got authentication tokens');
      print('   - ID Token: ${googleAuth.idToken?.substring(0, 20)}...');

      // Send token to backend
      String? tokenToSend;
      
      if (googleAuth.idToken != null) {
        // Use ID token for backend authentication
        tokenToSend = googleAuth.idToken;
        print('🔐 [GoogleAuthService] Using ID token for backend authentication');
      } else {
        throw Exception('No ID token received from Google');
      }

      // Authenticate with our backend
      final authResult = await AuthService.googleAuth(tokenToSend!);
      
      if (authResult != null && authResult['success'] == true) {
        print('✅ [GoogleAuthService] Backend authentication successful');
        return authResult;
      } else {
        print('❌ [GoogleAuthService] Backend authentication failed');
        print('   Error: ${authResult?['message'] ?? 'Unknown error'}');
        return authResult;
      }

    } catch (error) {
      print('❌ [GoogleAuthService] Google Sign-In error: $error');
      return {
        'success': false,
        'message': 'Google Sign-In failed: ${error.toString()}',
      };
    }
  }

  /// Sign out from Google
  static Future<void> signOut() async {
    try {
      print('🚪 [GoogleAuthService] Signing out from Google...');
      await _googleSignIn.signOut();
      print('✅ [GoogleAuthService] Google Sign-Out successful');
    } catch (error) {
      print('❌ [GoogleAuthService] Google Sign-Out error: $error');
    }
  }

  /// Check if user is signed in
  static Future<bool> isSignedIn() async {
    try {
      final isSignedIn = await _googleSignIn.isSignedIn();
      print('🔍 [GoogleAuthService] Is signed in: $isSignedIn');
      return isSignedIn;
    } catch (error) {
      print('❌ [GoogleAuthService] Error checking sign-in status: $error');
      return false;
    }
  }

  /// Get current user
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      final currentUser = await _googleSignIn.signInSilently();
      if (currentUser != null) {
        print('👤 [GoogleAuthService] Current user: ${currentUser.email}');
      } else {
        print('👤 [GoogleAuthService] No current user');
      }
      return currentUser;
    } catch (error) {
      print('❌ [GoogleAuthService] Error getting current user: $error');
      return null;
    }
  }
} 