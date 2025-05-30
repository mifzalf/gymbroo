import 'package:flutter/material.dart';
import 'package:gymbroo/pages/admin/memberPage.dart';
import 'package:gymbroo/pages/admin/membership/membershipPage.dart';
import 'package:gymbroo/pages/admin/trainer/trainerPage.dart';
import 'package:gymbroo/pages/admin/training/trainingPage.dart';
import 'package:http/http.dart' as http; // Import http
import 'dart:convert'; // Import json
import 'package:shared_preferences/shared_preferences.dart'; // Untuk menyimpan dan mengambil token

class dashboardAdmin extends StatefulWidget {
  final String adminName;

  const dashboardAdmin({
    super.key,
    this.adminName = "Admin", // Default admin name
  });

  @override
  State<dashboardAdmin> createState() => _dashboardAdminState();
}

class _dashboardAdminState extends State<dashboardAdmin> {
  int _currentIndex = 0;

  // Variabel untuk menyimpan data statistik
  int totalUsers = 0; // Ganti totalMembers menjadi totalUsers sesuai backend
  int totalMemberships = 0; // Ganti totalActiveMembers
  int totalTrainings = 0; // Ganti totalExpiredMembers
  bool _isLoading = true; // State untuk loading data

  // TODO: Ganti dengan URL dasar backend Anda
  final String _baseUrl = 'http://localhost:3000/API'; // Contoh: 'http://192.168.1.5:3000/API'

  @override
  void initState() {
    super.initState();
    _fetchAdminDashboardData(); // Panggil fungsi untuk mengambil data saat initState
  }

  // Fungsi untuk mengambil data dari backend
  Future<void> _fetchAdminDashboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token'); // Ambil token dari SharedPreferences

      if (token == null) {
        // Handle jika token tidak ada, mungkin redirect ke login page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication token not found. Please log in again.')),
        );
        // Contoh: Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/dashboard'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token', // Kirim token di header Authorization
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
         // Token invalid atau tidak memiliki akses
         final responseBody = json.decode(response.body);
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseBody['message'] ?? 'Unauthorized or forbidden.')),
         );
         // Redirect to login page
         // Navigator.pushReplacementNamed(context, '/login');
      }
       else {
        final responseBody = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseBody['message'] ?? 'Failed to load dashboard data.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching dashboard data: $e')),
      );
      print('Error fetching dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Cukup pop jika kita sudah di dashboard, atau push replacement jika ingin merefresh
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const dashboardAdmin()));
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MembershipPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TrainingPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TrainerPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const memberPage()),
        );
        break;
    }
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
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8D864))) // Loading indicator
                    : Column(
                        children: [
                          const SizedBox(height: 20),

                          // Statistics Cards
                          _buildStatCard(
                            'Total Users', // Diperbarui dari 'Total Member'
                            totalUsers.toString(),
                            Icons.people,
                          ),

                          const SizedBox(height: 16),

                          _buildStatCard(
                            'Memberships', // Diperbarui dari 'Total Active Member'
                            totalMemberships.toString(),
                            Icons.card_membership, // Ganti ikon jika lebih sesuai
                          ),

                          const SizedBox(height: 16),

                          _buildStatCard(
                            'Trainings Taken', // Diperbarui dari 'Total Expired Member'
                            totalTrainings.toString(),
                            Icons.fitness_center, // Ganti ikon jika lebih sesuai
                          ),

                          const Spacer(),
                        ],
                      ),
              ),
            ),

            // Bottom Navigation (tidak berubah)
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