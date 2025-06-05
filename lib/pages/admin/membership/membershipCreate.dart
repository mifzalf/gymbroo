import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime/mime.dart'; 
import 'package:http_parser/http_parser.dart';

class CreateMembershipPage extends StatefulWidget {
  const CreateMembershipPage({super.key});

  @override
  _CreateMembershipPageState createState() => _CreateMembershipPageState();
}

class _CreateMembershipPageState extends State<CreateMembershipPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _membershipTypeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  File? _backgroundImage; 
  Uint8List? _backgroundImageBytes; 
  XFile? _pickedXFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final String _baseUrl = 'http://192.168.100.8:3000/API'; 

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _backgroundImageBytes = bytes;
          _backgroundImage = null;
          _pickedXFile = image;
        });
      } else {
        setState(() {
          _backgroundImage = File(image.path);
          _backgroundImageBytes = null;
          _pickedXFile = image; 
        });
      }
    }
  }

  void _createMembership() async {
    if (_formKey.currentState!.validate()) {
      if (_backgroundImage == null && _backgroundImageBytes == null) {
        _showSnackBar('Background image is required.', Colors.red);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token == null) {
          _showSnackBar('Authentication token not found. Please log in again.', Colors.red);
          return;
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/admin/memberships'),
        );
        request.headers['Authorization'] = 'Bearer $token';

        request.fields['membershipDuration'] = _durationController.text;
        request.fields['price'] = _priceController.text;
        request.fields['membershipType'] = _membershipTypeController.text;

        // Add file based on platform
        if (kIsWeb && _pickedXFile != null) {
          final String? mimeType = lookupMimeType(_pickedXFile!.name);
          request.files.add(
            http.MultipartFile.fromBytes(
              'background', 
              _backgroundImageBytes!,
              filename: _pickedXFile!.name,
              contentType: (mimeType != null) ? MediaType.parse(mimeType) : MediaType('image', 'jpeg'),
            ),
          );
        } else if (!kIsWeb && _backgroundImage != null) {
          final String? mimeType = lookupMimeType(_backgroundImage!.path);
          request.files.add(
            await http.MultipartFile.fromPath(
              'background', 
              _backgroundImage!.path,
              filename: _pickedXFile?.name, 
              contentType: (mimeType != null) ? MediaType.parse(mimeType) : null,
            ),
          );
        }

        var response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final decodedBody = json.decode(responseBody);

        if (response.statusCode == 200) { 
          _showSnackBar('Membership created successfully!', Colors.green);
          Navigator.pop(context, true);
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          _showSnackBar(decodedBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
        } else {
          _showSnackBar(decodedBody['message'] ?? 'Failed to create membership.', Colors.red);
        }
      } catch (e) {
        _showSnackBar('An error occurred: $e', Colors.red);
        print('Error creating membership: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
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
                    'Create Membership Type',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: double.infinity,
                          height: 192,
                          decoration: BoxDecoration(
                            color: const Color(0xFF474242),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: (_backgroundImage != null || _backgroundImageBytes != null)
                              ? Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: kIsWeb
                                          ? Image.memory(
                                              _backgroundImageBytes!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              _backgroundImage!,
                                              width: double.infinity,
                                              height: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.grey[400],
                                      size: 40,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Background Image',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF474242),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _membershipTypeController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Membership Type',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Membership type is required.';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF474242),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _priceController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Price in IDR',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Price is required.';
                            }
                            if (int.tryParse(value) == null || int.parse(value) <= 0) {
                              return 'Price must be a positive number.';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF474242),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextFormField(
                          controller: _durationController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Duration in months',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Duration is required.';
                            }
                            if (int.tryParse(value) == null || int.parse(value) <= 0) {
                              return 'Duration must be a positive number.';
                            }
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _createMembership,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6E886),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text(
                                  'Create',
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
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _membershipTypeController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}