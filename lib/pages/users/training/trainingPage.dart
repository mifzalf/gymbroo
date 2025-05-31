import 'package:flutter/material.dart';
import 'package:gymbroo/pages/users/dashboardPage.dart';
import 'package:gymbroo/pages/users/membershipPage.dart';
import 'package:gymbroo/pages/users/payment/paymentTraining.dart';
import 'package:gymbroo/pages/users/profile/profilePage.dart';
import 'package:gymbroo/pages/users/training/detailTraining.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TrainingUser extends StatefulWidget {
  final String userName;
  final String userPhotoUrl;

  const TrainingUser({
    super.key,
    this.userName = "Loading...",
    this.userPhotoUrl = "",
  });

  @override
  State<TrainingUser> createState() => _TrainingUserState();
}

class _TrainingUserState extends State<TrainingUser> {
  int _currentIndex = 2;

  List<dynamic> _trainingPrograms = []; // Data pelatihan dari backend
  bool _isLoading = true; // State untuk loading data
  final String _baseUrl = 'http://localhost:3000/API'; // Your backend URL
  final String _trainingImagePathPrefix = 'http://localhost:3000/images/trainings/'; // Prefix untuk gambar training

  @override
  void initState() {
    super.initState();
    _fetchTrainingPrograms(); // Fetch data when the page initializes
  }

  // Fungsi untuk mengambil daftar training dari backend
  Future<void> _fetchTrainingPrograms() async {
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
        Uri.parse('$_baseUrl/user/trainings'), // Endpoint GET ALL trainings
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body); // Backend mengembalikan array langsung
        setState(() {
          _trainingPrograms = fetchedData; // <<< DATA DIISI DI SINI
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to load training programs.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error fetching training programs: $e', Colors.red);
      print('Error fetching training programs: $e');
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
        // Stay on current page
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileUser()));
        break;
    }
  }

  // >>> PERUBAHAN DI SINI: Hanya meneruskan training ID <<<
  void _navigateToTrainingDetail(int trainingId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserTrainingDetailPage(
          trainingId: trainingId, // Meneruskan training ID saja
        ),
      ),
    );
  }
  // <<< AKHIR PERUBAHAN >>>

  // Fungsi untuk memicu pendaftaran pelatihan (POST request ke backend)
  void _enrollTraining(Map<String, dynamic> training) async {
    _showSnackBar('Initiating enrollment for ${training['title']}...', const Color(0xFF00DCB7));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in.', Colors.red);
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/user/trainings/${training['id']}'), // Menggunakan ID training dari backend
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          // Data ini tidak digunakan oleh rute backend Anda, tapi boleh dikirim.
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String? transactionToken = responseData['token'];
        final String? redirectUrl = responseData['redirect_url'];
        final String? orderId = responseData['order_id'];

        if (transactionToken != null && orderId != null && redirectUrl != null) {
          _showSnackBar('Payment initiated successfully for ${training['title']}.', Colors.green);
          // Navigasi ke halaman pembayaran Midtrans
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainingPaymentPage(
                orderId: orderId,
                transactionToken: transactionToken,
                productName: training['title'],
                amount: training['price'],
                redirectUrl: redirectUrl,
              ),
            ),
          );
        } else {
          _showSnackBar('Failed to get transaction details from Midtrans.', Colors.red);
        }
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to initiate training enrollment.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred during enrollment: $e', Colors.red);
      print('Error enrolling training: $e');
    }
  }

  // Fungsi konfirmasi pembayaran pelatihan (untuk TrainingUser)
  void _confirmEnrollment(Map<String, dynamic> training) {
    final String trainingTitle = training['title'] ?? 'N/A';
    final int price = training['price'] ?? 0;
    final int totalSession = training['total_session'] ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: Text(
            'Confirm Enrollment for "$trainingTitle"',
            style: const TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Price: Rp. ${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Sessions: $totalSession',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to proceed with this training enrollment?',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _enrollTraining(training); // Lanjutkan ke proses pendaftaran/pembayaran
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00DCB7),
              ),
              child: const Text('Confirm Purchase', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
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
                      const Icon(Icons.fitness_center, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'Training Program',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Choose your training program',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8D864)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          if (_trainingPrograms.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No training programs available.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            )
                          else
                            // Menggunakan _trainingPrograms (data dari backend)
                            ..._trainingPrograms.map((training) => _buildTrainingCard(training)).toList(),
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

  Widget _buildTrainingCard(Map<String, dynamic> training) {
    final String trainingTitle = training['title'] ?? 'N/A';
    final int price = training['price'] ?? 0;
    final int totalSession = training['total_session'] ?? 0;
    final String bgImageName = training['background'] ?? 'gymstart.jpg';
    final String bgImageUrl = _trainingImagePathPrefix + bgImageName;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: bgImageUrl.startsWith('http')
              ? DecorationImage(
                  image: CachedNetworkImageProvider(bgImageUrl),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                  onError: (exception, stackTrace) {
                    print('Error loading network image for ${trainingTitle}: $exception');
                  },
                )
              : const DecorationImage(
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
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trainingTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${totalSession} Sessions',
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
                        '${totalSession}\nSessions',
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
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _navigateToTrainingDetail(training['id']), // <<< PERUBAHAN DI SINI: Meneruskan ID saja
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
                        onTap: () => _confirmEnrollment(training),
                        child: Container(
                          height: 36,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00DCB7),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Text(
                              'Enroll Now',
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