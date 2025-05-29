import 'package:flutter/material.dart';
import 'package:gymbroo/pages/users/profile/editProfile.dart'; 

class ProfileUser extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhotoUrl;
  final String membershipStatus;

  const ProfileUser({
    super.key,
    this.userName = "Aqil Yoga Deandles",
    this.userEmail = "aqil@gmail.com",
    this.userPhotoUrl = "", // Default empty, will show placeholder
    this.membershipStatus = "Premium Membership",
  });

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  int _currentIndex = 3; // Set to profile tab

  final int remainingDays = 78;

  final List<Map<String, dynamic>> trainingList = [
    {
      'name': 'Regular Training',
      'trainer': 'Jonito Seppu',
      'time': '20:30 WIB',
      'day': 'Selasa',
      'weeksLeft': '3 week left',
      'id': 1,
    },
    {
      'name': 'Yoga Training',
      'trainer': 'Aqil Prayuni',
      'time': '20:30 WIB',
      'day': 'Senin',
      'weeksLeft': '3 week left',
      'id': 2,
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
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const DashboardUserPage())); // Ganti dengan halaman dashboard user Anda
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Dashboard Page')),
    );
  }

  void _navigateToMembershipPage() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const MembershipUserPage())); // Ganti dengan halaman membership user Anda
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Membership Page')),
    );
  }

  void _navigateToTrainingPage() {
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const TrainingUserPage())); // Ganti dengan halaman training user Anda
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Training Page')),
    );
  }

  void _navigateToProfilePage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You are already on Profile Page')),
    );
  }

  void _editProfile() {
    // Navigasi ke EditProfilePage dan kirim data pengguna saat ini
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          userName: widget.userName,
          userEmail: widget.userEmail,
          userPhotoUrl: widget.userPhotoUrl,
          membershipStatus: widget.membershipStatus,
        ),
      ),
    );
  }

  void _extendMembership() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Extend Membership functionality')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with Background Image and Profile Text
            Container(
              width: double.infinity,
              height: 120,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/gymstart.jpg'),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Content Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Profile Image
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: ClipOval(
                          child: widget.userPhotoUrl.isNotEmpty
                              ? Image.network(
                                  widget.userPhotoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                )
                              : _buildDefaultAvatar(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // User Name
                    Center(
                      child: Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // User Email
                    Center(
                      child: Text(
                        widget.userEmail,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Edit Profile Button
                    Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _editProfile, // Panggil fungsi _editProfile untuk navigasi
                          borderRadius: BorderRadius.circular(12),
                          child: const Center(
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Membership Card
                    _buildMembershipCard(),

                    const SizedBox(height: 32),

                    // Training Section
                    const Text(
                      'Training taken',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Training List
                    ...trainingList.map((training) => _buildTrainingCard(training)),

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
        size: 40,
      ),
    );
  }

  Widget _buildTrainingCard(Map<String, dynamic> training) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF007662), Color(0xFF00DCB7)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Training name and time info in same row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Training name
                Text(
                  training['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // Right side - Time info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF659B92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        training['time'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Trainer name and day in same row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Trainer name
                Text(
                  training['trainer'],
                  style: const TextStyle(
                    color: Color(0xFFE6E886),
                    fontSize: 14,
                  ),
                ),

                // Right side - Day
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF659B92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    training['day'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Weeks left aligned to right
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF659B92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        training['weeksLeft'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipCard() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/gymstart.jpg'),
          fit: BoxFit.cover,
        ),
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
              Colors.black.withOpacity(0.6),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.membershipStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00DCB7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$remainingDays\nDAYS',
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
              const Spacer(),
            ],
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