import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ListSampahScreen extends StatelessWidget {
  const ListSampahScreen({super.key});

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
                // Logo
                  Container(
                    width: 60,
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
                  const SizedBox(width: 15),
                  // Title
                  const Text(
                    'List Sampah',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Waste Type Cards
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Plastik Card
                    _buildWasteCard(
                      icon: Icons.local_drink,
                      iconColor: Colors.blue.shade400,
                      title: 'Plastik',
                      price: 'Rp. 1000 Per Gram',
                      backgroundColor: const Color(0xFFD4F4DD),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Kertas Card
                    _buildWasteCard(
                      icon: Icons.description,
                      iconColor: Colors.grey.shade600,
                      title: 'Kertas',
                      price: 'Rp. 100 Per Gram',
                      backgroundColor: const Color(0xFFD4F4DD),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Kaca Card
                    _buildWasteCard(
                      icon: Icons.broken_image,
                      iconColor: Colors.lightBlue.shade300,
                      title: 'Kaca',
                      price: 'Rp. 10 Per Gram',
                      backgroundColor: const Color(0xFFD4F4DD),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Logam Card
                    _buildWasteCard(
                      icon: Icons.build,
                      iconColor: Colors.grey.shade700,
                      title: 'Logam',
                      price: 'Rp. 1 Per Gram',
                      backgroundColor: const Color(0xFFD4F4DD),
                    ),
                    
                    const Spacer(),
                  ],
                ),
              ),
            ),
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
                  color: AppColors.black,
                  size: 32,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Icons.grid_view,
                color: AppColors.primaryGreen,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String price,
    required Color backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 35,
            ),
          ),
          const SizedBox(width: 20),
          // Text content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF2D5016),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                price,
                style: const TextStyle(
                  color: Color(0xFF2D5016),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}