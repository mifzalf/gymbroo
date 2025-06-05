import 'package:flutter/material.dart';
import 'package:gymbroo/pages/users/membershipPage.dart'; 
import 'package:gymbroo/pages/users/profile/profilePage.dart';
import 'package:gymbroo/pages/users/training/trainingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DashboardUser extends StatefulWidget {
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

  String _currentUserName = "Loading...";
  String _currentUserEmail = "Loading...";
  String _currentUserPhotoUrl = "";
  String _currentMembershipSummary = "Loading...";

  String _membershipType = "No Membership";
  int _remainingDays = 0;
  String _membershipBackground = "assets/images/membership_bg_dummy.jpg";

  List<dynamic> _userTrainings = [];
  
  bool _isLoading = true;
  final String _baseUrl = 'http://192.168.100.8:3000/API';
  final String _userImagePathPrefix = 'http://192.168.100.8:3000/images/users/';
  final String _membershipImagePathPrefix = 'http://192.168.100.8:3000/images/memberships/';
  final String _trainingImagePathPrefix = 'http://192.168.100.8:3000/images/trainings/';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDashboardData();
    });
  }

  Future<void> _fetchDashboardData() async {
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
        Uri.parse('$_baseUrl/user/dashboard'),
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
        _showSnackBar('Dashboard data loaded successfully!', Colors.green);

      } else if (response.statusCode == 401 || response.statusCode == 403) {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
      } else {
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
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MembershipUser()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TrainingUser()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileUser()));
        break;
    }
  }
  void _navigateToTrainingDetail(int trainingId) {
    _showSnackBar('Navigate to Training Detail ID: $trainingId (Not implemented yet)', Colors.blue);
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
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUserName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentMembershipSummary,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: _currentUserPhotoUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: _currentUserPhotoUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
                                    errorWidget: (context, url, error) {
                                      print('Error loading user profile photo: $error');
                                      return _buildDefaultAvatar();
                                    },
                                  )
                                : _buildDefaultAvatar(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          _buildMembershipCard(),
                          const SizedBox(height: 24),
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