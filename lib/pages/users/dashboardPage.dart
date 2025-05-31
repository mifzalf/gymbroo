import 'package:flutter/material.dart';
import 'package:gymbroo/pages/users/membershipPage.dart';
import 'package:gymbroo/pages/users/profile/profilePage.dart';
import 'package:gymbroo/pages/users/training/trainingPage.dart';
import 'package:http/http.dart' as http; // Import http
import 'dart:convert'; // Import json
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:cached_network_image/cached_network_image.dart'; // Import cached_network_image

class DashboardUser extends StatefulWidget {
  // Properti ini sekarang mungkin tidak diperlukan lagi karena data akan diambil internal
  // Namun, tetap bisa dipertahankan sebagai fallback atau untuk parameter awal jika ada
  final String userName;
  final String userPhotoUrl;
  final String membershipStatus;

  const DashboardUser({
    super.key,
    this.userName = "Loading...",
    this.userPhotoUrl = "",
    this.membershipStatus = "Loading...",
  });

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  int _currentIndex = 0;

  // Data yang akan diisi dari backend
  String _currentUserName = "Loading...";
  String _currentUserPhotoUrl = "";
  String _currentMembershipStatus = "Loading..."; // Status komprehensif membership
  String _membershipType = "No Membership"; // Jenis membership
  int _remainingDays = 0; // Sisa hari membership
  String _membershipBackground = "assets/images/membership_bg_dummy.jpg"; // Background membership
  List<dynamic> _userTrainings = []; // Daftar training yang diambil user
  bool _isLoading = true; // State untuk loading keseluruhan halaman

  final String _baseUrl = 'http://localhost:3000/API'; // URL backend Anda
  final String _userImagePathPrefix = 'http://localhost:3000/images/users/'; // Prefix untuk foto profil user
  final String _membershipImagePathPrefix = 'http://localhost:3000/images/memberships/'; // Prefix untuk gambar membership

  @override
  void initState() {
    super.initState();
    _fetchDashboardData(); // Panggil fungsi untuk mengambil data saat initState
  }

  // Fungsi untuk mengambil semua data dashboard user
  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true; // Set loading true saat memulai fetch
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in again.', Colors.red);
        // Mungkin arahkan ke halaman login jika token tidak ada
        // Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/user/dashboard'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // --- Mengisi Data Profil ---
        final List<dynamic> profileData = responseData['Profile'] ?? [];
        if (profileData.isNotEmpty) {
          final userProfile = profileData[0];
          _currentUserName = userProfile['username'] ?? 'User';
          // Pastikan URL gambar profil user terbentuk dengan benar
          _currentUserPhotoUrl = (userProfile['profile_photo'] != null && userProfile['profile_photo'] != 'default.png')
              ? _userImagePathPrefix + userProfile['profile_photo']
              : ''; // Akan menampilkan avatar default jika kosong atau 'default.png'
        }

        // --- Mengisi Data Membership ---
        final List<dynamic> membershipUsersData = responseData['membershipUsers'] ?? [];
        if (membershipUsersData.isNotEmpty) {
          final userMembership = membershipUsersData[0]; // Asumsi hanya ada satu membership aktif
          _membershipType = userMembership['jenis_member'] ?? 'Active Member'; // Menggunakan 'jenis_member'
          _remainingDays = userMembership['sisa_hari_member'] ?? 0; // Menggunakan 'sisa_hari_member'
          // Pastikan URL gambar background membership terbentuk dengan benar
          _membershipBackground = (userMembership['background_member'] != null && userMembership['background_member'] != 'default.png')
              ? _membershipImagePathPrefix + userMembership['background_member']
              : "assets/images/membership_bg_dummy.jpg"; // Default asset jika null/default.png

          if (_remainingDays > 0) {
            _currentMembershipStatus = 'Active Member (${_remainingDays} days left)';
          } else {
            _currentMembershipStatus = 'Membership Expired/None';
          }
        } else {
          _currentMembershipStatus = 'No Active Membership';
          _membershipType = 'No Membership';
          _remainingDays = 0;
          _membershipBackground = "assets/images/membership_bg_dummy.jpg"; // Pastikan default jika tidak ada membership
        }

        // --- Mengisi Data Training ---
        _userTrainings = responseData['trainingUsers'] ?? [];

