import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditTrainerPage extends StatefulWidget {
  final Map<String, dynamic> trainerData;

  const EditTrainerPage({super.key, required this.trainerData});

  @override
  _EditTrainerPageState createState() => _EditTrainerPageState();
}

class _EditTrainerPageState extends State<EditTrainerPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _trainerNameController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  bool _isLoading = false;
  final String _baseUrl = 'http://localhost:3000/API'; // Your backend URL

  @override
  void initState() {
    super.initState();
    // Initialize controllers with received trainer data
    _trainerNameController.text = widget.trainerData['username'] ?? ''; // Use 'username' key from backend
    _whatsappController.text = widget.trainerData['whatsapp'] ?? '';
  }

  // Function to handle updating a trainer
  void _updateTrainer() async {
    if (_formKey.currentState!.validate()) {
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

        final response = await http.patch(
          Uri.parse('$_baseUrl/admin/trainers/${widget.trainerData['id']}'), // Use trainer ID
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(<String, String>{
            'username': _trainerNameController.text,
            'whatsapp': _whatsappController.text,
          }),
        );

        if (response.statusCode == 200) { // Backend returns 200 for success
          _showSnackBar('Trainer updated successfully!', Colors.green);
          Navigator.pop(context, true); // Return true to previous page to refresh
        } else {
          final responseBody = json.decode(response.body);
          _showSnackBar(responseBody['message'] ?? 'Failed to update trainer.', Colors.red);
        }
      } catch (e) {
        _showSnackBar('An error occurred: $e', Colors.red);
        print('Error updating trainer: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // Function to navigate back to previous page
  void _navigateBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _navigateBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF007662), Color(0xFF00DCB7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Edit Trainer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Form content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Trainer Name Input
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF474242),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _trainerNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Trainer Name',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Trainer Name is required.';
                            }
                            // Simplified validation: only check length
                            if (value.length < 1 || value.length > 30) {
                              return 'Username must be between 1 and 30 characters.';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Whatsapp Input
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF474242),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _whatsappController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Whatsapp (e.g., 081234567890)',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Whatsapp is required.';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateTrainer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6E886),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text(
                                  'Update Trainer',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _trainerNameController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
}