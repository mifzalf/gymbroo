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

    await Future.delayed(const Duration(seconds: 1));

    if (token == null || JwtDecoder.isExpired(token)) {
      print('DEBUG (Splash): Token tidak ada atau kedaluwarsa. Navigasi ke StartPage.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StartPage()),
      );
    } else {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final String? userRole = decodedToken['role']; 

        if (userRole == null) {
          print('DEBUG (Splash): Role tidak ditemukan di token. Navigasi ke StartPage.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StartPage()),
          );
          return;
        }

        print('DEBUG (Splash): Token valid. Role: $userRole. Navigasi ke dashboard.');
        if (userRole == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const dashboardAdmin(
                adminName: "Admin Gymbroo", 
              ),
            ),
          );
        } else if (userRole == 'user') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DashboardUser(
                userName: "Pengguna Gymbroo", 
                userPhotoUrl: "", 
                membershipStatus: "Member Aktif", 
              ),
            ),
          );
        } else {
          print('DEBUG (Splash): Tipe peran tidak dikenal ($userRole). Navigasi ke StartPage.');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const StartPage()),
          );
        }
      } catch (e) {
        print('DEBUG (Splash): Error mendekode token: $e. Navigasi ke StartPage.');
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
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFFE8D864)),
      ),
    );
  }
}