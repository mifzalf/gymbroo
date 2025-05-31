import 'package:flutter/material.dart';
import 'package:gymbroo/pages/users/payment/paymentTraining.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserTrainingDetailPage extends StatefulWidget {
  final int trainingId;

  const UserTrainingDetailPage({
    super.key,
    required this.trainingId,
  });

  @override
  State<UserTrainingDetailPage> createState() => _UserTrainingDetailPageState();
}

class _UserTrainingDetailPageState extends State<UserTrainingDetailPage> {
  Map<String, dynamic>? _fullTrainingDetails; // Data lengkap pelatihan dari backend
  bool _isLoadingDetails = true;
  bool _isInitiatingPayment = false;
  final String _baseUrl = 'http://localhost:3000/API'; // Ubah ke IP lokal Anda
  final String _trainingImagePathPrefix = 'http://localhost:3000/images/trainings/';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFullTrainingDetails(widget.trainingId);
    });
  }

  // Fungsi untuk mengambil detail pelatihan lengkap dari backend
  Future<void> _fetchFullTrainingDetails(int id) async {
    setState(() {
      _isLoadingDetails = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in again.', Colors.red);
        setState(() { _isLoadingDetails = false; _fullTrainingDetails = null; });
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/user/trainings/$id'), // Ini adalah RUTE USER
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // >>> PERBAIKAN DI SINI: Harapkan Map<String, dynamic> langsung <<<
        final Map<String, dynamic>? responseData = json.decode(response.body); // Langsung Map, bisa null

        if (responseData != null) { // Cek apakah data tidak null
          setState(() {
            _fullTrainingDetails = responseData;
          });
          // Log tambahan untuk memeriksa data yang diterima
          print('DEBUG (DETAIL PAGE): Fetched Data: $_fullTrainingDetails');
          if (_fullTrainingDetails!['trainer_id'] == null || _fullTrainingDetails!['trainer_username'] == null) {
             _showSnackBar('Trainer info is incomplete in fetched data. Showing default.', Colors.orange);
          }
        } else {
          _showSnackBar('Training details not found for ID: $id', Colors.orange);
          setState(() { _fullTrainingDetails = null; });
        }
        // <<< AKHIR PERBAIKAN >>>
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Unauthorized or forbidden when fetching details.', Colors.red);
        setState(() { _fullTrainingDetails = null; });
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to load training details.', Colors.red);
        setState(() { _fullTrainingDetails = null; });
      }
    } catch (e) {
      _showSnackBar('Error fetching training details: $e', Colors.red);
      print('Error fetching training details: $e');
      setState(() { _fullTrainingDetails = null; });
    } finally {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  void _confirmEnrollment() {
    if (_fullTrainingDetails == null) {
      _showSnackBar('Training data not loaded yet. Please wait or go back.', Colors.red);
      return;
    }

    final String trainingTitle = _fullTrainingDetails!['title'] ?? 'N/A';
    final int price = _fullTrainingDetails!['price'] ?? 0;
    final int totalSession = _fullTrainingDetails!['total_session'] ?? 0;

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
                Navigator.of(context).pop();
                _initiateTrainingPayment();
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

  void _initiateTrainingPayment() async {
    if (_fullTrainingDetails == null) {
      _showSnackBar('Training details not loaded. Cannot initiate payment.', Colors.red);
      return;
    }

    setState(() {
      _isInitiatingPayment = true;
    });
    _showSnackBar('Initiating payment for ${_fullTrainingDetails!['title']}...', const Color(0xFF00DCB7));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in.', Colors.red);
        setState(() { _isInitiatingPayment = false; });
        return;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/user/trainings/${_fullTrainingDetails!['id']}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String? transactionToken = responseData['token'];
        final String? redirectUrl = responseData['redirect_url'];
        final String? orderId = responseData['order_id'];

        if (transactionToken != null && orderId != null && redirectUrl != null) {
          _showSnackBar('Payment initiated successfully for ${_fullTrainingDetails!['title']}.', Colors.green);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainingPaymentPage(
                orderId: orderId,
                transactionToken: transactionToken,
                productName: _fullTrainingDetails!['title'],
                amount: _fullTrainingDetails!['price'],
                redirectUrl: redirectUrl,
              ),
            ),
          );
        } else {
          _showSnackBar('Failed to get transaction details from Midtrans.', Colors.red);
        }
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to initiate training payment.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred during payment initiation: $e', Colors.red);
      print('Error initiating training payment: $e');
    } finally {
      setState(() {
        _isInitiatingPayment = false;
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

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final String formattedPhoneNumber = phoneNumber.startsWith('0') ? '62${phoneNumber.substring(1)}' : phoneNumber;
    final Uri whatsappUri = Uri.parse('https://wa.me/$formattedPhoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      _showSnackBar('Could not launch WhatsApp. Make sure it is installed.', Colors.red);
    }
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading screen jika detail belum dimuat
    if (_isLoadingDetails) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFE8D864)),
              const SizedBox(height: 16),
              const Text('Loading training details...', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    // Tampilkan pesan jika data tidak ditemukan (misalnya, ID salah atau fetch gagal)
    if (_fullTrainingDetails == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Training Details', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF007662),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _navigateBack,
          ),
        ),
        body: const Center(
          child: Text(
            'Failed to load training details or training not found.',
            style: TextStyle(color: Colors.redAccent, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Data sudah dimuat, tampilkan UI utama
    final String? backgroundImageUrl = (_fullTrainingDetails!['background'] != null && _fullTrainingDetails!['background'] != 'default.png')
        ? _trainingImagePathPrefix + _fullTrainingDetails!['background']
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with gradient background and training name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF007662), Color(0xFF00DCB7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                image: backgroundImageUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(backgroundImageUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
                        onError: (exception, stackTrace) {
                          print('Error loading training background: $exception');
                        },
                      )
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button and title row
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _navigateBack,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _fullTrainingDetails!['title'] ?? 'Training Details',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Trainer info
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Trainer: ${_fullTrainingDetails!['trainer_username'] ?? 'N/A'}',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Program Description Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00DCB7).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFF00DCB7), size: 20),
                              SizedBox(width: 8),
                              Text('Program Description', style: TextStyle(color: Color(0xFF00DCB7), fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _fullTrainingDetails!['description'] ?? 'No description available.',
                            style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.6),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Trainer Contact Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFF00DCB7),
                            child: Icon(Icons.person, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fullTrainingDetails!['trainer_username'] ?? 'N/A',
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text('Personal Trainer', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _launchWhatsApp(_fullTrainingDetails!['trainer_whatsapp']?.replaceAll('+', '') ?? ''),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.message, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Training Schedule Details
                    Row(
                      children: [
                        // Days Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFF2D2D2D), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                const Icon(Icons.calendar_month, color: Color(0xFF00DCB7), size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  _fullTrainingDetails!['days'] ?? 'N/A',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const Text('Schedule Day', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Session Time Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFF2D2D2D), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                const Icon(Icons.schedule, color: Color(0xFF00DCB7), size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  _fullTrainingDetails!['time_start']?.substring(0, 5) ?? 'N/A',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const Text('Start Time', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Price and Total Session
                    Row(
                      children: [
                        // Total Price Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFF2D2D2D), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                const Icon(Icons.payments, color: Color(0xFF00DCB7), size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  'Rp ${_fullTrainingDetails!['price']?.toString() ?? 'N/A'}',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const Text('Total Price', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Total Session Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFF2D2D2D), borderRadius: BorderRadius.circular(12)),
                            child: Column(
                              children: [
                                const Icon(Icons.numbers, color: Color(0xFF00DCB7), size: 24),
                                const SizedBox(height: 8),
                                Text(
                                  '${_fullTrainingDetails!['total_session']?.toString() ?? 'N/A'} Sessions',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                const Text('Total Sessions', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Tombol Enroll Now
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isInitiatingPayment ? null : () => _confirmEnrollment(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8D864),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isInitiatingPayment
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text(
                                'Enroll Now',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}