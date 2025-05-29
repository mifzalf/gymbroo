// File: lib/pages/admin/training/editTrainingPage.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import untuk memilih gambar
import 'dart:io'; // Import untuk kelas File

class EditTrainingPage extends StatefulWidget {
  // Properti untuk menerima data pelatihan yang akan diedit
  final Map<String, dynamic> trainingData;

  const EditTrainingPage({super.key, required this.trainingData});

  @override
  _EditTrainingPageState createState() => _EditTrainingPageState();
}

class _EditTrainingPageState extends State<EditTrainingPage> {
  final TextEditingController _trainingNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  File? _backgroundImage; // Variabel untuk menyimpan gambar latar belakang

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data yang ada
    _trainingNameController.text = widget.trainingData['trainingName'] ?? '';
    _priceController.text = widget.trainingData['price'] ?? '';
    _timeController.text = widget.trainingData['time'] ?? '';
    _descriptionController.text = widget.trainingData['description'] ?? '';
    _durationController.text = widget.trainingData['duration'] ?? '';

    // Inisialisasi _backgroundImage jika ada path gambar di trainingData
    if (widget.trainingData['imagePath'] != null &&
        File(widget.trainingData['imagePath']).existsSync()) {
      _backgroundImage = File(widget.trainingData['imagePath']);
    }
  }

  // Fungsi untuk menangani pembaruan pelatihan
  void _updateTraining() {
    print('Updating Training:');
    print('New Training Name: ${_trainingNameController.text}');
    print('New Price: ${_priceController.text}');
    print('New Time: ${_timeController.text}');
    print('New Description: ${_descriptionController.text}');
    print('New Duration: ${_durationController.text}');
    if (_backgroundImage != null) {
      print('New Background Image Path: ${_backgroundImage!.path}');
    } else {
      print('No new background image selected.');
    }

    // TODO: Implementasikan logika pembaruan data pelatihan di sini
    // Termasuk mengirim _backgroundImage.path (jika ada) ke backend
    // atau memperbarui data lokal.

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Training updated successfully!')),
    );
    Navigator.pop(context); // Kembali ke halaman sebelumnya
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _backgroundImage = File(pickedFile.path);
      });
    }
  }

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
                    'Edit Training Class', // Judul halaman
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
              child: SingleChildScrollView(
                // Tambahkan SingleChildScrollView agar bisa discroll jika keyboard muncul
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Area untuk menampilkan atau memilih gambar latar belakang
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF474242),
                          borderRadius: BorderRadius.circular(12),
                          image: _backgroundImage != null
                              ? DecorationImage(
                                  image: FileImage(_backgroundImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _backgroundImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.add_a_photo,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Add/Change Background Photo',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ],
                              )
                            : null, // Jika sudah ada gambar, tidak perlu menampilkan ikon/teks
                      ),
                    ),

                    const SizedBox(height: 24), // Tambahkan spasi di sini

                    // Input Nama Pelatihan
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF474242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _trainingNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Training Name',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Input Harga
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF474242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _priceController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Price (e.g., Rp 50.000)',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Input Waktu
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF474242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _timeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Start Time (e.g., 16.30)',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Input Deskripsi
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF474242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Description',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Input Durasi
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF474242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _durationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Duration (e.g., 4 weeks)',
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
                        onPressed: _updateTraining,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6E886),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24), // Spasi di bawah tombol
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
    _trainingNameController.dispose();
    _priceController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}