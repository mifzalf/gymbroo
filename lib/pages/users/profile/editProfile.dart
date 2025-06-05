import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class EditProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhotoUrl;
  final String membershipStatus;

  const EditProfilePage({
    super.key,
    required this.userName,
    required this.userEmail,
    this.userPhotoUrl = '',
    this.membershipStatus = '',
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  File? _profileImage;
  Uint8List? _profileImageBytes;
  XFile? _pickedXFile;
  late String _currentDisplayedPhotoUrl;

  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final String _baseUrl = 'http://192.168.100.8:3000/API';
  final String _userImagePathPrefix = 'http://192.168.100.8:3000/images/users/';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.userEmail);
    _nameController = TextEditingController(text: widget.userName);
    _currentDisplayedPhotoUrl = widget.userPhotoUrl;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: color),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
          _profileImage = null;
          _pickedXFile = image;
          _currentDisplayedPhotoUrl = '';
        });
      } else {
        setState(() {
          _profileImage = File(image.path);
          _profileImageBytes = null;
          _pickedXFile = image;
          _currentDisplayedPhotoUrl = '';
        });
      }
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token == null) {
          _showSnackBar('Authentication token not found. Please log in again.', Colors.red);
          setState(() { _isLoading = false; });
          return;
        }

        var request = http.MultipartRequest(
          'PATCH',
          Uri.parse('$_baseUrl/user/profile'),
        );
        request.headers['Authorization'] = 'Bearer $token';

        request.fields['username'] = _nameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['password'] = _newPasswordController.text.isNotEmpty
            ? _newPasswordController.text
            : '';
        request.fields['confirmationPassword'] = _confirmPasswordController.text.isNotEmpty
            ? _confirmPasswordController.text
            : '';

        if (_profileImage != null || _profileImageBytes != null) {
          if (kIsWeb && _pickedXFile != null) {
            final String? mimeType = lookupMimeType(_pickedXFile!.name);
            request.files.add(
              http.MultipartFile.fromBytes(
                'profile_photo',
                _profileImageBytes!,
                filename: _pickedXFile!.name,
                contentType: (mimeType != null) ? MediaType.parse(mimeType) : MediaType('image', 'jpeg'),
              ),
            );
          } else if (!kIsWeb && _profileImage != null) {
            final String? mimeType = lookupMimeType(_profileImage!.path);
            request.files.add(
              await http.MultipartFile.fromPath(
                'profile_photo',
                _profileImage!.path,
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
          _showSnackBar('Profile updated successfully!', Colors.green);
          Navigator.pop(context); 
        } else {
          _showSnackBar(decodedBody['message'] ?? 'Failed to update profile. Please try again.', Colors.red);
        }
      } catch (e) {
        _showSnackBar('An error occurred: $e', Colors.red);
        print('Error updating profile: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF474242),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
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
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 120,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/gymstart.jpg'),
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
                            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              color: const Color(0xFF2D2D2D),
                              image: _profileImage != null
                                  ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover)
                                  : _profileImageBytes != null
                                      ? DecorationImage(image: MemoryImage(_profileImageBytes!), fit: BoxFit.cover)
                                      : _currentDisplayedPhotoUrl.isNotEmpty
                                          ? DecorationImage(
                                              image: CachedNetworkImageProvider(_currentDisplayedPhotoUrl),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                            ),
                            child: (_profileImage == null && _profileImageBytes == null && _currentDisplayedPhotoUrl.isEmpty)
                                ? const Icon(Icons.person, color: Colors.white, size: 40)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _currentDisplayedPhotoUrl.isEmpty ? 'Add Profile Photo' : 'Change Profile Photo',
                          style: TextStyle(color: Colors.grey[400], fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 24),

                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Email is required.';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Username',
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Username is required.';
                          if (!RegExp(r'^[a-zA-Z0-9._\s]+$').hasMatch(value)) return 'Username can only contain letters, numbers, spaces, dots, and underscores.'; // Tambahkan \s untuk spasi
                          if (RegExp(r'^\d+$').hasMatch(value)) return 'Username cannot be only numbers.';
                          if (value.contains('..')) return 'Username cannot have consecutive dots.';
                          if (value.endsWith('.')) return 'Username cannot end with a dot.';
                          if (value.length < 1 || value.length > 30) return 'Username must be between 1 and 30 characters.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _newPasswordController,
                        hintText: 'Enter New Password (optional)',
                        icon: Icons.lock,
                        obscureText: !_isNewPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(_isNewPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey[400]),
                          onPressed: () { setState(() { _isNewPasswordVisible = !_isNewPasswordVisible; }); },
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length < 6) return 'Password must be at least 6 characters.';
                            if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password must have at least one uppercase letter.';
                            if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password must have at least one lowercase letter.';
                            if (!RegExp(r'\d').hasMatch(value)) return 'Password must contain at least one number.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Confirm New Password (optional)',
                        icon: Icons.lock,
                        obscureText: !_isConfirmPasswordVisible,
                        suffixIcon: IconButton(
                          icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey[400]),
                          onPressed: () { setState(() { _isConfirmPasswordVisible = !_isConfirmPasswordVisible; }); },
                        ),
                        validator: (value) {
                          if (_newPasswordController.text.isNotEmpty) {
                            if (value == null || value.isEmpty) return 'Confirmation password is required.';
                            if (value != _newPasswordController.text) return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6E886),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text('Save', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
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
}