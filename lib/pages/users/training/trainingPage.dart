import 'package:flutter/material.dart';
import 'package:gymbroo/pages/users/membershipPage.dart';
import 'package:gymbroo/pages/users/profile/dashboardPage.dart';
import 'package:gymbroo/pages/users/profile/profilePage.dart';
import 'package:gymbroo/pages/users/training/detailTraining.dart';

class TrainingUser extends StatefulWidget {
  final String userName;
  final String userPhotoUrl;
  
  const TrainingUser({
    super.key,
    this.userName = "Rahadya Suset",
    this.userPhotoUrl = "",
  });

  @override
  State<TrainingUser> createState() => _TrainingUserState();
}

class _TrainingUserState extends State<TrainingUser> {
  int _currentIndex = 2; // Set to training tab

  // Training programs data
  final List<Map<String, dynamic>> trainingPrograms = [
    {
      'name': 'Yoga Training',
      'subtitle': 'Class',
      'price': 'Rp.295.000',
      'duration': 4,
      'description': 'Improve flexibility, strength, and mental wellness through guided yoga sessions',
      'features': [
        'Professional yoga instructor',
        'Beginner to advanced levels',
        'Meditation sessions included',
        'Flexible scheduling',
        '4 weeks intensive program'
      ],
    },
    {
      'name': 'Weight Lost',
      'subtitle': 'Training',
      'price': 'Rp.295.000',
      'duration': 4,
      'description': 'Structured weight loss program with personalized diet and exercise plan',
      'features': [
        'Personal trainer guidance',
        'Customized meal plans',
        'Progress tracking',
        'Cardio & strength training',
        '4 weeks transformation'
      ],
    },
    {
      'name': 'Body Building',
      'subtitle': 'Training',
      'price': 'Rp.295.000',
      'duration': 4,
      'description': 'Intensive muscle building program for strength and physique development',
      'features': [
        'Expert bodybuilding coach',
        'Progressive overload training',
        'Nutrition for muscle gain',
        'Supplement guidance',
        '4 weeks muscle building'
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

  void _navigateToTrainingDetail(Map<String, dynamic> trainingData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserTrainingDetailPage(
          trainingData: trainingData,
        ),
      ),
    );
  }

  void _enrollTraining(Map<String, dynamic> training) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Enrolling in ${training['name']} ${training['subtitle']}...'),
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
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Training Program',
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
                    'Choose your training program',
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
                    
                    // Training Program Cards
                    ...trainingPrograms.map((training) => _buildTrainingCard(training)),
                    
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

  Widget _buildTrainingCard(Map<String, dynamic> training) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Use same background image as membership cards
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
                Colors.black.withOpacity(0.4),
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
                // Header row with training name and duration
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            training['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            training['subtitle'],
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00DCB7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${training['duration']}\nWeek',
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
                  training['price'],
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const Spacer(),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToTrainingDetail(training),
                        child: Container(
                          height: 36,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Text(
                              'Read More',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _enrollTraining(training),
                        child: Container(
                          height: 36,
                          margin: const EdgeInsets.only(left: 8),
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
                      ),
                    ),
                  ],
                ),
              ],
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