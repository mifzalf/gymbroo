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

class EditMembershipPage extends StatefulWidget {
  final Map<String, dynamic> membership;

  const EditMembershipPage({super.key, required this.membership});

  @override
  _EditMembershipPageState createState() => _EditMembershipPageState();
}

class _EditMembershipPageState extends State<EditMembershipPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _membershipTypeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  File? _newBackgroundImage; 
  Uint8List? _newBackgroundImageBytes; 
  XFile? _pickedXFile; 
  String? _currentBackgroundImageUrl; 
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final String _baseUrl = 'http://192.168.100.8:3000/API'; 
  final String _imagePathPrefix = 'http://192.168.100.8:3000/images/memberships/'; 

  @override
  void initState() {
    super.initState();
    _membershipTypeController.text = widget.membership['membership_type'] ?? '';
    _priceController.text = widget.membership['price']?.toString() ?? '';
    _durationController.text = widget.membership['membership_duration']?.toString() ?? '';
    
    if (widget.membership['background'] != null && widget.membership['background'] != 'default.png') {
      _currentBackgroundImageUrl = _imagePathPrefix + widget.membership['background'];
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _newBackgroundImageBytes = bytes;
          _newBackgroundImage = null;
          _currentBackgroundImageUrl = null; 
          _pickedXFile = image; 
        });
      } else {
        setState(() {
          _newBackgroundImage = File(image.path);
          _newBackgroundImageBytes = null;
          _currentBackgroundImageUrl = null; 
          _pickedXFile = image; 
        });
      }
    }
  }

  void _editMembership() async {
    if (_formKey.currentState!.validate()) {
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
          'PATCH', 
          Uri.parse('$_baseUrl/admin/memberships/${widget.membership['id']}'),
        );
        request.headers['Authorization'] = 'Bearer $token';

        request.fields['membershipDuration'] = _durationController.text;
        request.fields['price'] = _priceController.text;
        request.fields['membershipType'] = _membershipTypeController.text;

        if (_newBackgroundImage != null || _newBackgroundImageBytes != null) {
          if (kIsWeb && _pickedXFile != null) {
            final String? mimeType = lookupMimeType(_pickedXFile!.name);
            request.files.add(
              http.MultipartFile.fromBytes(
                'background',
                _newBackgroundImageBytes!,
                filename: _pickedXFile!.name,
                contentType: (mimeType != null) ? MediaType.parse(mimeType) : MediaType('image', 'jpeg'),
              ),
            );
          } else if (!kIsWeb && _newBackgroundImage != null) {
            final String? mimeType = lookupMimeType(_newBackgroundImage!.path);
            request.files.add(
              await http.MultipartFile.fromPath(
                'background',
                _newBackgroundImage!.path,
                filename: _pickedXFile?.name,
                contentType: (mimeType != null) ? MediaType.parse(mimeType) : null,
              ),
            );
          }
        }

        var response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final decodedBody = json.decode(responseBody);

        if (response.statusCode == 200) { 
          _showSnackBar('Membership updated successfully!', Colors.green);
          Navigator.pop(context, true);
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          _showSnackBar(decodedBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
        } else {
          _showSnackBar(decodedBody['message'] ?? 'Failed to update membership.', Colors.red);
        }
      } catch (e) {
        _showSnackBar('An error occurred: $e', Colors.red);
        print('Error updating membership: $e');
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
            // Header
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
                    'Edit Membership Type',
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
                            image: _newBackgroundImage != null
                                ? DecorationImage(image: FileImage(_newBackgroundImage!), fit: BoxFit.cover)
                                : _newBackgroundImageBytes != null
                                    ? DecorationImage(image: MemoryImage(_newBackgroundImageBytes!), fit: BoxFit.cover)
                                    : _currentBackgroundImageUrl != null
                                        ? DecorationImage(image: NetworkImage(_currentBackgroundImageUrl!), fit: BoxFit.cover)
                                        : null,
                          ),
                          child: (_newBackgroundImage == null && _newBackgroundImageBytes == null && _currentBackgroundImageUrl == null)
                              ? Column(
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
                                )
                              : null,
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
                          onPressed: _isLoading ? null : _editMembership,
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
                                  'Edit',
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