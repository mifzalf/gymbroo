import 'package:flutter/material.dart';
import 'package:gymbroo/pages/users/dashboardPage.dart';
import 'package:gymbroo/pages/users/payment/paymentMembership.dart';
import 'package:gymbroo/pages/users/profile/profilePage.dart';
import 'package:gymbroo/pages/users/training/trainingPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class MembershipUser extends StatefulWidget {
  final String userName;
  final String userPhotoUrl;
  final String currentMembershipStatus;

  const MembershipUser({
    super.key,
    this.userName = "Loading...",
    this.userPhotoUrl = "",
    this.currentMembershipStatus = "Loading...",
  });

  @override
  State<MembershipUser> createState() => _MembershipUserState();
}

class _MembershipUserState extends State<MembershipUser> {
  int _currentIndex = 1;

  List<dynamic> _membershipOptions = [];
  bool _isLoading = true;
  final String _baseUrl = 'http://localhost:3000/API';
  final String _membershipImagePathPrefix = 'http://localhost:3000/images/memberships/';

  @override
  void initState() {
    super.initState();
    _fetchMembershipOptions();
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  Future<void> _fetchMembershipOptions() async {
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
        Uri.parse('$_baseUrl/user/memberships'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _membershipOptions = responseData['memberships'] ?? [];
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to load membership options.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error fetching membership options: $e', Colors.red);
      print('Error fetching membership options: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const TrainingUser()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileUser()));
        break;
    }
  }

  void _selectMembership(Map<String, dynamic> membership) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: Text(
            'Select ${membership['membership_type']} Membership',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price: Rp. ${membership['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Duration: ${membership['membership_duration']} Months',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Features:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...[
                'Access to gym facilities',
                'Basic classes',
                'Locker access',
                'Shower facilities',
                'Towel service',
              ].map<Widget>((feature) => Padding(
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

  void _processMembershipPurchase(Map<String, dynamic> membership) async {
    _showSnackBar('Initiating payment for ${membership['membership_type']}...', const Color(0xFF00DCB7));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in.', Colors.red);
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/user/memberships/${membership['id']}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String? transactionToken = responseData['token'];
        final String? redirectUrl = responseData['redirect_url'];
        final String? orderId = responseData['order_id'];

        if (transactionToken != null && orderId != null && redirectUrl != null) {
          Navigator.of(context).pop(); 
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MembershipPaymentPage(
                orderId: orderId,
                transactionToken: transactionToken,
                productName: membership['membership_type'],
                amount: membership['price'],
                redirectUrl: redirectUrl,
              ),
            ),
          );
        } else {
          _showSnackBar('Failed to get transaction token, order ID, or redirect URL from Midtrans.', Colors.red);
        }
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to initiate payment.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred during payment initiation: $e', Colors.red);
      print('Error initiating payment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.card_membership, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Membership Type',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your perfect plan',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8D864)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          if (_membershipOptions.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No membership options available.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            )
                          else
                            ..._membershipOptions.map((membership) => _buildMembershipCard(membership)).toList(),
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
            _buildNavItem(icon: Icons.home, index: 0, isActive: _currentIndex == 0),
            _buildNavItem(icon: Icons.card_membership, index: 1, isActive: _currentIndex == 1),
            _buildNavItem(icon: Icons.fitness_center, index: 2, isActive: _currentIndex == 2),
            _buildNavItem(icon: Icons.person, index: 3, isActive: _currentIndex == 3),
          ],
        ),
      ),
    );
  }

  Widget _buildMembershipCard(Map<String, dynamic> membership) {
    final String membershipType = membership['membership_type'] ?? 'N/A';
    final int price = membership['price'] ?? 0;
    final int durationMonths = membership['membership_duration'] ?? 0;
    final String bgImageName = membership['background'] ?? 'gymstart.jpg';
    final String bgImageUrl = _membershipImagePathPrefix + bgImageName;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: GestureDetector(
        onTap: () => _selectMembership(membership),
        child: Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: bgImageUrl.startsWith('http')
                ? DecorationImage(
                    image: NetworkImage(bgImageUrl),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
                    onError: (exception, stackTrace) {
                      print('Error loading network image for ${membershipType}: $exception');
                    },
                  )
                : const DecorationImage(
                    image: AssetImage('assets/images/membership_bg_dummy.jpg'),
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
                colors: [Colors.black.withOpacity(0.3), Colors.transparent],
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            membershipType,
                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            'Membership',
                            style: TextStyle(color: Colors.white70, fontSize: 16),
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
                          '$durationMonths\nMONTHS',
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
                  Text(
                    'Rp. ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                    style: const TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.bold),
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
                        'Get Started',
                        style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
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