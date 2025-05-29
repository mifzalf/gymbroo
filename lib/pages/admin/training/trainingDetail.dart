// File: lib/pages/admin/training/trainingDetailPage.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TrainingDetailPage extends StatefulWidget {
  final Map<String, dynamic> trainingData;

  const TrainingDetailPage({
    Key? key,
    required this.trainingData,
  }) : super(key: key);

  @override
  State<TrainingDetailPage> createState() => _TrainingDetailPageState();
}

class _TrainingDetailPageState extends State<TrainingDetailPage> {
  // Sample program description - you can modify this based on your needs
  String getProgramDescription() {
    switch (widget.trainingData['trainingName']) {
      case 'Morning Cardio':
        return 'Start your day with an energizing cardio session designed to boost your metabolism and improve cardiovascular health. This high-energy workout includes running, cycling, and aerobic exercises perfect for morning motivation.';
      case 'Weight Training':
        return 'Build strength and muscle mass with our comprehensive weight training program. Focus on proper form and progressive overload techniques to achieve your fitness goals safely and effectively.';
      case 'Yoga Class':
        return 'Find your inner peace and improve flexibility with our yoga sessions. Suitable for all levels, combining traditional poses with breathing techniques for mind-body wellness.';
      case 'HIIT Training':
        return 'High-Intensity Interval Training designed to burn maximum calories in minimum time. Alternating between intense bursts of activity and brief recovery periods for optimal results.';
      case 'Pilates':
        return 'Strengthen your core and improve posture with Pilates exercises. Focus on controlled movements and breathing to enhance flexibility, balance, and overall body awareness.';
      case 'Boxing Class':
        return 'Learn boxing fundamentals while getting an incredible full-body workout. Improve coordination, build strength, and relieve stress through this dynamic combat sport training.';
      case 'Crossfit':
        return 'Challenge yourself with varied functional movements performed at high intensity. Build strength, endurance, and agility through constantly varied workouts.';
      case 'Zumba Dance':
        return 'Dance your way to fitness with Latin-inspired moves and upbeat music. A fun, effective workout that feels more like a party than exercise.';
      case 'Personal Training':
        return 'One-on-one personalized training sessions tailored to your specific goals and fitness level. Get individual attention and customized workout plans from certified trainers.';
      default:
        return 'Join this training session to improve your fitness level and achieve your health goals with professional guidance and structured workout programs.';
    }
  }

  // Get trainer data based on training type
  Map<String, String> getTrainerData() {
    switch (widget.trainingData['trainingName']) {
      case 'Morning Cardio':
        return {'name': 'John Smith', 'whatsapp': '+62812345678901'};
      case 'Weight Training':
        return {'name': 'Mike Johnson', 'whatsapp': '+62812345678902'};
      case 'Yoga Class':
        return {'name': 'Sarah Williams', 'whatsapp': '+62812345678903'};
      case 'HIIT Training':
        return {'name': 'David Brown', 'whatsapp': '+62812345678904'};
      case 'Pilates':
        return {'name': 'Emma Davis', 'whatsapp': '+62812345678905'};
      case 'Boxing Class':
        return {'name': 'Alex Rodriguez', 'whatsapp': '+62812345678906'};
      case 'Crossfit':
        return {'name': 'Chris Wilson', 'whatsapp': '+62812345678907'};
      case 'Zumba Dance':
        return {'name': 'Maria Garcia', 'whatsapp': '+62812345678908'};
      case 'Personal Training':
        return {'name': 'Robert Taylor', 'whatsapp': '+62812345678909'};
      default:
        return {'name': 'Trainer', 'whatsapp': '+62812345678900'};
    }
  }

  // Get duration data (4 weeks or more)
  String getDuration() {
    switch (widget.trainingData['trainingName']) {
      case 'Morning Cardio':
      case 'Yoga Class':
      case 'Zumba Dance':
        return '4 Weeks';
      case 'Weight Training':
      case 'Boxing Class':
      case 'Crossfit':
        return '6 Weeks';
      case 'HIIT Training':
      case 'Pilates':
        return '8 Weeks';
      case 'Personal Training':
        return '12 Weeks';
      default:
        return '4 Weeks';
    }
  }

  // Get session start time (hour)
  String getSessionStartTime() { // <--- FUNGSI INI DIUBAH NAMANYA DAN LOGIKANYA
    switch (widget.trainingData['trainingName']) {
      case 'Morning Cardio':
        return '07:00 AM'; // Contoh: ubah ke format jam mulai
      case 'Weight Training':
        return '09:00 AM';
      case 'Yoga Class':
        return '06:00 PM';
      case 'HIIT Training':
        return '07:30 PM';
      case 'Pilates':
        return '10:00 AM';
      case 'Boxing Class':
        return '08:00 PM';
      case 'Crossfit':
        return '06:00 AM';
      case 'Zumba Dance':
        return '05:00 PM';
      case 'Personal Training':
        return 'Flexible'; // Atau sesuaikan jika ada waktu mulai spesifik
      default:
        return 'N/A'; // Jika tidak ada waktu mulai yang cocok
    }
  }

  // Get training days
  String getTrainingDays() {
    switch (widget.trainingData['trainingName']) {
      case 'Morning Cardio':
        return 'Mon, Wed, Fri';
      case 'Weight Training':
        return 'Tue, Thu, Sat';
      case 'Yoga Class':
        return 'Mon, Wed, Fri';
      case 'HIIT Training':
        return 'Tue, Thu, Sat';
      case 'Pilates':
        return 'Mon, Wed, Fri';
      case 'Boxing Class':
        return 'Tue, Thu, Sat';
      case 'Crossfit':
        return 'Mon, Wed, Fri';
      case 'Zumba Dance':
        return 'Tue, Thu, Sat';
      case 'Personal Training':
        return 'Flexible Schedule';
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
                          widget.trainingData['trainingName'],
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
                                  'Personal Trainer',
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
                            child: const Column( // Diubah menjadi const Column
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  color: Color(0xFF00DCB7),
                                  size: 24,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  // Memanggil fungsi getDuration
                                  // getDuration(), // <--- Tidak bisa dipanggil di sini jika Column const
                                  'Duration', // Teks statis jika ingin Column const
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Duration', // Teks statis jika ingin Column const
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
                            child: Column( // Tetap Column biasa agar bisa pakai nilai dinamis
                              children: [
                                const Icon(
                                  Icons.schedule,
                                  color: Color(0xFF00DCB7),
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  getSessionStartTime(), // <--- Memanggil fungsi baru di sini
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Session Start', // <--- Ubah label
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
                            child: Column( // Tetap Column biasa agar bisa pakai nilai dinamis
                              children: [
                                const Icon(
                                  Icons.today,
                                  color: Color(0xFF00DCB7),
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  getTrainingDays(), // Memanggil fungsi getTrainingDays
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
                            child: Column( // Tetap Column biasa agar bisa pakai nilai dinamis
                              children: [
                                const Icon(
                                  Icons.payment,
                                  color: Color(0xFF00DCB7),
                                  size: 24,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.trainingData['price'], // Menggunakan data harga langsung
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

                    // Contact Trainer Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _launchWhatsApp(trainerData['whatsapp']!.replaceAll('+', '')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00DCB7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.message,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Contact Trainer',
                              style: TextStyle(
                                color: Colors.white,
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