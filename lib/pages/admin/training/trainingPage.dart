import 'package:flutter/material.dart';
import 'package:gymbroo/pages/admin/dashboardPage.dart';
import 'package:gymbroo/pages/admin/memberPage.dart';
import 'package:gymbroo/pages/admin/membership/membershipPage.dart';
import 'package:gymbroo/pages/admin/trainer/trainerPage.dart';
import 'package:gymbroo/pages/admin/training/trainingCreate.dart';
import 'package:gymbroo/pages/admin/training/trainingDetail.dart';
import 'package:gymbroo/pages/admin/training/trainingEdit.dart';
import 'package:http/http.dart' as http; // Import http
import 'dart:convert'; // Import json
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  int _currentIndex = 2; // Set to 2 since this is the training page

  List<dynamic> trainingData = []; // Ubah menjadi List<dynamic> untuk menampung data dari API
  bool _isLoading = true; // State untuk loading data
  final String _baseUrl = 'http://localhost:3000/API'; // Your backend URL

  @override
  void initState() {
    super.initState();
    _fetchTrainings(); // Fetch data when the page initializes
  }

  // Function to fetch trainings list from the backend
  Future<void> _fetchTrainings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in again.', Colors.red);
        // Optionally, navigate to login page:
        // Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/trainings'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        setState(() {
          trainingData = fetchedData;
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to load trainings.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error fetching trainings: $e', Colors.red);
      print('Error fetching trainings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to delete a training
  Future<void> _deleteTraining(int trainingId) async { // Hanya menerima trainingId
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D2D2D),
          title: const Text(
            'Delete Training Class',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this training class?',
            style: TextStyle(color: Colors.white70),
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
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _isLoading = true; // Show loading while deleting
                });

                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('token');

                  if (token == null) {
                    _showSnackBar('Authentication token not found. Please log in again.', Colors.red);
                    return;
                  }

                  final response = await http.delete(
                    Uri.parse('$_baseUrl/admin/trainings/$trainingId'),
                    headers: {
                      'Authorization': 'Bearer $token',
                    },
                  );

                  if (response.statusCode == 200) {
                    _showSnackBar('Training class deleted successfully', Colors.green);
                    // Refresh the training list after deletion
                    _fetchTrainings();
                  } else if (response.statusCode == 401 || response.statusCode == 403) {
                    final responseBody = json.decode(response.body);
                    _showSnackBar(responseBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
                  } else {
                    final responseBody = json.decode(response.body);
                    _showSnackBar(responseBody['message'] ?? 'Failed to delete training class.', Colors.red);
                  }
                } catch (e) {
                  _showSnackBar('Error deleting training class: $e', Colors.red);
                  print('Error deleting training class: $e');
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  void _navigateToPage(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const dashboardAdmin()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MembershipPage()),
        );
        break;
      case 2:
        // Stay on training page
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TrainerPage()),
        );
        break;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const memberPage()),
        );
        break;
    }
  }

  void _createTraining() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTrainingPage()),
    );
    if (result == true) { // If returned with success indication
      _fetchTrainings(); // Refresh data
    }
  }

  void _editTraining(Map<String, dynamic> training) async { // Menerima Map<String, dynamic>
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTrainingPage(
          trainingData: training, // Meneruskan data pelatihan lengkap
        ),
      ),
    );
    if (result == true) { // If returned with success indication
      _fetchTrainings(); // Refresh data
    }
  }

  // Function to navigate to training detail page when name is clicked
  void _viewTrainingDetail(Map<String, dynamic> training) { // Menerima Map<String, dynamic>
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingDetailPage(
          trainingData: training, // Meneruskan data lengkap ke halaman detail
        ),
      ),
    );
    _showSnackBar('Viewing details for: ${training['title']}', Colors.blue); // Menggunakan 'title' dari backend
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
                    'Training Class',
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFE8D864)))
                      : Column(
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
                                      'Training Name',
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
                              child: trainingData.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No training data.',
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    )
                                  : ListView.builder(
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
                                                  (index + 1).toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: GestureDetector(
                                                  onTap: () => _viewTrainingDetail(item), // Pass the whole item
                                                  child: Text(
                                                    item['title'] ?? '-', // Using 'title' from backend
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      decoration: TextDecoration.underline,
                                                      decorationColor: Colors.white,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Rp ${item['price']?.toString() ?? '-'}', // Using 'price' from backend
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
                                                  item['time_start']?.substring(0, 5) ?? '-', // Using 'time_start' from backend
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
                                                  mainAxisSize: MainAxisSize.min, // Fix RenderFlex overflow
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () => _editTraining(item), // Pass the whole item
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
                                                      onTap: () => _deleteTraining(item['id']), // Pass training ID
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