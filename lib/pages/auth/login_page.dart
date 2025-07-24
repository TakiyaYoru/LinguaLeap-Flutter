// lib/pages/auth/login_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../network/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Luôn clear token trước khi login mới
    await AuthService.clearToken();
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _message = 'Vui lòng nhập email và password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Đang đăng nhập...';
    });

    try {
      final result = await AuthService.testLogin(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (result != null) {
        final token = result['token'];
        if (token != null) {
          await AuthService.saveToken(token);
          setState(() {
            _message = 'Đăng nhập thành công! ✅';
          });
          // Delay một chút để user thấy message
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            context.go('/home');
          }
        } else {
          setState(() {
            _message = 'Lỗi: Không nhận được token';
          });
        }
      } else {
        setState(() {
          _message = 'Đăng nhập thất bại. Kiểm tra email/password ❌';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.school,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 50,
                ),
              ),
              const SizedBox(height: 32),
              
              // Title
              Text(
                'LinguaLeap',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                'Learn English the smart way',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 48),
              
              // Email field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 20),
              
              // Password field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 8),
              
              // Message
              if (_message.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: _message.contains('✅') 
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                      : Theme.of(context).colorScheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _message.contains('✅') 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  child: Text(
                    _message,
                    style: TextStyle(
                      color: _message.contains('✅') 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              
              // Login button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Register link
              TextButton(
                onPressed: () {
                  context.go('/register');
                },
                child: const Text('Don\'t have an account? Sign up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}