import 'package:flutter/material.dart';
import 'package:gymbroo/pages/users/profile/dashboardPage.dart';
import 'package:gymbroo/pages/users/profile/profilePage.dart';
import 'package:gymbroo/pages/users/training/trainingPage.dart';

class MembershipUser extends StatefulWidget {
  final String userName;
  final String userPhotoUrl;
  final String currentMembershipStatus;
  
  const MembershipUser({
    super.key,
    this.userName = "Rahadya Suset",
    this.userPhotoUrl = "",
    this.currentMembershipStatus = "Active Member",
  });

  @override
  State<MembershipUser> createState() => _MembershipUserState();
}

class _MembershipUserState extends State<MembershipUser> {
  int _currentIndex = 1; // Set to membership tab

  // Membership options data
  final List<Map<String, dynamic>> membershipOptions = [
    {
      'type': 'Premium',
      'subtitle': 'Membership',
      'price': 'Rp.295.000',
      'days': 90,
      'color': const Color(0xFF00DCB7),
      'bgImage': 'assets/images/premium_bg.jpg',
      'features': [
        'Access to all premium equipment',
        'Personal trainer sessions',
        'Nutrition consultation',
        'Priority booking',
        'Exclusive classes'
      ],
    },
    {
      'type': 'Standard',
      'subtitle': 'Membership',
      'price': 'Rp.199.000',
      'days': 60,
      'color': const Color(0xFF007662),
      'bgImage': 'assets/images/standard_bg.jpg',
      'features': [
        'Access to standard equipment',
        'Group training sessions',
        'Basic nutrition guide',
        'Regular booking',
        'Standard classes'
      ],
    },
    {
      'type': 'Basic',
      'subtitle': 'Membership',
      'price': 'Rp.100.000',
      'days': 30,
      'color': const Color(0xFF6B7280),
      'bgImage': 'assets/images/basic_bg.jpg',
      'features': [
        'Access to basic equipment',
        'Limited training sessions',
        'Basic facilities',
        'Standard booking',
        'Basic classes'
      ],
    },
  ];

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        _navigateToDashboardPage();
        break;
      case 1:
        _navigateToMembershipPage();
        break;
      case 2:
        _navigateToTrainingPage();
        break;
      case 3:
        _navigateToProfilePage();
        break;
    }
  }
  
  void _navigateToDashboardPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DashboardUser()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Dashboard Page')),
    );
  }

  void _navigateToMembershipPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MembershipUser()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Membership Page')),
    );
  }

  void _navigateToTrainingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainingUser()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Training Page')),
    );
  }

  void _navigateToProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileUser()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Profile Page')),
    );
  }

  void _selectMembership(Map<String, dynamic> membership) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: Text(
            'Select ${membership['type']} Membership',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price: ${membership['price']}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${membership['days']} days',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Features:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...membership['features'].map<Widget>((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check, color: Color(0xFF00DCB7), size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processMembershipPurchase(membership);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00DCB7),
              ),
              child: const Text('Purchase', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _processMembershipPurchase(Map<String, dynamic> membership) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing ${membership['type']} membership purchase...'),
        backgroundColor: const Color(0xFF00DCB7),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF007662), Color(0xFF00DCB7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.card_membership,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Membership type',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your perfect plan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Membership Cards
                    ...membershipOptions.map((membership) => _buildMembershipCard(membership)),
                    
                    const SizedBox(height: 100), // Space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bottom Navigation
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(
              icon: Icons.home,
              index: 0,
              isActive: _currentIndex == 0,
            ),
            _buildNavItem(
              icon: Icons.card_membership,
              index: 1,
              isActive: _currentIndex == 1,
            ),
            _buildNavItem(
              icon: Icons.fitness_center,
              index: 2,
              isActive: _currentIndex == 2,
            ),
            _buildNavItem(
              icon: Icons.person,
              index: 3,
              isActive: _currentIndex == 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF007662), Color(0xFF00DCB7)],
        ),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  Widget _buildMembershipCard(Map<String, dynamic> membership) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: () => _selectMembership(membership),
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Use same background image as dashboard membership card
            image: const DecorationImage(
              image: AssetImage('assets/images/gymstart.jpg'),
              fit: BoxFit.cover,
            ),
            // Fallback gradient if image is not available
            gradient: const LinearGradient(
              colors: [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with membership type and days
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            membership['type'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            membership['subtitle'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00DCB7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${membership['days']}\nDAYS',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Price
                  Text(
                    membership['price'],
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Get Started Button - all yellow
                  Container(
                    width: double.infinity,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _navigateToPage(index),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive 
              ? const Color(0xFF00B894) 
              : const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}