        setState(() {
          // UI akan diperbarui dengan data baru
        });
        _showSnackBar('Dashboard data loaded successfully!', Colors.green);

      } else if (response.statusCode == 401 || response.statusCode == 403) {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
        // Mungkin arahkan ke login jika token tidak valid
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to load dashboard data.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error fetching dashboard data: $e', Colors.red);
      print('Error fetching dashboard data: $e');
    } finally {
      setState(() {
        _isLoading = false; // Set loading false setelah fetch selesai
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) { // Pastikan widget masih ada di tree sebelum menampilkan SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  void _navigateToPage(int index) {
    if (_currentIndex == index) return; // Jangan navigasi jika sudah di halaman yang sama

    setState(() {
      _currentIndex = index;
    });

    // Menggunakan Navigator.pushReplacement untuk navigasi tab utama agar tidak menumpuk halaman
    switch (index) {
      case 0:
        // Sudah di DashboardUser, tidak perlu navigasi ulang
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MembershipUser()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TrainingUser()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileUser()),
        );
        break;
    }
  }

  void _navigateToTrainingDetail(int trainingId) {
    // TODO: Implementasi navigasi ke halaman detail training user
    _showSnackBar('Navigate to Training Detail ID: $trainingId (Not implemented yet)', Colors.blue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _isLoading // Tampilkan CircularProgressIndicator jika sedang loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFE8D864)),
              )
            : Column(
                children: [
                  // Header Section with User Info
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
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUserName, // Menggunakan data dari backend
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentMembershipStatus, // Menggunakan data dari backend
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // User Photo
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            // Menggunakan CachedNetworkImage untuk foto profil
                            child: _currentUserPhotoUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: _currentUserPhotoUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white), // Placeholder saat memuat
                                    errorWidget: (context, url, error) {
                                      print('Error loading user profile photo: $error');
                                      return _buildDefaultAvatar(); // Fallback jika error
                                    },
                                  )
                                : _buildDefaultAvatar(), // Tampilkan avatar default jika URL kosong
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),

                          // Membership Card
                          _buildMembershipCard(),

                          const SizedBox(height: 24),

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
                          if (_userTrainings.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'You have not taken any training yet.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            )
                          else
                            // Menggunakan data training dari backend
                            ..._userTrainings.map((training) => _buildTrainingCard(training)).toList(),

                          const SizedBox(height: 100), // Spasi untuk bottom navigation
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

  Widget _buildMembershipCard() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Menggunakan CachedNetworkImageProvider untuk background membership
        image: _membershipBackground.startsWith('http') // Cek apakah ini URL jaringan
            ? DecorationImage(
                image: CachedNetworkImageProvider(_membershipBackground),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                // onError: (exception, stackTrace) {
                //   // Jika NetworkImage gagal, maka _membershipBackground akan tetap pada URL yang gagal.
                //   // Anda bisa menambahkan logika fallback di sini jika ingin mengubah gambar ke asset default
                //   // tapi itu akan mengubah state global _membershipBackground.
                //   // Untuk DecorationImage, NetworkImageProvider akan menampilkan "broken image" jika gagal
                //   // kecuali Anda menangani errornya lebih lanjut di Image.network widget langsung.
                //   // Saat ini, fallback ke gradient yang sudah ada.
                //   print('Error loading membership background: $exception');
                // },
              )
            : DecorationImage( // Jika bukan URL jaringan, anggap sebagai asset
                image: AssetImage(_membershipBackground),
                fit: BoxFit.cover,
              ),
        gradient: const LinearGradient( // Fallback gradient jika tidak ada gambar sama sekali atau gagal
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
                    _membershipType, // Menggunakan data dari backend
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00DCB7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$_remainingDays\nDAYS', // Menggunakan data dari backend
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
              Container(
                width: double.infinity,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Text(
                    'Extend Now',
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
    );
  }

  Widget _buildTrainingCard(Map<String, dynamic> training) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _navigateToTrainingDetail(training['id']), // Asumsi ada 'id' di data training
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
                    training['jenis_training'] ?? 'N/A', // Menggunakan 'jenis_training' dari backend
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Right side - Time info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          training['jam_training']?.substring(0, 5) ?? 'N/A', // Menggunakan 'jam_training' dari backend
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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
                    training['nama_trainer'] ?? 'N/A', // Menggunakan 'nama_trainer' dari backend
                    style: const TextStyle(
                      color: Color(0xFFE6E886),
                      fontSize: 16,
                    ),
                  ),
                  // Right side - Day
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF659B92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      training['hari_mulai'] ?? 'N/A', // Menggunakan 'hari_mulai' dari backend
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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
                          Icons.schedule,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${training['sisa_pertemuan'] ?? 'N/A'} sessions left', // Menggunakan 'sisa_pertemuan' dari backend
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
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