// File: lib/pages/splashScreen.dart

import 'package:flutter/material.dart';
import 'package:gymbroo/pages/admin/dashboardPage.dart';
import 'package:gymbroo/pages/users/dashboardPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; 

import 'package:gymbroo/pages/startPages.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? userType = prefs.getString('userType');

    // Beri sedikit delay untuk efek splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (token == null || userType == null || JwtDecoder.isExpired(token)) {
      // Tidak ada token, atau token kedaluwarsa
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StartPage()),
      );
    } else {
      // Token ada dan masih valid
      if (userType == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const dashboardAdmin(
              adminName: "Admin Gymbroo", // Ambil dari data login jika disimpan
            ),
          ),
        );
      } else if (userType == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardUser(
              userName: "Pengguna Gymbroo", // Ambil dari data login jika disimpan
              userPhotoUrl: "", // Ambil dari data login jika disimpan
              membershipStatus: "Member Aktif", // Ambil dari data login jika disimpan
            ),
          ),
        );
      } else {
        // Tipe pengguna tidak dikenal, kembalikan ke StartPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StartPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black, // Warna background splash screen
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFE8D864)), // Indikator loading
      ),
    );
  }
}