import 'package:flutter/material.dart';
import 'package:gymbroo/pages/users/dashboardPage.dart';
import 'package:gymbroo/pages/users/membershipPage.dart';
import 'package:gymbroo/pages/users/profile/editProfile.dart';
import 'package:gymbroo/pages/users/training/trainingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gymbroo/pages/startPages.dart'; 

class ProfileUser extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhotoUrl;
  final String membershipStatus;

  const ProfileUser({
    super.key,
    this.userName = "Loading...",
    this.userEmail = "Loading...",
    this.userPhotoUrl = "",
    this.membershipStatus = "Loading...",
  });

  @override
  State<ProfileUser> createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  int _currentIndex = 3;

  String _currentUserName = "Loading...";
  String _currentUserEmail = "Loading...";
  String _currentUserPhotoUrl = "";
  String _currentMembershipSummary = "Loading...";

  String _membershipType = "No Membership";
  int _remainingDays = 0;
  String _membershipBackground = "assets/images/membership_bg_dummy.jpg";

  List<dynamic> _userTrainings = [];
  
  bool _isLoading = true; 
  bool _isLoggingOut = false;
  final String _baseUrl = 'http://192.168.100.8:3000/API'; 
  final String _userImagePathPrefix = 'http://192.168.100.8:3000/images/users/';
  final String _membershipImagePathPrefix = 'http://192.168.100.8:3000/images/memberships/';
  final String _trainingImagePathPrefix = 'http://192.168.100.8:3000/images/trainings/';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProfileData();
    });
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in again.', Colors.red);
        setState(() { _isLoading = false; });
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/user/profile'), 
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        final List<dynamic> profileData = responseData['Profile'] ?? [];
        if (profileData.isNotEmpty) {
          final userProfile = profileData[0];
          _currentUserName = userProfile['username'] ?? 'N/A';
          _currentUserEmail = userProfile['email'] ?? 'N/A';
          _currentUserPhotoUrl = (userProfile['profile_photo'] != null && userProfile['profile_photo'] != 'default.png')
              ? _userImagePathPrefix + userProfile['profile_photo']
              : '';
        }

        final List<dynamic> membershipUsersData = responseData['membershipUsers'] ?? [];
        if (membershipUsersData.isNotEmpty) {
          final userMembership = membershipUsersData[0];
          _membershipType = userMembership['jenis_member'] ?? 'No Membership Type';
          _remainingDays = userMembership['sisa_hari_member'] ?? 0;
          _membershipBackground = (userMembership['background_member'] != null && userMembership['background_member'] != 'default.png')
              ? _membershipImagePathPrefix + userMembership['background_member']
              : "assets/images/membership_bg_dummy.jpg";
          
          if (_remainingDays > 0) {
            _currentMembershipSummary = 'Active Member (${_remainingDays} days left)';
          } else {
            _currentMembershipSummary = 'Membership Expired/None';
          }
        } else {
          _currentMembershipSummary = 'No Active Membership';
          _membershipType = 'No Membership';
          _remainingDays = 0;
          _membershipBackground = "assets/images/membership_bg_dummy.jpg";
        }

        _userTrainings = responseData['trainingUsers'] ?? [];
        
        setState(() {
        });
        _showSnackBar('Profile data loaded successfully!', Colors.green);

      } else if (response.statusCode == 401 || response.statusCode == 403) {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to load profile data.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error fetching profile data: $e', Colors.red);
      print('Error fetching profile data: $e');
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardUser()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MembershipUser()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TrainingUser()));
        break;
      case 3:
        break;
    }
  }

  void _editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          userName: _currentUserName,
          userEmail: _currentUserEmail,
          userPhotoUrl: _currentUserPhotoUrl,
          membershipStatus: _currentMembershipSummary,
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text('Profile Options', style: TextStyle(color: Colors.white)),
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
        // Kirim request logout ke backend
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
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row( 
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Profile',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert, color: Colors.white, size: 28),
                                onPressed: _showOptionsMenu,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                              ),
                              child: ClipOval(
                                child: _currentUserPhotoUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: _currentUserPhotoUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                                        errorWidget: (context, url, error) {
                                          print('Error loading user profile photo: $error');
                                          return _buildDefaultAvatar(40);
                                        },
                                      )
                                    : _buildDefaultAvatar(40),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Center(
                            child: Text(
                              _currentUserName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Center(
                            child: Text(
                              _currentUserEmail,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

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
                                onTap: _editProfile,
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

                          _buildMembershipCard(),

                          const SizedBox(height: 32),

                          const Text(
                            'Training taken',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

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
                            ..._userTrainings.map((training) => _buildTrainingCard(training)).toList(),

                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),

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

  Widget _buildDefaultAvatar(double size) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF007662), Color(0xFF00DCB7)],
        ),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: size,
      ),
    );
  }

  Widget _buildMembershipCard() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: _membershipBackground.startsWith('http')
            ? DecorationImage(
                image: CachedNetworkImageProvider(_membershipBackground),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                onError: (exception, stackTrace) {
                  print('Error loading membership background: $exception');
                  if (mounted) {
                    setState(() {
                      _membershipBackground = "assets/images/membership_bg_dummy.jpg";
                    });
                  }
                },
              )
            : DecorationImage(
                image: AssetImage(_membershipBackground),
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
                    _membershipType,
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
                      '$_remainingDays\nDAYS',
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MembershipUser()),
                  );
                },
                child: Container(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrainingCard(Map<String, dynamic> training) {
    final String trainingTitle = training['jenis_training'] ?? 'N/A';
    final String trainerName = training['nama_trainer'] ?? 'N/A';
    final String timeStart = training['jam_training']?.substring(0, 5) ?? 'N/A';
    final String days = training['hari_mulai'] ?? 'N/A';
    final int sessionsLeft = training['sisa_pertemuan'] ?? 0;
    final String bgImageName = training['background_training'] ?? 'gymstart.jpg';
    final String bgImageUrl = _trainingImagePathPrefix + bgImageName;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trainingTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                        timeStart,
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trainerName,
                  style: const TextStyle(
                    color: Color(0xFFE6E886),
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF659B92),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    days,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

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
                        '$sessionsLeft sessions left',
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