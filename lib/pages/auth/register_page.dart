// lib/pages/auth/register_page.dart - COMPLETE VERSION
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../network/auth_service.dart';
import '../../theme/app_themes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
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
    _usernameController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final result = await AuthService.testRegister(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
        _displayNameController.text.trim(),
      );

      if (result != null) {
        final token = result['token'];
        if (token != null) {
          await AuthService.saveToken(token);
          setState(() {
            _message = 'Account created successfully! ✅';
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
          _message = 'Registration failed. Please try again.';
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
                    vertical: isSmallScreen ? 15 : 30,
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
                            // Header Section
                            if (!keyboardVisible || !isSmallScreen) ...[
                              const SizedBox(height: 10),
                              _buildHeaderSection(),
                              SizedBox(height: isSmallScreen ? 20 : 35),
                            ],
                            
                            // Register Form Card
                            _buildRegisterCard(),
                            
                            const SizedBox(height: 20),
                            
                            // Login Link
                            _buildLoginLink(),
                            
                            // Add spacing for keyboard
                            SizedBox(height: keyboardVisible ? 15 : 30),
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

  Widget _buildHeaderSection() {
    return Column(
      children: [
        // Back Button
        Row(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.go('/login');
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: AppThemes.primaryGreen,
                size: 24,
              ),
            ),
            const Spacer(),
          ],
        ),
        
        const SizedBox(height: 10),
        
        // App Logo (smaller for register)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppThemes.primaryGreen,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppThemes.primaryGreen.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Welcome Text
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
            fontFamily: '-apple-system',
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Join LinguaLeap and start your learning adventure',
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

  Widget _buildRegisterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          // Username Field
          _buildUsernameField(),
          
          const SizedBox(height: 16),
          
          // Display Name Field
          _buildDisplayNameField(),
          
          const SizedBox(height: 16),
          
          // Email Field
          _buildEmailField(),
          
          const SizedBox(height: 16),
          
          // Password Field
          _buildPasswordField(),
          
          const SizedBox(height: 16),
          
          // Confirm Password Field
          _buildConfirmPasswordField(),
          
          const SizedBox(height: 20),
          
          // Message Display
          if (_message.isNotEmpty) ...[
            _buildMessageCard(),
            const SizedBox(height: 16),
          ],
          
          // Register Button
          _buildRegisterButton(),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Username',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
            fontFamily: '-apple-system',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _usernameController,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a username';
            }
            if (value.length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
              return 'Username can only contain letters, numbers, and underscore';
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
            hintText: 'Choose a unique username',
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppThemes.darkSecondaryLabel 
                : AppThemes.lightSecondaryLabel,
              fontFamily: '-apple-system',
            ),
            prefixIcon: Icon(
              Icons.person_outline,
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
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Name',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
            fontFamily: '-apple-system',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _displayNameController,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your display name';
            }
            if (value.length < 2) {
              return 'Display name must be at least 2 characters';
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
            hintText: 'Your full name',
            hintStyle: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark 
                ? AppThemes.darkSecondaryLabel 
                : AppThemes.lightSecondaryLabel,
              fontFamily: '-apple-system',
            ),
            prefixIcon: Icon(
              Icons.badge_outlined,
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
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
            fontFamily: '-apple-system',
          ),
        ),
        const SizedBox(height: 6),
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
            hintText: 'Enter your email address',
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
              vertical: 14,
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
            fontFamily: '-apple-system',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
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
            hintText: 'Create a strong password',
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
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm Password',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark 
              ? AppThemes.darkLabel 
              : AppThemes.lightLabel,
            fontFamily: '-apple-system',
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleRegister(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
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
            hintText: 'Confirm your password',
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
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
              vertical: 14,
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

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
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
              'Create Account',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: '-apple-system',
              ),
            ),
      ),
    );
  }

  Widget _buildLoginLink() {
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
            'Already have an account? ',
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
              context.go('/login');
            },
            child: Text(
              'Sign In',
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