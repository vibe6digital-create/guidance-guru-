import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';

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
                        child: Text(
                          user?.name.isNotEmpty == true ? user!.name[0] : '?',
                          style: GoogleFonts.sora(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Photo upload available in full version')),
                          );
                        },
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
