import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  // Menerima data pengguna dari halaman sebelumnya
  final String userName;
  final String userEmail;
  final String userPhotoUrl; // Opsional, jika ingin mengedit foto
  final String membershipStatus; // Opsional, jika ingin menampilkan saja

  const EditProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userPhotoUrl = '', // Default kosong jika tidak ada foto
    this.membershipStatus = '', // Default kosong
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // Controllers untuk TextField
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controllers dengan data yang diterima
    _emailController = TextEditingController(text: widget.userEmail);
    _nameController = TextEditingController(text: widget.userName);
    _newPasswordController = TextEditingController(); // Kosongkan untuk password baru
    _confirmPasswordController = TextEditingController(); // Kosongkan
  }

  // Fungsi untuk menangani pembaruan profil
  void _updateProfile() {
    // Di sini Anda akan menambahkan logika untuk menyimpan perubahan ke backend Anda
    print('Updating Profile:');
    print('New Email: ${_emailController.text}');
    print('New Name: ${_nameController.text}');
    print('New Password: ${_newPasswordController.text}');
    print('Confirm Password: ${_confirmPasswordController.text}');

    // Validasi sederhana untuk password
    if (_newPasswordController.text.isNotEmpty &&
        _newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password and confirm password do not match!')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
    Navigator.pop(context); // Kembali ke halaman sebelumnya (ProfileUser)
  }

  // Fungsi untuk navigasi kembali
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
            // Header Section dengan Background Image dan Tombol Kembali
            Container(
              width: double.infinity,
              height: 120,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/gymstart.jpg'), // Sesuaikan path gambar Anda
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Align(
                    alignment: Alignment.centerLeft,
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
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28, // Sesuaikan dengan ukuran di ProfileUser
                            fontWeight: FontWeight.bold, // Sesuaikan dengan gaya di ProfileUser
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Form Input
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Input Email
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Input Nama
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Name',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 16),

                    // Input Password Baru
                    _buildTextField(
                      controller: _newPasswordController,
                      hintText: 'Enter Your new password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),

                    // Input Konfirmasi Password
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Your New Password',
                      icon: Icons.lock,
                      obscureText: true,
                    ),

                    const SizedBox(height: 32),

                    // Tombol Save
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE6E886), // Warna kuning cerah
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save',
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

  // Widget helper untuk membuat TextField dengan gaya yang konsisten
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF474242), // Warna latar belakang TextField
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}