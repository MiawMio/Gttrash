import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.primaryGreen,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Logo
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Profile title
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Profile Image
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: Colors.purple.shade100,
                  child: const Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.purple,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 80),
            
            // Action Buttons Container
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Edit Button
                    _buildActionButton(
                      title: 'EDIT',
                      backgroundColor: const Color(0xFFB8E6C1),
                      onTap: () {
                        // Navigate to edit profile screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Edit Profile akan segera tersedia')),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Keluar Button
                    _buildActionButton(
                      title: 'KELUAR',
                      backgroundColor: const Color(0xFFB8E6C1),
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: const BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
                         GestureDetector(
               onTap: () {
                 Navigator.pop(context);
               },
               child: Container(
                 padding: const EdgeInsets.all(16),
                 child: const Icon(
                   Icons.home,
                   color: AppColors.grey,
                   size: 28,
                 ),
               ),
             ),
            Container(
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Icons.grid_view,
                color: AppColors.primaryGreen,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}