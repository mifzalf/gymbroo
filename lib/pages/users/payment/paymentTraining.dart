// File: lib/pages/users/training/training_payment_page.dart

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka URL Midtrans Snap

class TrainingPaymentPage extends StatefulWidget { // Ubah nama kelas
  final String orderId;
  final String transactionToken;
  final String productName;
  final int amount;
  final String redirectUrl;

  const TrainingPaymentPage({
    super.key,
    required this.orderId,
    required this.transactionToken,
    required this.productName,
    required this.amount,
    required this.redirectUrl,
  });

  @override
  State<TrainingPaymentPage> createState() => _TrainingPaymentPageState(); // Ubah nama state
}

class _TrainingPaymentPageState extends State<TrainingPaymentPage> { // Ubah nama state
  String _paymentStatus = 'PENDING';
  bool _isCheckingStatus = false;
  String _message = 'Tap "Open Midtrans Payment Page" button below to pay for your training.'; // Sesuaikan pesan
  final String _baseUrl = 'http://localhost:3000/API';

  @override
  void initState() {
    super.initState();
    // Anda bisa menambahkan timer di sini untuk cek status otomatis
  }

  Future<void> _checkPaymentStatus() async {
    setState(() {
      _isCheckingStatus = true;
      _message = 'Checking payment status...';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in.', Colors.red);
        setState(() { _isCheckingStatus = false; });
        return;
      }

      // Gunakan endpoint yang spesifik untuk training payment status
      final response = await http.get(
        Uri.parse('$_baseUrl/user/trainings/payment-status/${widget.orderId}'), // Endpoint training payment status
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _paymentStatus = responseData['status'];
          _message = responseData['message'];
        });

        if (_paymentStatus == 'paid') {
          _showSnackBar('Payment successful! Training enrolled.', Colors.green); // Sesuaikan pesan
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          _showSnackBar(_message, Colors.orange);
        }
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to check payment status.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('An error occurred while checking status: $e', Colors.red);
      print('Error checking payment status: $e');
    } finally {
      setState(() {
        _isCheckingStatus = false;
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Complete Training Payment', style: TextStyle(color: Colors.white)), // Sesuaikan judul
        backgroundColor: const Color(0xFF007662),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Training: ${widget.productName}', // Sesuaikan teks
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: Rp ${widget.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              style: const TextStyle(color: Color(0xFFE8D864), fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            if (_paymentStatus == 'PENDING' || _paymentStatus == 'Creating Payment...') ...[
              const Text(
                'Please complete your payment via Midtrans.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(widget.redirectUrl))) {
                    await launchUrl(Uri.parse(widget.redirectUrl), mode: LaunchMode.externalApplication);
                  } else {
                    _showSnackBar('Could not launch payment page. URL: ${widget.redirectUrl}', Colors.red);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00DCB7),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Open Midtrans Payment Page', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isCheckingStatus ? null : _checkPaymentStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8D864),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isCheckingStatus
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text('Check Payment Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _paymentStatus == 'PENDING' ? Colors.orange : Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Midtrans payment link will typically expire in 10 minutes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ] else if (_paymentStatus == 'paid') ...[
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00DCB7),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Go to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              const Icon(Icons.cancel_outlined, color: Colors.red, size: 80),
              const SizedBox(height: 16),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8D864),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Go Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}