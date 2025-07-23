import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';
import '../utils/validators.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: _nameController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.loginFailed}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      // Pastikan resizeToAvoidBottomInset diatur ke true (default)
      // Ini memungkinkan Scaffold untuk menyesuaikan ukurannya saat keyboard muncul.
      resizeToAvoidBottomInset: true, 
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Top section with green background and logo
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: const Center(
                    child: AppLogo(size: 100),
                  ),
                ),
              ),
              
              // Bottom section with login form
              Expanded(
                flex: 3,
                child: SingleChildScrollView( // <--- Tambahkan SingleChildScrollView di sini
                  padding: const EdgeInsets.all(32), // Pindahkan padding ke SingleChildScrollView
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Login title
                      const Text(
                        AppStrings.login,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Subtitle
                      const Text(
                        AppStrings.signIn,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.grey,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Name/Email field
                      CustomTextField(
                        label: AppStrings.email,
                        hintText: 'Masukkan Email',
                        controller: _nameController,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Password field
                      CustomTextField(
                        label: AppStrings.password,
                        hintText: '******',
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        validator: Validators.validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Login button
                      CustomButton(
                        text: AppStrings.logIn,
                        onPressed: _login,
                        isLoading: _isLoading,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Register link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            AppStrings.signupHere,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Tambahkan SizedBox di bagian bawah untuk memberikan sedikit ruang ekstra
                      // agar konten tidak terlalu mepet ke bawah saat digulir
                      const SizedBox(height: 20), 
                    ],
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
