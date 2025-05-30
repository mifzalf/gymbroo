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

class EditTrainingPage extends StatefulWidget {
  final Map<String, dynamic> trainingData;

  const EditTrainingPage({super.key, required this.trainingData});

  @override
  _EditTrainingPageState createState() => _EditTrainingPageState();
}

class _EditTrainingPageState extends State<EditTrainingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _timeStartController = TextEditingController();
  final TextEditingController _totalSessionController = TextEditingController();
  final TextEditingController _trainerIdController = TextEditingController();

  File? _newBackgroundImage;
  Uint8List? _newBackgroundImageBytes;
  XFile? _pickedXFile;
  String? _currentBackgroundImageUrl;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  final String _baseUrl = 'http://localhost:3000/API';
  final String _imagePathPrefix = 'http://localhost:3000/images/trainings/';

  List<dynamic> _trainers = [];
  String? _selectedDay;
  int? _selectedTrainerId;

  final List<String> _daysOfWeek = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers with received training data
    _titleController.text = widget.trainingData['title'] ?? '';
    _descriptionController.text = widget.trainingData['description'] ?? '';
    _priceController.text = widget.trainingData['price']?.toString() ?? '';
    // Use the actual day value from backend if available, otherwise fallback
    _selectedDay = widget.trainingData['days']; // Set initial value for dropdown
    _timeStartController.text = widget.trainingData['time_start']?.substring(0, 5) ?? ''; // Format time_start
    _totalSessionController.text = widget.trainingData['total_session']?.toString() ?? '';
    
    // Set initial selected values for dropdowns
    _selectedTrainerId = widget.trainingData['trainer_id'];

    // Set URL for existing background image
    if (widget.trainingData['background'] != null && widget.trainingData['background'] != 'default.png') {
      _currentBackgroundImageUrl = _imagePathPrefix + widget.trainingData['background'];
    }

    _fetchTrainersForDropdown(); // Fetch trainers for dropdown
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _daysController.dispose();
    _timeStartController.dispose();
    _totalSessionController.dispose();
    _trainerIdController.dispose();
    super.dispose();
  }

  Future<void> _fetchTrainersForDropdown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _showSnackBar('Authentication token not found. Please log in again.', Colors.red);
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/admin/trainers'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _trainers = responseData['data'];
        });
      } else {
        final responseBody = json.decode(response.body);
        _showSnackBar(responseBody['message'] ?? 'Failed to load trainers for dropdown.', Colors.red);
      }
    } catch (e) {
      _showSnackBar('Error fetching trainers: $e', Colors.red);
      print('Error fetching trainers: $e');
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

  // >>> PERUBAHAN DI SINI: Format waktu ke HH:MM (24 jam)
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), // Force 24-hour format for picker
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeStartController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      });
    }
  }
  // <<< AKHIR PERUBAHAN

  // Function to handle updating a training
  void _updateTraining() async {
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
          'PATCH', // Using PATCH for update
          Uri.parse('$_baseUrl/admin/trainings/${widget.trainingData['id']}'),
        );
        request.headers['Authorization'] = 'Bearer $token';

        request.fields['title'] = _titleController.text;
        request.fields['description'] = _descriptionController.text;
        request.fields['price'] = _priceController.text;
        request.fields['days'] = _selectedDay ?? '';
        request.fields['timeStart'] = _timeStartController.text;
        request.fields['totalSession'] = _totalSessionController.text;
        request.fields['trainerId'] = _selectedTrainerId?.toString() ?? '';

        // Add background file if selected
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

        var response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final decodedBody = json.decode(responseBody);

        if (response.statusCode == 200) {
          _showSnackBar('Training updated successfully!', Colors.green);
          Navigator.pop(context, true);
        } else if (response.statusCode == 401 || response.statusCode == 403) {
          _showSnackBar(decodedBody['message'] ?? 'Unauthorized or forbidden.', Colors.red);
        } else {
          _showSnackBar(decodedBody['message'] ?? 'Failed to update training.', Colors.red);
        }
      } catch (e) {
        _showSnackBar('An error occurred: $e', Colors.red);
        print('Error updating training: $e');
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
                    'Edit Training Class',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Background image upload section
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: double.infinity,
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
                                    Icon(Icons.add_a_photo, color: Colors.grey, size: 40),
                                    const SizedBox(height: 8),
                                    Text('Add/Change Background Photo', style: TextStyle(color: Colors.grey[400])),
                                  ],
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title Input
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF474242), borderRadius: BorderRadius.circular(12)),
                        child: TextFormField(
                          controller: _titleController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: 'Training Name', hintStyle: TextStyle(color: Colors.grey[400]), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
                          validator: (value) => value == null || value.isEmpty ? 'Training Name is required.' : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Price Input
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF474242), borderRadius: BorderRadius.circular(12)),
                        child: TextFormField(
                          controller: _priceController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: 'Price (e.g., 50000)', hintStyle: TextStyle(color: Colors.grey[400]), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Price is required.';
                            if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Price must be a positive number.';
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Day Dropdown
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF474242), borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF474242),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: 'Select Day', hintStyle: TextStyle(color: Colors.grey[400]), border: InputBorder.none),
                          value: _selectedDay,
                          items: _daysOfWeek.map((String day) {
                            return DropdownMenuItem<String>(value: day, child: Text(day));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedDay = newValue;
                            });
                          },
                          validator: (value) => value == null || value.isEmpty ? 'Day is required.' : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Time Start Input (with time picker)
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF474242), borderRadius: BorderRadius.circular(12)),
                        child: TextFormField(
                          controller: _timeStartController,
                          style: const TextStyle(color: Colors.white),
                          readOnly: true,
                          onTap: () => _selectTime(context),
                          decoration: InputDecoration(
                            hintText: 'Start Time (e.g., 16:30)',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Start Time is required.' : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Total Session Input
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF474242), borderRadius: BorderRadius.circular(12)),
                        child: TextFormField(
                          controller: _totalSessionController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(hintText: 'Total Session (e.g., 8)', hintStyle: TextStyle(color: Colors.grey[400]), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Total Session is required.';
                            if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Total Session must be a positive number.';
                            return null;
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Trainer Dropdown
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF474242), borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: DropdownButtonFormField<int>(
                          dropdownColor: const Color(0xFF474242),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: 'Select Trainer', hintStyle: TextStyle(color: Colors.grey[400]), border: InputBorder.none),
                          value: _selectedTrainerId,
                          items: _trainers.map((dynamic trainer) {
                            return DropdownMenuItem<int>(value: trainer['id'], child: Text(trainer['username']));
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedTrainerId = newValue;
                            });
                          },
                          validator: (value) => value == null ? 'Trainer is required.' : null,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description Input (Multi-line)
                      Container(
                        decoration: BoxDecoration(color: const Color(0xFF474242), borderRadius: BorderRadius.circular(12)),
                        child: TextFormField(
                          controller: _descriptionController,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          decoration: InputDecoration(hintText: 'Description', hintStyle: TextStyle(color: Colors.grey[400]), border: InputBorder.none, contentPadding: const EdgeInsets.all(16)),
                          validator: (value) => value == null || value.isEmpty ? 'Description is required.' : null,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateTraining,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE6E886),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.black)
                              : const Text('Update', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 24),
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