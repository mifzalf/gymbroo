// File: lib/pages/admin/trainer/editTrainerPage.dart

import 'package:flutter/material.dart';

class EditTrainerPage extends StatefulWidget {
  final Map<String, dynamic> trainerData; // Menggunakan trainerData

  const EditTrainerPage({super.key, required this.trainerData});

  @override
  _EditTrainerPageState createState() => _EditTrainerPageState();
}

class _EditTrainerPageState extends State<EditTrainerPage> {
  final TextEditingController _trainerNameController = TextEditingController(); // Ubah nama controller agar lebih jelas
  final TextEditingController _whatsappController = TextEditingController(); // Tambahkan controller untuk whatsapp

  @override
  void initState() {
    super.initState();
    // Inisialisasi kontroler dengan data trainer yang diterima
    _trainerNameController.text = widget.trainerData['nama'] ?? ''; // Menggunakan kunci 'nama'
    _whatsappController.text = widget.trainerData['whatsapp'] ?? ''; // Inisialisasi whatsapp
  }

  // Fungsi untuk menangani pembaruan trainer
  void _updateTrainer() {
    print('Updating Trainer:');
    print('New Trainer Name: ${_trainerNameController.text}');
    print('New Whatsapp: ${_whatsappController.text}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trainer updated successfully!')),
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

                    // Tombol Update
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _updateTrainer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6E886),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
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