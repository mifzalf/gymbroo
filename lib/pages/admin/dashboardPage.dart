import 'package:flutter/material.dart';
import 'package:gymbroo/pages/admin/memberPage.dart';
import 'package:gymbroo/pages/admin/membership/membershipPage.dart';
import 'package:gymbroo/pages/admin/trainer/trainerPage.dart';
import 'package:gymbroo/pages/admin/training/trainingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gymbroo/pages/startPages.dart';

class dashboardAdmin extends StatefulWidget {
  final String adminName;
  
  const dashboardAdmin({
    super.key,
    this.adminName = "Admin", 
  });

  @override
  State<dashboardAdmin> createState() => _dashboardAdminState();
}

class _dashboardAdminState extends State<dashboardAdmin> {
  int _currentIndex = 0;

  int totalUsers = 0;
  int totalMemberships = 0;
  int totalTrainings = 0;
  bool _isLoading = true; 
  bool _isLoggingOut = false; 
  final String _baseUrl = 'http://192.168.100.8:3000/API';

  @override
  void initState() {
    super.initState();
    _fetchAdminDashboardData(); 
  }

  Future<void> _fetchAdminDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in again.', Colors.red);
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/dashboard'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> rows = responseData['rows'];

        if (rows.isNotEmpty) {
          setState(() {
            totalUsers = rows[0]['users'] ?? 0;
            totalMemberships = rows[0]['user_memberships'] ?? 0;
            totalTrainings = rows[0]['user_trainings'] ?? 0;
          });
        }
        print('Dashboard data fetched: $responseData');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
          final responseBody = json.decode(response.body);
          _showSnackBar(responseBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
      }
      else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to load dashboard data.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error fetching dashboard data: $e', Colors.red);
      print('Error fetching dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  void _navigateToPage(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on DashboardAdmin
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MembershipPage()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TrainingPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TrainerPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const memberPage()),
        );
        break;
    }
  }

  void _showOptionsMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text('Admin Options', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop(); 
                  _confirmLogout(); 
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text('Confirm Logout', style: TextStyle(color: Colors.white)),
          content: const Text('Are you sure you want to log out?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: _isLoggingOut ? null : () { 
                Navigator.of(context).pop(); 
                _performLogout(); 
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: _isLoggingOut
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    setState(() {
      _isLoggingOut = true; 
    });
    _showSnackBar('Logging out...', Colors.orange);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('No token found. Already logged out or session expired.', Colors.green);
      } else {
        final response = await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token', 
          },
        );

        if (response.statusCode == 200) {
          _showSnackBar('Logout successful!', Colors.green);
        } else {
          final responseBody = json.decode(response.body);
          _showSnackBar(responseBody['message'] ?? 'Logout failed. Please try again.', Colors.red);
        }
      }

      await prefs.remove('token');
      await prefs.remove('userType');
      print('Token and userType removed from SharedPreferences.');

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const StartPage()),
        (Route<dynamic> route) => false,
      );

    } catch (e) {
      _showSnackBar('An error occurred during logout: $e', Colors.red);
      print('Error logout: $e');
    } finally {
      setState(() {
        _isLoggingOut = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFE8D864)),
              )
            : Column(
                children: [
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.adminName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Admin',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                          onPressed: _showOptionsMenu, 
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),    
                          _buildStatCard(
                            'Total Users',
                            totalUsers.toString(),
                            Icons.people,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildStatCard(
                            'Memberships',
                            totalMemberships.toString(),
                            Icons.card_membership,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          _buildStatCard(
                            'Trainings Taken',
                            totalTrainings.toString(),
                            Icons.fitness_center,
                          ),
                          
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  Container(
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
                          icon: Icons.sports_martial_arts,
                          index: 3,
                          isActive: _currentIndex == 3,
                        ),
                        _buildNavItem(
                          icon: Icons.person,
                          index: 4,
                          isActive: _currentIndex == 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF007662), Color(0xFF00DCB7)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
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
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
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