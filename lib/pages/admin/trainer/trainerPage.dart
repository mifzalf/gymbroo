import 'package:flutter/material.dart';
import 'package:gymbroo/pages/admin/dashboardPage.dart';
import 'package:gymbroo/pages/admin/memberPage.dart';
import 'package:gymbroo/pages/admin/membership/membershipPage.dart';
import 'package:gymbroo/pages/admin/trainer/TrainerEdit.dart';
import 'package:gymbroo/pages/admin/trainer/trainerCreate.dart';
import 'package:gymbroo/pages/admin/training/trainingPage.dart';


class TrainerPage extends StatefulWidget {
  const TrainerPage({super.key});

  @override
  State<TrainerPage> createState() => _TrainerPageState();
}

class _TrainerPageState extends State<TrainerPage> {
  int _currentIndex = 3; 

  // Mengubah nama variabel dari trainingData menjadi trainerData
  final List<Map<String, dynamic>> trainerData = [
    {
      'no': 1,
      'nama': 'Morning Cardio',
      'whatsapp': '081234567801',
      'description': 'Pelatih ahli dalam sesi kardio pagi.',
      'duration': 'Full-time',
      'time': '06.00' // Contoh waktu mulai
    },
    {
      'no': 2,
      'nama': 'Weight Training',
      'whatsapp': '081234567802',
      'description': 'Spesialis dalam pelatihan beban dan pembentukan otot.',
      'duration': 'Part-time',
      'time': '08.30'
    },
    {
      'no': 3,
      'nama': 'Yoga Class',
      'whatsapp': '081234567803',
      'description': 'Instruktur yoga bersertifikat dengan pengalaman 5 tahun.',
      'duration': 'Part-time',
      'time': '10.00'
    },
    {
      'no': 4,
      'nama': 'HIIT Training',
      'whatsapp': '081234567804',
      'description': 'Pelatih dengan fokus pada intensitas tinggi interval training.',
      'duration': 'Full-time',
      'time': '14.00'
    },
    {
      'no': 5,
      'nama': 'Pilates',
      'whatsapp': '081234567805',
      'description': 'Ahli dalam Pilates untuk kekuatan inti dan fleksibilitas.',
      'duration': 'Part-time',
      'time': '17.00'
    },
    {
      'no': 6,
      'nama': 'Boxing Class',
      'whatsapp': '081234567806',
      'description': 'Mantan petinju profesional, pelatih kelas tinju.',
      'duration': 'Full-time',
      'time': '19.00'
    },
    {
      'no': 7,
      'nama': 'Crossfit',
      'whatsapp': '081234567807',
      'description': 'Pelatih CrossFit Level 1 bersertifikat.',
      'duration': 'Full-time',
      'time': '20.30'
    },
    {
      'no': 8,
      'nama': 'Zumba Dance',
      'whatsapp': '081234567808',
      'description': 'Instruktur Zumba yang energik dan menyenangkan.',
      'duration': 'Part-time',
      'time': '11.00'
    },
    {
      'no': 9,
      'nama': 'Personal Training',
      'whatsapp': '081234567809',
      'description': 'Pelatih pribadi yang menyediakan program kustom.',
      'duration': 'Full-time',
      'time': '09.00'
    },
  ];


  void _navigateToPage(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        _navigateToDashboardpPage();
        break;
      case 1:
        _navigateToMembershipPage();
        break;
      case 2:
        _navigateToTrainingPage();
        break;
      case 3:
        _navigateToTrainerPage();
        break;
      case 4:
        _navigateToMemberPage();
        break;
    }
  }
  
  void _navigateToDashboardpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const dashboardAdmin()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to dashboard Page')),
    );
  }

  void _navigateToMembershipPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MembershipPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Membership Page')),
    );
  }

  void _navigateToTrainingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainingPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Training Page')),
    );
  }

  void _navigateToTrainerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Trainer Page')),
    );
  }

  void _navigateToMemberPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const memberPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Member Page')),
    );
  }

  void _createTrainer() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTrainerPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Create Trainer Page')),
    );
  }

  // Memperbaiki pemanggilan parameter dan menggunakan trainerData
  void _editTrainer(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTrainerPage(
          trainerData: trainerData[index], // Meneruskan data dengan nama parameter yang benar
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigate to Edit Trainer: ${trainerData[index]['nama']}')),
    );
  }

  // Mengubah nama fungsi dan referensi data menjadi trainerData
  void _deleteTrainer(int index) { 
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Delete Trainer',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete ${trainerData[index]['nama']}?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  trainerData.removeAt(index); // Menggunakan trainerData
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trainer deleted')),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
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
              child: const Row(
                children: [
                  Icon(
                    Icons.sports_martial_arts,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Trainer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Create Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: _createTrainer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create Trainer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            // Data Table
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Table Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF007662), Color(0xFF00DCB7)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                'No',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'Name',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Whatsapp',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'Action',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Table Data
                      Expanded(
                        child: ListView.builder(
                          itemCount: trainerData.length, // Menggunakan trainerData
                          itemBuilder: (context, index) {
                            final item = trainerData[index]; // Menggunakan trainerData
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      item['no'].toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      item['nama'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item['whatsapp'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _editTrainer(index),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.edit,
                                              color: Color(0xFF00DCB7),
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => _deleteTrainer(index), // Memanggil _deleteTrainer
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Bottom Navigation
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