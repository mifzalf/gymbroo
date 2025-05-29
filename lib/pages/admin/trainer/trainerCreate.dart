// File: lib/pages/admin/trainer/createTrainerPage.dart

import 'package:flutter/material.dart';

class CreateTrainerPage extends StatefulWidget {
  const CreateTrainerPage({super.key});

  @override
  _CreateTrainerPageState createState() => _CreateTrainerPageState();
}

class _CreateTrainerPageState extends State<CreateTrainerPage> {
  final TextEditingController _trainerNameController = TextEditingController(); // Ubah nama controller
  final TextEditingController _whatsappController = TextEditingController(); // Tambahkan controller

  // Fungsi untuk menangani pembuatan trainer
  void _createTrainer() {
    print('Creating New Trainer:');
    print('Trainer Name: ${_trainerNameController.text}');
    print('Whatsapp: ${_whatsappController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trainer created successfully!')),
    );
    Navigator.pop(context); // Kembali ke halaman sebelumnya
  }

  // Fungsi untuk navigasi kembali ke halaman sebelumnya
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
            // Header dengan tombol kembali dan judul
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
                    'Create Trainer', // Judul halaman
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Konten form
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Input Nama Trainer
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF474242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _trainerNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Trainer Name',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Input Whatsapp
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF474242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _whatsappController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone, // Tipe keyboard untuk nomor telepon
                        decoration: InputDecoration(
                          hintText: 'Whatsapp (e.g., 081234567890)',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tombol Create
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _createTrainer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6E886),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Create Trainer',
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