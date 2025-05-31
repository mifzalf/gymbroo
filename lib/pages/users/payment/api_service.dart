import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Digunakan jika nanti ada QR string langsung dari Midtrans
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk membuka URL Midtrans Snap

class MembershipPaymentPage extends StatefulWidget {
  final String orderId;
  final String transactionToken; // Midtrans token for payment (not directly used for display in this UI, but good to have)
  final String productName;
  final int amount;
  final String redirectUrl; // Midtrans Snap redirect URL (halaman pembayaran)

  const MembershipPaymentPage({
    super.key,
    required this.orderId,
    required this.transactionToken,
    required this.productName,
    required this.amount,
    required this.redirectUrl,
  });

  @override
  State<MembershipPaymentPage> createState() => _MembershipPaymentPageState();
}

class _MembershipPaymentPageState extends State<MembershipPaymentPage> {
  String _paymentStatus = 'PENDING'; // Status awal
  bool _isCheckingStatus = false;
  String _message = 'Tap "Open Midtrans Payment Page" button below to pay via QRIS.';
  final String _baseUrl = 'http://localhost:3000/API'; // URL backend Anda

  @override
  void initState() {
    super.initState();
    // Anda bisa menambahkan timer di sini untuk cek status otomatis
    // Atau hanya mengandalkan tombol manual seperti yang diminta.
  }

  // Fungsi untuk mengecek status pembayaran ke backend
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

      final response = await http.get(
        Uri.parse('$_baseUrl/user/memberships/payment-status/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _paymentStatus = responseData['status']; // 'paid', 'pending', 'failed', 'expire', 'cancel', 'unknown'
          _message = responseData['message']; // Message from backend
        });

        if (_paymentStatus == 'paid') {
          _showSnackBar('Payment successful! Membership activated.', Colors.green);
          // Opsi: Kembali ke DashboardUser atau halaman sukses lainnya
          Navigator.popUntil(context, (route) => route.isFirst); // Kembali ke root (DashboardUser)
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
        title: const Text('Complete Payment', style: TextStyle(color: Colors.white)),
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
              'Product: ${widget.productName}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: Rp ${widget.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}',
              style: const TextStyle(color: Color(0xFFE8D864), fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Display Payment Instructions / QR / Status
            if (_paymentStatus == 'PENDING' || _paymentStatus == 'Creating Payment...') ...[
              const Text(
                'Please complete your payment via Midtrans.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              // Tombol untuk membuka halaman pembayaran Midtrans Snap
              ElevatedButton(
                onPressed: () async {
                  if (await canLaunchUrl(Uri.parse(widget.redirectUrl))) {
                    await launchUrl(Uri.parse(widget.redirectUrl), mode: LaunchMode.externalApplication); // Open in external browser
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
              // Tombol untuk cek status manual
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
                  Navigator.popUntil(context, (route) => route.isFirst); // Go back to main dashboard
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
                  Navigator.pop(context); // Go back to membership selection to try again
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