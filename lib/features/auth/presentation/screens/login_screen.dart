import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/user/providers/user_providers.dart';
import 'package:local_auth/local_auth.dart'; // New import
import 'package:flutter/services.dart'; // New import for PlatformException
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart'; // New import for UserEntity
import 'package:shared_preferences/shared_preferences.dart'; // New import for SharedPreferences

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  final LocalAuthentication _localAuth = LocalAuthentication(); // New
  bool _canCheckBiometrics = false; // New
  bool _isBiometricSupported = false; // New
  List<BiometricType> _availableBiometrics = []; // New

  @override
  void initState() {
    super.initState();
    _checkBiometrics(); // Call check biometrics on init
    _loadLastLoggedInUsername(); // Load last logged in username

    // Pre-populate username if biometrics enabled for the user
    final user = ref.read(authProvider).user;
    if (user != null && user.biometricsEnabled) {
      _usernameController.text = user.username;
    }
  }

  Future<void> _loadLastLoggedInUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLoggedInUsername = prefs.getString('last_logged_in_username');
    if (lastLoggedInUsername != null) {
      _usernameController.text = lastLoggedInUsername;
    }
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });

    late bool isBiometricSupported;
    try {
      isBiometricSupported = await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      isBiometricSupported = false;
      print(e);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _isBiometricSupported = isBiometricSupported;
    });

    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    print('[_authenticateWithBiometrics] - Starting biometric authentication.');
    bool authenticated = false;
    try {
      authenticated = await _localAuth.authenticate(
        localizedReason: 'Scan your fingerprint or face to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      print('[_authenticateWithBiometrics] - Authentication result: $authenticated');
    } on PlatformException catch (e) {
      print('[_authenticateWithBiometrics] - PlatformException: $e');
      if (e.code == 'NotEnrolled') {
        AppUtils.showSnackBar(context, message: 'No biometrics enrolled. Please enroll biometrics in your device settings.');
      } else if (e.code == 'PasscodeNotSet') {
        AppUtils.showSnackBar(context, message: 'Please set a passcode in your device settings.');
      } else if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        AppUtils.showSnackBar(context, message: 'Biometrics are locked. Please use your passcode to unlock.');
      }
    }
    if (!mounted) {
      print('[_authenticateWithBiometrics] - Widget not mounted after authentication.');
      return;
    }

    if (authenticated) {
      print('[_authenticateWithBiometrics] - Biometric authentication successful. Attempting to update auth state.');
      AppUtils.showSnackBar(context, message: 'Biometric authentication successful!');
      // Call the new biometric login method
      await ref.read(authProvider.notifier).loginWithBiometrics(
        UserEntity(id: 0, username: _usernameController.text, biometricsEnabled: true),
      );

      if (!mounted) {
        print('[_authenticateWithBiometrics] - Widget not mounted after auth state update.');
        return;
      }
      print('[_authenticateWithBiometrics] - Navigating to: ${AppConstants.homeRoute}');
      context.go(AppConstants.homeRoute);
    } else {
      print('[_authenticateWithBiometrics] - Biometric authentication failed.');
      AppUtils.showSnackBar(context, message: 'Biometric authentication failed.');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      // Close keyboard
      FocusScope.of(context).unfocus();
      
      // Get email and password
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      
      // Call login method from auth provider
      await ref.read(authProvider.notifier).login(username: username, password: password);

      if (!mounted) return;
      
      // Check if login was successful
      final authState = ref.read(authProvider);
      if (authState.errorMessage != null) {
        // Show error message if login failed
        if (context.mounted) {
          AppUtils.showSnackBar(
            context,
            message: authState.errorMessage!,
            backgroundColor: Theme.of(context).colorScheme.error,
          );
        }
      } else {
        // Login successful, save username for future biometric logins
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_logged_in_username', username);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state
    final authState = ref.watch(authProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.flutter_dash,
                    size: 100,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter your username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Implement forgot password
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Log In'),
                  ),
                  const SizedBox(height: 16),
                  if (_canCheckBiometrics && _isBiometricSupported && _availableBiometrics.isNotEmpty)
                    ElevatedButton(
                      onPressed: _authenticateWithBiometrics,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      ),
                      child: const Text('Login with Biometrics'),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(deleteAllUsersProvider)(NoParams());
                      if (context.mounted) {
                        AppUtils.showSnackBar(
                          context,
                          message: 'All users deleted',
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Delete All Users (DEBUG)'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.go(AppConstants.registerRoute);
                        },
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
