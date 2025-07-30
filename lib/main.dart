// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'network/graphql_client.dart';
import 'network/auth_service.dart';
import 'routes/app_router.dart';
import 'theme/theme_manager.dart';
import 'theme/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Auto-login for testing
  await _autoLogin();
  
  runApp(
    GraphQLProvider(
      client: ValueNotifier(GraphQLService.client),
      child: const MyApp(),
    ),
  );
}

// Auto-login function for testing
Future<void> _autoLogin() async {
  try {
    print('🔐 Auto-login for testing...');
    
    // Check if already logged in
    final existingToken = await AuthService.getToken();
    if (existingToken != null) {
      print('✅ Already logged in with existing token');
      return;
    }
    
    // Auto-login with test account
    final loginResult = await AuthService.testLogin('test@example.com', 'password123');
    
    if (loginResult != null && loginResult['token'] != null) {
      await AuthService.saveToken(loginResult['token']);
      print('✅ Auto-login successful');
      print('   User: ${loginResult['user']['email']}');
    } else {
      print('❌ Auto-login failed');
    }
  } catch (e) {
    print('❌ Auto-login error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ThemeManager(),
      child: Consumer<ThemeManager>(
        builder: (context, themeManager, child) {
          return GetMaterialApp.router(
            title: 'LinguaLeap',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeManager.themeMode,
            routeInformationParser: AppRouter.router.routeInformationParser,
            routeInformationProvider: AppRouter.router.routeInformationProvider,
            routerDelegate: AppRouter.router.routerDelegate,
            debugShowCheckedModeBanner: false,
            defaultTransition: Transition.cupertino,
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
    );
  }
}