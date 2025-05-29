import 'package:flutter/material.dart';
import 'package:gymbroo/pages/admin/dashboardPage.dart';
import 'package:gymbroo/pages/admin/memberPage.dart';
import 'package:gymbroo/pages/admin/membership/membershipPage.dart';
import 'package:gymbroo/pages/admin/trainer/trainerPage.dart';
import 'package:gymbroo/pages/admin/training/trainingCreate.dart';
import 'package:gymbroo/pages/admin/training/trainingDetail.dart';
import 'package:gymbroo/pages/admin/training/trainingEdit.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  int _currentIndex = 2; // Set to 2 since this is the training page

  // Sample training data - replace with actual data from your backend
  final List<Map<String, dynamic>> trainingData = [
    {
      'no': 1,
      'trainingName': 'Morning Cardio',
      'price': 'Rp 50.000',
      'time': '07:00 - 08:00'
    },
    {
      'no': 2,
      'trainingName': 'Weight Training',
      'price': 'Rp 75.000',
      'time': '09:00 - 10:30'
    },
    {
      'no': 3,
      'trainingName': 'Yoga Class',
      'price': 'Rp 40.000',
      'time': '18:00 - 19:00'
    },
    {
      'no': 4,
      'trainingName': 'HIIT Training',
      'price': 'Rp 60.000',
      'time': '19:30 - 20:30'
    },
    {
      'no': 5,
      'trainingName': 'Pilates',
      'price': 'Rp 55.000',
      'time': '10:00 - 11:00'
    },
    {
      'no': 6,
      'trainingName': 'Boxing Class',
      'price': 'Rp 80.000',
      'time': '20:00 - 21:00'
    },
    {
      'no': 7,
      'trainingName': 'Crossfit',
      'price': 'Rp 90.000',
      'time': '06:00 - 07:00'
    },
    {
      'no': 8,
      'trainingName': 'Zumba Dance',
      'price': 'Rp 45.000',
      'time': '17:00 - 18:00'
    },
    {
      'no': 9,
      'trainingName': 'Personal Training',
      'price': 'Rp 150.000',
      'time': 'Flexible'
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
        // Stay on training page
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
      SnackBar(content: const Text('Navigate to dashboard Page')),
    );
  }

  void _navigateToMembershipPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MembershipPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Navigate to Membership Page')),
    );
  }

  void _navigateToTrainingPage() {
    // Karena ini adalah halaman Training, tidak perlu navigasi lagi,
    // hanya tampilkan SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Stay on Training Page')),
    );
  }

  void _navigateToTrainerPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrainerPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Navigate to Trainer Page')),
    );
  }

  void _navigateToMemberPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const memberPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Navigate to Member Page')),
    );
  }

  // Fungsi untuk menavigasi ke halaman CreateTrainingPage
  void _createTraining() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTrainingPage()),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Create new training class')),
    );
  }

  // Fungsi untuk menavigasi ke halaman EditTrainingPage
  void _editTraining(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTrainingPage(
          trainingData: trainingData[index], // Meneruskan data pelatihan yang akan diedit
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit training: ${trainingData[index]['trainingName']}')),
    );
  }

  void _deleteTraining(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Delete Training Class',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to delete ${trainingData[index]['trainingName']}?',
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
                  trainingData.removeAt(index);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Training class deleted')),
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

  // Fungsi untuk menavigasi ke halaman detail pelatihan saat nama diklik
  void _viewTrainingDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingDetailPage(
          trainingData: trainingData[index], // Meneruskan data lengkap ke halaman detail
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for: ${trainingData[index]['trainingName']}')),
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
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Training class',
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
                  onPressed: _createTraining,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create',
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
                                'Training name',
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
                                'Price',
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
                                'Time',
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
                          itemCount: trainingData.length,
                          itemBuilder: (context, index) {
                            final item = trainingData[index];
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
                                    child: GestureDetector( // <-- Wrap with GestureDetector
                                      onTap: () => _viewTrainingDetail(index), // <-- Call new function
                                      child: Text(
                                        item['trainingName'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          decoration: TextDecoration.underline, // Opsional: Beri underline
                                          decorationColor: Colors.white, // Warna underline
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      item['price'],
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
                                      item['time'],
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
                                          onTap: () => _editTraining(index),
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
                                          onTap: () => _deleteTraining(index),
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