import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../services/storage_service.dart';
import '../../services/firestore_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthController>().user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showImagePickerSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.read<AuthController>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Change Profile Photo',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.camera_alt_rounded,
                    color: isDark ? AppColors.primaryBright : AppColors.primary),
                title: Text('Take Photo',
                    style: GoogleFonts.dmSans(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library_rounded,
                    color: isDark ? AppColors.primaryBright : AppColors.primary),
                title: Text('Choose from Gallery',
                    style: GoogleFonts.dmSans(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (auth.user?.profileImage != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error),
                  title: Text('Remove Photo',
                      style: GoogleFonts.dmSans(color: AppColors.error)),
                  onTap: () {
                    Navigator.pop(ctx);
                    final user = auth.user;
                    if (user != null) {
                      auth.updateUser(UserModel(
                        id: user.id,
                        name: user.name,
                        phone: user.phone,
                        email: user.email,
                        role: user.role,
                        profileImage: null,
                        createdAt: user.createdAt,
                        studentCode: user.studentCode,
                        counselorName: user.counselorName,
                        counselorPhone: user.counselorPhone,
                        parentName: user.parentName,
                        parentPhone: user.parentPhone,
                      ));
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null && mounted) {
      final auth = context.read<AuthController>();
      final user = auth.user;
      if (user == null) return;

      final useMock = dotenv.get('USE_MOCK', fallback: 'false') == 'true';
      if (useMock) {
        auth.updateUser(user.copyWith(profileImage: picked.path));
      } else {
        // Upload to Firebase Storage, store URL
        try {
          final url = await StorageService().uploadProfileImage(
            user.id,
            File(picked.path),
          );
          auth.updateUser(user.copyWith(profileImage: url));
          // Persist URL to Firestore
          await FirestoreService().updateDocument(
            FirestoreService().users,
            user.id,
            {'profileImage': url},
          );
        } catch (_) {
          // Fallback to local path
          auth.updateUser(user.copyWith(profileImage: picked.path));
        }
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    try {
      final auth = context.read<AuthController>();
      final user = auth.user;
      if (user == null) return;

      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      auth.updateUser(updatedUser);

      // Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', updatedUser.name);
      await prefs.setString('user_email', updatedUser.email ?? '');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthController>().user;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: 'Edit Profile',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Hero(
                      tag: 'profile-avatar',
                      child: CircleAvatar(
                        radius: 52,
                        backgroundColor: AppColors.primary
                            .withValues(alpha: isDark ? 0.2 : 0.1),
                        backgroundImage: user?.profileImage != null
                            ? (user!.profileImage!.startsWith('http')
                                ? NetworkImage(user.profileImage!)
                                : FileImage(File(user.profileImage!)))
                            : null,
                        child: user?.profileImage == null
                            ? Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name[0]
                                    : '?',
                                style: GoogleFonts.sora(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showImagePickerSheet(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isDark ? AppColors.surfaceDark : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Name field
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your name',
                      prefixIcon: Icons.person_outline_rounded,
                      validator: Validators.name,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 16),
                    // Phone (read-only)
                    CustomTextField(
                      controller:
                          TextEditingController(text: user?.phone ?? ''),
                      label: 'Phone',
                      hint: 'Phone number',
                      prefixIcon: Icons.phone_outlined,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Changes',
                icon: Icons.check_rounded,
                isLoading: _isSaving,
                onPressed: _isSaving ? null : _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
