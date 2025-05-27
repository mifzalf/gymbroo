import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class dashboardUsers extends StatefulWidget {
  const dashboardUsers({super.key});

  @override
  State<dashboardUsers> createState() => _dashboardUsersState();
}

class _dashboardUsersState extends State<dashboardUsers> {
  String? userToken;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('auth_token');
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/login', 
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF007662),
        title: const Text(
          'GymBroo Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF007662),
                      const Color(0xFF007662).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: Color(0xFFE8D864),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ready for your workout?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Token: ${userToken?.substring(0, 20) ?? 'Loading...'}...',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Quick Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Workouts', '12', Icons.fitness_center),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard('Hours', '24', Icons.access_time),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Menu Options
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuTile(
                      'Start Workout',
                      'Begin your training session',
                      Icons.play_arrow,
                      const Color(0xFFE8D864),
                      () {
                        print('Navigate to Start Workout');
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuTile(
                      'My Programs',
                      'View your training programs',
                      Icons.list_alt,
                      const Color(0xFF007662),
                      () {
                        print('Navigate to My Programs');
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuTile(
                      'Progress Tracking',
                      'Check your fitness progress',
                      Icons.trending_up,
                      const Color(0xFFE8D864),
                      () {
                        print('Navigate to Progress Tracking');
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildMenuTile(
                      'Membership',
                      'View membership details',
                      Icons.card_membership,
                      const Color(0xFF007662),
                      () {
                        print('Navigate to Membership');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFE8D864),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: color == const Color(0xFFE8D864) ? Colors.black : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}