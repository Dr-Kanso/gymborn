import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../components/custom_button.dart';
import '../../themes/theme.dart';

enum AuthMode { signIn, signUp }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.signIn;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
    'displayName': '',
  };
  bool _isPasswordVisible = false;
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.signIn) {
      setState(() {
        _authMode = AuthMode.signUp;
      });
      _animationController.forward();
    } else {
      setState(() {
        _authMode = AuthMode.signIn;
      });
      _animationController.reverse();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_authMode == AuthMode.signIn) {
      await authProvider.signIn(_authData['email']!, _authData['password']!);
    } else {
      await authProvider.register(
        _authData['email']!,
        _authData['password']!,
        _authData['displayName']!,
      );
    }

    // Check if the widget is still mounted before using the BuildContext
    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Column(
            children: [
              // Top decorative area with logo
              Container(
                height: size.height * 0.35,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [kPrimaryColor, kSecondaryColor],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Replace with actual logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          size: 60,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'GYMBORN',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'Your Fitness Journey Begins',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withAlpha((0.8 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Auth form
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          _authMode == AuthMode.signIn
                              ? 'Sign In'
                              : 'Create Account',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _authMode == AuthMode.signIn
                              ? 'Welcome back! Please sign in to continue'
                              : 'Create an account to start your fitness journey',
                          style: TextStyle(
                            fontSize: 14,
                            color: kLightTextColor,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Display Name field (only in SignUp)
                        if (_authMode == AuthMode.signUp)
                          FadeTransition(
                            opacity: _opacityAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Display Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _authData['displayName'] = value ?? '';
                                },
                              ),
                            ),
                          ),
                        if (_authMode == AuthMode.signUp)
                          const SizedBox(height: 16),

                        // Email field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _authData['email'] = value ?? '';
                          },
                        ),
                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          obscureText: !_isPasswordVisible,
                          controller: _passwordController,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _authData['password'] = value ?? '';
                          },
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password field (only in SignUp)
                        if (_authMode == AuthMode.signUp)
                          FadeTransition(
                            opacity: _opacityAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Confirm Password',
                                  prefixIcon: Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                obscureText: true,
                                validator:
                                    _authMode == AuthMode.signUp
                                        ? (value) {
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match!';
                                          }
                                          return null;
                                        }
                                        : null,
                              ),
                            ),
                          ),

                        const Spacer(),

                        // Submit button
                        CustomButton(
                          text:
                              _authMode == AuthMode.signIn
                                  ? 'Sign In'
                                  : 'Sign Up',
                          onPressed: _submit,
                          isLoading: authProvider.isLoading,
                          isFullWidth: true,
                        ),
                        const SizedBox(height: 16),

                        // Switch auth mode button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _authMode == AuthMode.signIn
                                  ? 'Don\'t have an account?'
                                  : 'Already have an account?',
                              style: TextStyle(color: kLightTextColor),
                            ),
                            TextButton(
                              onPressed: _switchAuthMode,
                              child: Text(
                                _authMode == AuthMode.signIn
                                    ? 'Sign Up'
                                    : 'Sign In',
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
