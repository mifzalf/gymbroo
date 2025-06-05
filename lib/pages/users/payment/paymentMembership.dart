import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MembershipPaymentPage extends StatefulWidget {
  final String orderId;
  final String transactionToken; 
  final String productName;
  final int amount;
  final String redirectUrl;

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
  String _paymentStatus = 'PENDING';
  bool _isCheckingStatus = false;
  String _message = 'Tap "Open Midtrans Payment Page" button below to pay.'; 
  final String _baseUrl = 'http://192.168.100.8:3000/API'; 

  @override
  void initState() {
    super.initState();
    print('Halaman Pembayaran Dimuat. Order ID: ${widget.orderId}, Redirect URL: ${widget.redirectUrl}');
    if (widget.redirectUrl.isEmpty) {
      _message = 'Error: Payment URL not provided. Please try again.';
    }
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

      final response = await http.get(
        Uri.parse('$_baseUrl/user/memberships/payment-status/${widget.orderId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          _paymentStatus = responseData['status'] ?? 'unknown'; 
          _message = responseData['message'] ?? 'Status successfully checked.';
        });

        if (_paymentStatus.toLowerCase() == 'paid' || _paymentStatus.toLowerCase() == 'settlement') { 
          _showSnackBar('Payment successful! Membership activated.', Colors.green);
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          _showSnackBar(_message, _paymentStatus.toLowerCase() == 'pending' ? Colors.orange : Colors.blue);
        }
      } else {
        _showSnackBar(responseData['message'] ?? 'Failed to check payment status. Code: ${response.statusCode}', Colors.red);
      }
    } catch (e) {
      print('Error checking payment status: $e');
      if (mounted) {
        _showSnackBar('An error occurred while checking status: $e', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  Future<void> _launchPaymentUrl() async {
    print('Mencoba membuka URL Midtrans: ${widget.redirectUrl}');

    if (widget.redirectUrl.isEmpty) {
      _showSnackBar('Payment URL is not available. Cannot proceed.', Colors.red);
      print('Error: redirectUrl kosong.');
      return;
    }

    try {
      final Uri urlToLaunch = Uri.parse(widget.redirectUrl);

      if (!['http', 'https'].contains(urlToLaunch.scheme)) {
          _showSnackBar('Invalid URL scheme: ${urlToLaunch.scheme}', Colors.red);
          print('Error: Skema URL tidak valid - ${urlToLaunch.scheme}');
          return;
      }

      if (await canLaunchUrl(urlToLaunch)) {
        await launchUrl(urlToLaunch, mode: LaunchMode.externalApplication);
      } else {
        print('Tidak bisa membuka URL (canLaunchUrl false): ${widget.redirectUrl}');
        _showSnackBar('Could not launch payment page. Please ensure you have a web browser installed or check the URL.', Colors.red);
      }
    } catch (e) {
      print('Error saat parsing atau membuka URL: $e');
      _showSnackBar('Error opening payment page: $e', Colors.red);
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
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            Text(
              'Product: ${widget.productName}',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: Rp ${widget.amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')},-', // Tambah ,-
              style: const TextStyle(color: Color(0xFFE8D864), fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32), 

            if (widget.redirectUrl.isEmpty && _paymentStatus == 'PENDING') ...[
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                const Text(
                'Failed to get payment URL. Please go back and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ] else if (_paymentStatus == 'PENDING' || _paymentStatus == 'Creating Payment...' || _paymentStatus.toLowerCase() == 'pending') ...[ // Kondisi lebih fleksibel
              const Text(
                'Please complete your payment via Midtrans.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _launchPaymentUrl,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00DCB7),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(200, 50), 
                ),
                child: const Text('Open Midtrans Payment Page'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isCheckingStatus ? null : _checkPaymentStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE8D864),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  minimumSize: const Size(200, 50), 
                ),
                child: _isCheckingStatus
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                    : const Text('Check Payment Status'),
              ),
              const SizedBox(height: 20),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _paymentStatus.toLowerCase() == 'pending' ? Colors.orangeAccent : Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Midtrans payment link will typically expire in 10 minutes.', 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ] else if (_paymentStatus.toLowerCase() == 'paid' || _paymentStatus.toLowerCase() == 'settlement') ...[
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Go to Dashboard'),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Try Again or Go Back'),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}