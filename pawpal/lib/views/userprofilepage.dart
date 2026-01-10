import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pawpal/models/user.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/shared/mydrawer.dart';
import 'package:pawpal/shared/pawloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final User? user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final mainPink = const Color.fromRGBO(215, 54, 138, 1);
  final bgCream = const Color.fromRGBO(245, 234, 219, 1);

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  File? profileImage;
  Uint8List? webImage;
  String? currentProfileImageUrl;

  bool isEditing = false;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() {
    if (widget.user != null) {
      nameController.text = widget.user!.user_name ?? '';
      emailController.text = widget.user!.user_email ?? '';
      phoneController.text = widget.user!.user_phone ?? '';
      
      // Load profile image if exists
      if (widget.user!.profile_image != null &&
          widget.user!.profile_image!.isNotEmpty) {
        currentProfileImageUrl =
            "${MyConfig.baseUrl}/pawpal/assets/profiles/${widget.user!.profile_image}";
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: mainPink,
        foregroundColor: Colors.white,
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Image
            _buildProfileImage(),
            
            const SizedBox(height: 30),

            // Profile Form
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      enabled: isEditing,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      icon: Icons.email,
                      enabled: false, // Email cannot be changed
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: phoneController,
                      label: 'Phone Number',
                      icon: Icons.phone,
                      enabled: isEditing,
                    ),
                    
                    if (isEditing) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = false;
                                  loadUserData(); // Reset to original data
                                  profileImage = null;
                                  webImage = null;
                                });
                              },
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mainPink,
                              ),
                              onPressed: isLoading ? null : updateProfile,
                              child: isLoading
                                  ? PawLoading()
                                  : const Text(
                                      'Save',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Account Info
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: mainPink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoRow('User ID', widget.user?.user_id ?? 'N/A'),
                    _infoRow(
                      'Member Since',
                      widget.user?.user_reg_date != null
                          ? widget.user!.user_reg_date!.split(' ')[0]
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: mainPink, width: 4),
            boxShadow: [
              BoxShadow(
                color: mainPink.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: _getProfileImageWidget(),
          ),
        ),
        
        if (isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: pickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: mainPink,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _getProfileImageWidget() {
    if (webImage != null) {
      return Image.memory(webImage!, fit: BoxFit.cover);
    } else if (profileImage != null) {
      return Image.file(profileImage!, fit: BoxFit.cover);
    } else if (currentProfileImageUrl != null) {
      return Image.network(
        currentProfileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.person,
          size: 60,
          color: mainPink,
        ),
      );
    } else {
      return Icon(
        Icons.person,
        size: 60,
        color: mainPink,
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool enabled,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey[200],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            webImage = bytes;
          });
        } else {
          setState(() {
            profileImage = File(pickedFile.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> updateProfile() async {
    // Validation
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Name cannot be empty'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (phoneController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number must be at least 10 digits'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      String? imageBase64;
      
      // Convert image to base64 if changed
      if (kIsWeb && webImage != null) {
        imageBase64 = base64Encode(webImage!);
      } else if (profileImage != null) {
        final bytes = await profileImage!.readAsBytes();
        imageBase64 = base64Encode(bytes);
      }

      final body = {
        'user_id': widget.user?.user_id,
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'profile_image': imageBase64,
      };

      final response = await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/update_profile.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result['success']) {
          // Update local user object
          widget.user?.user_name = nameController.text.trim();
          widget.user?.user_phone = phoneController.text.trim();
          
          if (result['profile_image'] != null) {
            widget.user?.profile_image = result['profile_image'];
            currentProfileImageUrl =
                "${MyConfig.baseUrl}/pawpal/assets/profiles/${result['profile_image']}";
          }

          // Save to SharedPreferences
          await saveUserSession();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );

          setState(() {
            isEditing = false;
            profileImage = null;
            webImage = null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Update failed'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> saveUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', widget.user?.user_id ?? '');
    await prefs.setString('user_name', widget.user?.user_name ?? '');
    await prefs.setString('user_email', widget.user?.user_email ?? '');
    await prefs.setString('user_phone', widget.user?.user_phone ?? '');
    await prefs.setString('profile_image', widget.user?.profile_image ?? '');
  }
}