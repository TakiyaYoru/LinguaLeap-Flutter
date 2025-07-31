// lib/pages/auth/login_page.dart - COMPLETE IMPROVED VERSION
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../network/auth_service.dart';
import '../../theme/app_themes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String _message = '';

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    setState(() {
      _isLoading = true;
      _message = '';
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
            _message = 'Login successful! ✅';
          });
          
          // Success haptic feedback
          HapticFeedback.lightImpact();
          
          // Delay to show success message
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            context.go('/home');
          }
        } else {
          setState(() {
            _message = 'Error: No token received';
          });
          HapticFeedback.heavyImpact();
        }
      } else {
        setState(() {
          _message = 'Login failed. Please check your credentials.';
        });
        HapticFeedback.heavyImpact();
      }
    } catch (e) {
      setState(() {
        _message = 'Network error. Please try again.';
      });
      HapticFeedback.heavyImpact();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
        ? AppThemes.darkBackground 
        : AppThemes.lightGroupedBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08, // 8% of screen width
                    vertical: isSmallScreen ? 20 : 40,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: 400, // Max width for larger screens
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo and Welcome Section
                            if (!keyboardVisible || !isSmallScreen) ...[
                              const SizedBox(height: 20),
                              _buildLogoSection(),
                              SizedBox(height: isSmallScreen ? 30 : 50),
                            ],
                            
                            // Login Form Card
                            _buildLoginCard(),
                            
                            const SizedBox(height: 24),
                            
                            // Register Link
                            _buildRegisterLink(),
                            
                            // Add spacing for keyboard
                            SizedBox(height: keyboardVisible ? 20 : 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppThemes.primaryGreen.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            color: Colors.white,
            size: 50,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Welcome Text
        Text(
          'Welcome Back!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
            fontFamily: '-apple-system',
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Sign in to continue your learning journey',
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkSecondaryLabel 
              : AppThemes.lightSecondaryLabel,
            fontFamily: '-apple-system',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? AppThemes.darkSecondaryBackground 
          : AppThemes.lightBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          _buildEmailField(),
          
          const SizedBox(height: 20),
          
          // Password Field
          _buildPasswordField(),
          
          const SizedBox(height: 24),
          
          // Message Display
          if (_message.isNotEmpty) ...[
            _buildMessageCard(),
            const SizedBox(height: 20),
          ],
          
          // Login Button
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
            fontFamily: '-apple-system',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          style: TextStyle(
            fontSize: 16,
            fontFamily: '-apple-system',
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your email',
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppThemes.darkSecondaryLabel 
                : AppThemes.lightSecondaryLabel,
              fontFamily: '-apple-system',
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
              color: AppThemes.primaryGreen,
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkTertiaryBackground 
              : AppThemes.lightSecondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                  ? AppThemes.darkTertiaryBackground 
                  : AppThemes.lightSecondaryBackground,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppThemes.primaryGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppThemes.systemRed,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
            fontFamily: '-apple-system',
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleLogin(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
          style: TextStyle(
            fontSize: 16,
            fontFamily: '-apple-system',
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppThemes.darkSecondaryLabel 
                : AppThemes.lightSecondaryLabel,
              fontFamily: '-apple-system',
            ),
            prefixIcon: Icon(
              Icons.lock_outlined,
              color: AppThemes.primaryGreen,
            ),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Theme.of(context).brightness == Brightness.dark 
                  ? AppThemes.darkSecondaryLabel 
                  : AppThemes.lightSecondaryLabel,
              ),
            ),
            filled: true,
            fillColor: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkTertiaryBackground 
              : AppThemes.lightSecondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark 
                  ? AppThemes.darkTertiaryBackground 
                  : AppThemes.lightSecondaryBackground,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppThemes.primaryGreen,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppThemes.systemRed,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard() {
    final isSuccess = _message.contains('✅');
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess 
          ? AppThemes.primaryGreen.withOpacity(0.1)
          : AppThemes.systemRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuccess 
            ? AppThemes.primaryGreen.withOpacity(0.5)
            : AppThemes.systemRed.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: isSuccess ? AppThemes.primaryGreen : AppThemes.systemRed,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _message,
              style: TextStyle(
                color: isSuccess ? AppThemes.primaryGreen : AppThemes.systemRed,
                fontWeight: FontWeight.w500,
                fontFamily: '-apple-system',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppThemes.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: AppThemes.primaryGreen.withOpacity(0.3),
          disabledBackgroundColor: AppThemes.primaryGreen.withOpacity(0.6),
        ),
        child: _isLoading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: '-apple-system',
              ),
            ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
          ? AppThemes.darkSecondaryBackground.withOpacity(0.5)
          : AppThemes.lightBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark 
            ? AppThemes.darkTertiaryBackground 
            : AppThemes.lightSecondaryBackground,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account? ',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppThemes.darkSecondaryLabel 
                : AppThemes.lightSecondaryLabel,
              fontFamily: '-apple-system',
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/register');
            },
            child: Text(
              'Sign Up',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppThemes.primaryGreen,
                fontFamily: '-apple-system',
              ),
            ),
          ),
        ],
      ),
    );
  }
}