import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TrainingDetailPage extends StatefulWidget {
  final Map<String, dynamic> trainingData;

  const TrainingDetailPage({
    super.key,
    required this.trainingData,
  });

  @override
  State<TrainingDetailPage> createState() => _TrainingDetailPageState();
}

class _TrainingDetailPageState extends State<TrainingDetailPage> {
  Map<String, dynamic> _trainerInfo = {};
  bool _isLoadingTrainer = true;
  final String _baseUrl = 'http://localhost:3000/API';
  final String _imagePathPrefix = 'http://localhost:3000/images/trainings/';

  @override
  void initState() {
    super.initState();
    // Fetch trainer details based on ID
    if (widget.trainingData['trainer_id'] != null) {
      _fetchTrainerDetails(widget.trainingData['trainer_id']);
    } else {
      setState(() {
        _isLoadingTrainer = false;
        _trainerInfo = {'username': 'N/A', 'whatsapp': ''}; // Handle case where trainer_id is null
      });
    }
  }

  Future<void> _fetchTrainerDetails(int trainerId) async {
    setState(() {
      _isLoadingTrainer = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in again.', Colors.red);
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/trainers/$trainerId'), // Assuming this endpoint exists and returns full trainer data
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _trainerInfo = responseData['data'] ?? {};
        });
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to load trainer details.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error fetching trainer details: $e', Colors.red);
      print('Error fetching trainer details: $e');
    } finally {
      setState(() {
        _isLoadingTrainer = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
    final String? backgroundImageUrl = (widget.trainingData['background'] != null && widget.trainingData['background'] != 'default.png')
        ? _imagePathPrefix + widget.trainingData['background']
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
                        image: NetworkImage(backgroundImageUrl),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.darken),
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
                          widget.trainingData['title'] ?? 'Training Details',
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
                  _isLoadingTrainer
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : Row(
                          children: [
                            const Icon(Icons.person, color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Trainer: ${_trainerInfo['username'] ?? 'N/A'}',
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
                            widget.trainingData['description'] ?? 'No description available.',
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
                      child: _isLoadingTrainer
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : Row(
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
                                        _trainerInfo['username'] ?? 'N/A',
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text('Personal Trainer', style: TextStyle(color: Colors.white70, fontSize: 14)),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _launchWhatsApp(_trainerInfo['whatsapp']?.replaceAll('+', '') ?? ''),
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
                                  widget.trainingData['days'] ?? 'N/A',
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
                                  widget.trainingData['time_start']?.substring(0, 5) ?? 'N/A',
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
                                  'Rp ${widget.trainingData['price']?.toString() ?? 'N/A'}',
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
                                  '${widget.trainingData['total_session']?.toString() ?? 'N/A'} Sessions',
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

                    // "Book Now" button removed from here
                    // const SizedBox(height: 24), // Removed if Spacer already handles bottom spacing
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