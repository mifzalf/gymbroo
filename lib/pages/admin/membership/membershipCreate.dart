import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateMembershipPage extends StatefulWidget {
  @override
  _CreateMembershipPageState createState() => _CreateMembershipPageState();
}

class _CreateMembershipPageState extends State<CreateMembershipPage> {
  final TextEditingController _membershipTypeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  
  File? _backgroundImage;
  final ImagePicker _picker = ImagePicker();

  // Function to pick image
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _backgroundImage = File(image.path);
      });
    }
  }

  // Function to handle create membership
  void _createMembership() {
    // Implement create membership logic here
    print('Membership Type: ${_membershipTypeController.text}');
    print('Price: ${_priceController.text}');
    print('Duration: ${_durationController.text}');
    print('Background Image: $_backgroundImage');
    
    // Navigate back or show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Membership created successfully!')),
    );
  }

  // Function to navigate back to membership page
  void _navigateBack() {
    Navigator.pop(context);
    // Or navigate to specific membership page
    // Navigator.pushReplacementNamed(context, '/membershipPage');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _navigateBack,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF007662), Color(0xFF00DCB7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
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
            
            // Form content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    
                    // Background image upload section
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 192,
                        decoration: BoxDecoration(
                          color: Color(0xFF474242),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _backgroundImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
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
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
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
                                  SizedBox(height: 8),
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
                    
                    SizedBox(height: 24),
                    
                    // Membership type input
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF474242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _membershipTypeController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Membership type',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Price input
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF474242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _priceController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Price in IDR',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // Duration input
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF474242),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _durationController,
                        style: TextStyle(color: Colors.white),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Duration by month',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // Create button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _createMembership,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE6E886),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
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