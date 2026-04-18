import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final VoidCallback onSaved;
  const EditProfilePage({super.key, required this.currentName, required this.onSaved});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A18),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change Profile Photo',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF0EDE6),
                  ),
                ),
                const SizedBox(height: 20),
                _buildPickerOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Upload from Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
                _buildPickerOption(
                  icon: Icons.camera_alt_outlined,
                  label: 'Take a Photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_selectedImage != null) ...[
                  const SizedBox(height: 12),
                  _buildPickerOption(
                    icon: Icons.delete_outline,
                    label: 'Remove Photo',
                    color: const Color(0xFFE57373),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _selectedImage = null);
                    },
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final c = color ?? const Color(0xFFF0EDE6);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF222220),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: c,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}.',
              style: GoogleFonts.dmSans(color: const Color(0xFFF0EDE6)),
            ),
            backgroundColor: const Color(0xFF2E2E2B),
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _loading = true);

    try {
      // Upload photo if selected
      if (_selectedImage != null) {
        final uid = AuthService.currentUser!.uid;
        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child('$uid.jpg');
        await ref.putFile(_selectedImage!);
        final url = await ref.getDownloadURL();
        await AuthService.currentUser!.updatePhotoURL(url);
      }

      await AuthService.updateDisplayName(name);
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile',
                style: GoogleFonts.dmSans(color: Colors.white)),
            backgroundColor: const Color(0xFF1A1A18),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.currentName.isNotEmpty
        ? widget.currentName[0].toUpperCase()
        : 'A';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Back Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 41, height: 41,
                      decoration: const BoxDecoration(
                        color: Color(0xFF222220),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('‹',
                          style: GoogleFonts.dmSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w200,
                            color: const Color(0xFF9B9890),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Text('Edit Profile',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFF0EDE6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Avatar — tappable
              Center(
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Stack(
                    children: [
                      Container(
                        width: 90, height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A853).withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD4A853).withOpacity(0.4),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  width: 90,
                                  height: 90,
                                )
                              : AuthService.currentUser?.photoURL != null
                                  ? Image.network(
                                      AuthService.currentUser!.photoURL!,
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                    )
                                  : Center(
                                      child: Text(initial,
                                        style: GoogleFonts.playfairDisplay(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFD4A853),
                                        ),
                                      ),
                                    ),
                        ),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A853),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF0F0F0E), width: 2,
                            ),
                          ),
                          child: const Icon(Icons.edit,
                              size: 14, color: Color(0xFF0A0A09)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  _selectedImage != null ? 'Photo selected ✓' : 'Tap to change photo',
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: _selectedImage != null
                        ? const Color(0xFFD4A853)
                        : const Color(0xFF5C5A56),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Name Field
              Text('DISPLAY NAME',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9B9890),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD4A853)),
                ),
                child: TextField(
                  controller: _nameController,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF0EDE6),
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),

              const SizedBox(height: 16),

              Text('EMAIL',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9B9890),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF2E2E2B)),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AuthService.currentUser?.email ?? 'No email',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: const Color(0xFF5C5A56),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              GestureDetector(
                onTap: _save,
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A853),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2E2E2B)),
                  ),
                  child: Center(
                    child: Text('Save Changes',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0A0A09),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}