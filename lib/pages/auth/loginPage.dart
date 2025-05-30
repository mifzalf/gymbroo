import 'package:flutter/material.dart';
import 'package:gymbroo/pages/admin/dashboardPage.dart';
import 'package:gymbroo/pages/users/dashboardPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import untuk SharedPreferences

import 'package:gymbroo/pages/auth/register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false; 

  final String _baseUrl = 'http://localhost:3000/API'; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi untuk menangani logika login
  void _login() async {
    // Validasi form sebelum mengirim permintaan
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Tampilkan indikator loading
      });

      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/login'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': _emailController.text,
            'password': _passwordController.text,
          }),
        );

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          final String token = responseBody['token'];
          final String userType = responseBody['userType'];
          
          // Simpan token ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          print('Token disimpan: $token'); // Untuk debugging

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login berhasil sebagai $userType!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigasi berdasarkan tipe user
          if (userType == 'admin') {
            // Jika backend mengembalikan nama admin, Anda bisa meneruskannya
            // Contoh: final String adminUsername = responseBody['admin']['username'] ?? 'Admin';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const dashboardAdmin(
                  adminName: "Admin Gymbroo", // Ganti dengan nama admin asli jika tersedia dari API
                ),
              ),
            );
          } else if (userType == 'user') {
            // TODO: Backend Anda saat ini hanya mengembalikan {token, userType} untuk login.
            // Untuk mengisi data userName, userPhotoUrl, membershipStatus di DashboardUser,
            // Anda perlu memodifikasi respons API login backend agar menyertakan data pengguna lengkap.
            // Contoh data placeholder:
            final String userName = "Pengguna Gymbroo"; // Ganti dengan nama pengguna asli dari API
            // Asumsi URL foto profil disimpan di public/images/users/ di backend
            final String userPhotoUrl = '$_baseUrl/images/users/default.png'; // Ganti dengan URL foto profil asli dari API
            final String membershipStatus = "Member Aktif"; // Ganti dengan status membership asli dari API
            
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardUser(
                  userName: userName,
                  userPhotoUrl: userPhotoUrl,
                  membershipStatus: membershipStatus,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tipe pengguna tidak dikenal.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          // Jika login gagal (status code selain 200)
          final responseBody = json.decode(response.body);
          final String errorMessage = responseBody['message'] ?? 'Login gagal. Silakan cek kembali kredensial Anda.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Tangani error jaringan atau lainnya
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error login: $e'); // Untuk debugging
      } finally {
        setState(() {
          _isLoading = false; // Sembunyikan indikator loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: 'Sign in ',
                      style: TextStyle(
                        color: const Color(0xFFE8D864),
                        fontFamily: Theme.of(context).textTheme.headlineLarge?.fontFamily,
                      ),
                    ),
                    const TextSpan(
                      text: 'to your\nAccount',
                      style: TextStyle(
                        color: Color(0xFF007662), // Teal color
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Form untuk Email dan Password
              Form(
                key: _formKey, // Gunakan GlobalKey untuk validasi form
                child: Column(
                  children: [
                    // Email Field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField( // Menggunakan TextFormField untuk validasi
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          hintText: 'Masukkan email Anda',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email wajib diisi.';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Masukkan email yang valid.';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password Field dengan Toggle Visibility
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField( // Menggunakan TextFormField untuk validasi
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible, // Atur berdasarkan state
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          hintText: 'Masukkan kata sandi Anda',
                          hintStyle: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kata sandi wajib diisi.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login, // Tombol dinonaktifkan saat loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8D864), // Warna Kuning
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black) // Tampilkan loading spinner
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const Spacer(), // Mengambil sisa ruang vertikal

              // Bagian Pendaftaran (Register Section)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF007662), // Warna Teal
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Belum punya",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Akun? Daftar Sekarang",
                          style: TextStyle(
                            color: Color(0xFFE8D864), // Warna Kuning
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navigasi ke halaman Register
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D864), // Warna Kuning
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}