import 'package:flutter/material.dart';
import 'package:gymbroo/pages/admin/dashboardPage.dart';
import 'package:gymbroo/pages/admin/membership/membershipPage.dart';
import 'package:gymbroo/pages/admin/trainer/trainerPage.dart';
import 'package:gymbroo/pages/admin/training/trainingPage.dart';

class memberPage extends StatefulWidget {
  const memberPage({super.key});

  @override
  State<memberPage> createState() => _memberPageState();
}

class _memberPageState extends State<memberPage> {
  int _currentIndex = 4; 

  // Sample training data - replace with actual data from your backend
  final List<Map<String, dynamic>> trainingData = [
    {
    'no': 1,
    'nama': 'Rahadya Suset',
    'email': 'rahadya@example.com',
    'status': 'aktif'
    },
    {
      'no': 2,
      'nama': 'Dewi Lestari',
      'email': 'dewi.lestari@example.com',
      'status': 'tidak aktif'
    },
    {
      'no': 3,
      'nama': 'Andi Pratama',
      'email': 'andi.pratama@example.com',
      'status': 'aktif'
    },
    {
      'no': 4,
      'nama': 'Sinta Rahmawati',
      'email': 'sinta.rahma@example.com',
      'status': 'aktif'
    },
    {
      'no': 5,
      'nama': 'Budi Santoso',
      'email': 'budi.santoso@example.com',
      'status': 'tidak aktif'
    },
    {
      'no': 6,
      'nama': 'Nina Kartika',
      'email': 'nina.kartika@example.com',
      'status': 'aktif'
    },
    {
      'no': 7,
      'nama': 'Agus Maulana',
      'email': 'agus.maulana@example.com',
      'status': 'aktif'
    },
    {
      'no': 8,
      'nama': 'Dina Marlina',
      'email': 'dina.marlina@example.com',
      'status': 'tidak aktif'
    },
    {
      'no': 9,
      'nama': 'Rizky Hidayat',
      'email': 'rizky.hidayat@example.com',
      'status': 'aktif'
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
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const MemberPage()),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Member Page')),
    );
  }

  void _createTraining() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create new training class')),
    );
  }

  void _editTraining(int index) {
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
              child: Row(
                children: [
                  Icon(
                    Icons.sports_martial_arts,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Text(
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
                                'Email',
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
                                'Status',
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
                                      item['email'],
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
                                      item['status'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
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