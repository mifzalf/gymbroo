import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io'; // For File class (non-web)
import 'dart:typed_data'; // For Uint8List (web)
import 'package:http/http.dart' as http; // For HTTP requests
import 'dart:convert'; // For JSON encoding/decoding
import 'package:flutter/foundation.dart' show kIsWeb; // To check if running on web
import 'package:mime/mime.dart'; // For mimeType lookup
import 'package:http_parser/http_parser.dart'; // For MediaType

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _profileImage; // Stores File on non-web platforms
  Uint8List? _profileImageBytes; // Stores image bytes on web
  XFile? _pickedXFile; // Stores XFile to get name and mimeType
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  final String _baseUrl = 'http://localhost:3000/API'; // Your backend URL

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Function to select profile image
  Future<void> _selectProfileImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        // For web, read as bytes
        final bytes = await image.readAsBytes();
        setState(() {
          _profileImageBytes = bytes;
          _profileImage = null; // Ensure File is null on web
          _pickedXFile = image; // Store XFile
        });
      } else {
        // For non-web, use File
        setState(() {
          _profileImage = File(image.path);
          _profileImageBytes = null; // Ensure bytes is null on non-web
          _pickedXFile = image; // Store XFile
        });
      }
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/register'),
        );

        request.fields['username'] = _usernameController.text;
        request.fields['email'] = _emailController.text;
        request.fields['password'] = _passwordController.text;
        request.fields['confirmationPassword'] = _confirmPasswordController.text;

        // Add profile photo file if selected
        if (kIsWeb && _pickedXFile != null) {
          final String? mimeType = lookupMimeType(_pickedXFile!.name);
          request.files.add(
            http.MultipartFile.fromBytes(
              'profile_photo', // Field name must match backend's upload.single('profile_photo')
              _profileImageBytes!,
              filename: _pickedXFile!.name, // Use original file name
              contentType: (mimeType != null) ? MediaType.parse(mimeType) : MediaType('image', 'jpeg'), // Default to jpeg if lookup fails
            ),
          );
        } else if (!kIsWeb && _profileImage != null) {
          final String? mimeType = lookupMimeType(_profileImage!.path);
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_photo', // Field name must match backend's upload.single('profile_photo')
              _profileImage!.path,
              filename: _pickedXFile?.name, // Use original XFile name if available
              contentType: (mimeType != null) ? MediaType.parse(mimeType) : null,
            ),
          );
        }

        var response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final decodedBody = json.decode(responseBody);

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration successful!'),
              backgroundColor: Colors.green,
            ),
          );
          _navigateToLogin();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(decodedBody['message'] ?? 'Registration failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    children: [
                      TextSpan(
                        text: 'Register ',
                        style: TextStyle(
                          color: const Color(0xFFE8D864),
                          fontFamily: Theme.of(context).textTheme.headlineLarge?.fontFamily,
                        ),
                      ),
                      const TextSpan(
                        text: 'your new\nAccount',
                        style: TextStyle(
                          color: Color(0xFF007662),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Profile Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _selectProfileImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: (_profileImage != null || _profileImageBytes != null)
                            ? const Color(0xFF4ECDC4)
                            : const Color(0xFF2D2D2D),
                        shape: BoxShape.circle,
                        // Display image based on platform
                        image: (_profileImage != null || _profileImageBytes != null)
                            ? DecorationImage(
                                image: kIsWeb ? MemoryImage(_profileImageBytes!) : FileImage(_profileImage!) as ImageProvider,
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: (_profileImage == null && _profileImageBytes == null)
                          ? const Icon(
                              Icons.add_a_photo,
                              color: Colors.white,
                              size: 30,
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Email Field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter Your Email',
                      hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                      prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF9E9E9E)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Username Field (Validasi dipermudah untuk mengizinkan spasi)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter Your Username',
                      hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
                      prefixIcon: Icon(Icons.person_outline, color: Color(0xFF9E9E9E)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      // Hanya validasi panjang yang dipertahankan
                      if (value.length < 1 || value.length > 30) {
                        return 'Username must be between 1 and 30 characters.';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Password Field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter Your Password',
                      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9E9E9E)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF9E9E9E),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters.';
                      }
                      if (!RegExp(r'[A-Z]').hasMatch(value)) {
                        return 'Password must have at least one uppercase letter.';
                      }
                      if (!RegExp(r'[a-z]').hasMatch(value)) {
                        return 'Password must have at least one lowercase letter.';
                      }
                      if (!RegExp(r'\d').hasMatch(value)) {
                        return 'Password must contain at least one number.';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Confirm Password Field
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: !_isConfirmPasswordVisible,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Confirm Your Password',
                      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9E9E9E)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF9E9E9E),
                        ),
                        onPressed: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8D864),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.black,
                          )
                        : const Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 60),

                // Bottom Navigation
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007662),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _navigateToLogin,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8D864),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            "Already have",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "Account? Sign in Now",
                            style: TextStyle(
                              color: Color(0xFFE8D864),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}