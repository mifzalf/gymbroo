// File: lib/pages/users/training/detailTraining.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UserTrainingDetailPage extends StatefulWidget {
  final Map<String, dynamic> trainingData;

  const UserTrainingDetailPage({
    Key? key,
    required this.trainingData,
  }) : super(key: key);

  @override
  State<UserTrainingDetailPage> createState() => _UserTrainingDetailPageState();
}

class _UserTrainingDetailPageState extends State<UserTrainingDetailPage> {
  // Sample program description - matches admin detail structure
  String getProgramDescription() {
    switch (widget.trainingData['name']) {
      case 'Yoga Training':
        return 'Improve flexibility, strength, and mental wellness through guided yoga sessions. This comprehensive program combines traditional poses with breathing techniques for mind-body wellness, suitable for all levels from beginner to advanced.';
      case 'Weight Lost':
        return 'Structured weight loss program with personalized diet and exercise plan. Focus on sustainable weight management through a combination of cardio, strength training, and nutritional guidance for long-term results.';
      case 'Body Building':
        return 'Intensive muscle building program for strength and physique development. Learn progressive overload techniques, proper form, and nutrition strategies specifically designed for muscle gain and bodybuilding goals.';
      default:
        return 'Join this comprehensive training program to improve your fitness level and achieve your health goals with professional guidance and structured workout programs tailored to your needs.';
    }
  }

  // Get trainer data based on training type
  Map<String, String> getTrainerData() {
    switch (widget.trainingData['name']) {
      case 'Yoga Training':
        return {'name': 'Sarah Williams', 'whatsapp': '+62812345678903'};
      case 'Weight Lost':
        return {'name': 'Mike Johnson', 'whatsapp': '+62812345678902'};
      case 'Body Building':
        return {'name': 'David Brown', 'whatsapp': '+62812345678904'};
      default:
        return {'name': 'Professional Trainer', 'whatsapp': '+62812345678900'};
    }
  }

  // Get duration from training data
  String getDuration() {
    return '${widget.trainingData['duration']} Weeks';
  }

  // Get session start time
  String getSessionStartTime() {
    switch (widget.trainingData['name']) {
      case 'Yoga Training':
        return '06:00 PM';
      case 'Weight Lost':
        return '07:00 AM';
      case 'Body Building':
        return '08:00 PM';
      default:
        return '07:00 AM';
    }
  }

  // Get training days
  String getTrainingDays() {
    switch (widget.trainingData['name']) {
      case 'Yoga Training':
        return 'Mon, Wed, Fri';
      case 'Weight Lost':
        return 'Tue, Thu, Sat';
      case 'Body Building':
        return 'Mon, Wed, Fri, Sat';
      default:
        return 'Mon, Wed, Fri';
    }
  }

  // Launch WhatsApp
  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }

  // Get Started function
  void _getStarted() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${widget.trainingData['name']} program...'),
        backgroundColor: const Color(0xFF00DCB7),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final trainerData = getTrainerData();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section with gradient background
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
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.trainingData['name'],
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
                      const Icon(
                        Icons.person,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trainer: ${trainerData['name']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
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
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF00DCB7),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Program Description',
                                style: TextStyle(
                                  color: Color(0xFF00DCB7),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            getProgramDescription(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.6,
                            ),
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
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trainerData['name']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Trainer',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _launchWhatsApp(trainerData['whatsapp']!.replaceAll('+', '')),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.message,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Training Schedule Details
                    Row(
                      children: [
                        // Duration Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  color: Color(0xFF00DCB7),
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  getDuration(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Duration',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Session Time Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  color: Color(0xFF00DCB7),
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  getSessionStartTime(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Session Start',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Days and Price
                    Row(
                      children: [
                        // Training Days Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.today,
                                  color: Color(0xFF00DCB7),
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  getTrainingDays(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Text(
                                  'Schedule',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Price Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D2D2D),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.payment,
                                  color: Color(0xFF00DCB7),
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.trainingData['price'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Total Price',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Get Started Button (Yellow like in training user page)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _getStarted,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700), // Yellow color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 8),
                            Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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