import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/student_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_textfield.dart';
import '../../core/widgets/glass_app_bar.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/gradient_card.dart';
import '../../models/student_academic_model.dart';

class AcademicFormScreen extends StatefulWidget {
  const AcademicFormScreen({super.key});

  @override
  State<AcademicFormScreen> createState() => _AcademicFormScreenState();
}

class _AcademicFormScreenState extends State<AcademicFormScreen> {
  int _currentStep = 0;
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());

  // Step 1: Class 10
  final _math10 = TextEditingController();
  final _science10 = TextEditingController();
  final _english10 = TextEditingController();
  final _hindi10 = TextEditingController();
  final _social10 = TextEditingController();

  // Step 2: Class 12
  String _stream12 = 'Science';
  final _sub1_12 = TextEditingController();
  final _sub2_12 = TextEditingController();
  final _sub3_12 = TextEditingController();
  final _english12 = TextEditingController();

  // Step 3: Graduation
  final _gradPercentage = TextEditingController();
  final _gradField = TextEditingController();

  // Step 4: PG
  final _pgPercentage = TextEditingController();
  final _pgField = TextEditingController();

  final _streams = ['Science', 'Commerce', 'Arts', 'Vocational'];

  @override
  void dispose() {
    _math10.dispose();
    _science10.dispose();
    _english10.dispose();
    _hindi10.dispose();
    _social10.dispose();
    _sub1_12.dispose();
    _sub2_12.dispose();
    _sub3_12.dispose();
    _english12.dispose();
    _gradPercentage.dispose();
    _gradField.dispose();
    _pgPercentage.dispose();
    _pgField.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeys[_currentStep].currentState?.validate() ?? false) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _submitForm();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _submitForm() {
    final auth = context.read<AuthController>();
    final studentId = auth.user?.id ?? 'unknown';

    final class10Marks = <SubjectMark>[
      SubjectMark(subject: 'Mathematics', marks: double.tryParse(_math10.text) ?? 0),
      SubjectMark(subject: 'Science', marks: double.tryParse(_science10.text) ?? 0),
      SubjectMark(subject: 'English', marks: double.tryParse(_english10.text) ?? 0),
      SubjectMark(subject: 'Hindi/Language', marks: double.tryParse(_hindi10.text) ?? 0),
      SubjectMark(subject: 'Social Science', marks: double.tryParse(_social10.text) ?? 0),
    ];

    final class12Marks = <SubjectMark>[
      SubjectMark(subject: 'Subject 1', marks: double.tryParse(_sub1_12.text) ?? 0),
      SubjectMark(subject: 'Subject 2', marks: double.tryParse(_sub2_12.text) ?? 0),
      SubjectMark(subject: 'Subject 3', marks: double.tryParse(_sub3_12.text) ?? 0),
      SubjectMark(subject: 'English', marks: double.tryParse(_english12.text) ?? 0),
    ];

    final class10Avg = class10Marks.fold<double>(0, (sum, m) => sum + m.marks) / class10Marks.length;
    final class12Avg = class12Marks.fold<double>(0, (sum, m) => sum + m.marks) / class12Marks.length;

    final academicData = StudentAcademicModel(
      studentId: studentId,
      class10Marks: class10Marks,
      class10Percentage: class10Avg,
      class12Marks: class12Marks,
      class12Percentage: class12Avg,
      class12Stream: _stream12,
      graduationField: _gradField.text.isNotEmpty ? _gradField.text : null,
      graduationPercentage: double.tryParse(_gradPercentage.text),
      pgField: _pgField.text.isNotEmpty ? _pgField.text : null,
      pgPercentage: double.tryParse(_pgPercentage.text),
    );

    final controller = context.read<StudentController>();
    controller.updateAcademicData(academicData);
    controller.submitAcademicData();
    Navigator.pushNamed(context, '/test');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassScaffold(
      appBar: GlassAppBar(
        title: AppStrings.academicDetails,
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Row(
              children: List.generate(4, (i) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? AppColors.primary
                          : isDark ? AppColors.dividerDark : AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _stepTitle(_currentStep),
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.primaryBright : AppColors.primary,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1}/4',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildStep(_currentStep),
              ),
            ),
          ),
          // Bottom buttons
          Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: CustomButton(
                      text: 'Back',
                      isOutlined: true,
                      onPressed: _previousStep,
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: _currentStep == 0 ? 1 : 1,
                  child: CustomButton(
                    text: _currentStep == 3 ? 'Start Test' : 'Next',
                    icon: _currentStep == 3
                        ? Icons.play_arrow_rounded
                        : Icons.arrow_forward_rounded,
                    onPressed: _nextStep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return AppStrings.class10Marks;
      case 1:
        return AppStrings.class12Marks;
      case 2:
        return AppStrings.graduationMarks;
      case 3:
        return AppStrings.pgMarks;
      default:
        return '';
    }
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return _buildClass10Form();
      case 1:
        return _buildClass12Form();
      case 2:
        return _buildGraduationForm();
      case 3:
        return _buildPgForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildClass10Form() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _formKeys[0],
      child: Column(
        key: const ValueKey(0),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter your Class 10 subject-wise marks',
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                const SizedBox(height: 16),
                _MarksField(controller: _math10, label: 'Mathematics'),
                const SizedBox(height: 12),
                _MarksField(controller: _science10, label: 'Science'),
                const SizedBox(height: 12),
                _MarksField(controller: _english10, label: 'English'),
                const SizedBox(height: 12),
                _MarksField(controller: _hindi10, label: 'Hindi/Language'),
                const SizedBox(height: 12),
                _MarksField(controller: _social10, label: 'Social Science'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClass12Form() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _formKeys[1],
      child: Column(
        key: const ValueKey(1),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select your stream and enter marks',
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                const SizedBox(height: 16),
                // Stream selector
                DropdownButtonFormField<String>(
                  value: _stream12,
                  decoration: InputDecoration(
                    labelText: 'Stream',
                    prefixIcon: const Icon(Icons.category_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                  ),
                  items: _streams
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) => setState(() => _stream12 = v ?? 'Science'),
                ),
                const SizedBox(height: 12),
                _MarksField(controller: _sub1_12, label: 'Subject 1'),
                const SizedBox(height: 12),
                _MarksField(controller: _sub2_12, label: 'Subject 2'),
                const SizedBox(height: 12),
                _MarksField(controller: _sub3_12, label: 'Subject 3'),
                const SizedBox(height: 12),
                _MarksField(controller: _english12, label: 'English'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraduationForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _formKeys[2],
      child: Column(
        key: const ValueKey(2),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Graduation Details',
                        style: GoogleFonts.sora(
                            fontSize: 16, fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.successBright : AppColors.success).withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Optional',
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: isDark ? AppColors.successBright : AppColors.success)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _gradField,
                  label: 'Field of Study',
                  hint: 'e.g., Computer Science',
                  prefixIcon: Icons.book_outlined,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _gradPercentage,
                  label: 'Percentage / CGPA',
                  hint: 'e.g., 85.5',
                  prefixIcon: Icons.percent,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPgForm() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Form(
      key: _formKeys[3],
      child: Column(
        key: const ValueKey(3),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Post Graduation Details',
                        style: GoogleFonts.sora(
                            fontSize: 16, fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.successBright : AppColors.success).withValues(alpha: isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Optional',
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: isDark ? AppColors.successBright : AppColors.success)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _pgField,
                  label: 'Field of Study',
                  hint: 'e.g., MBA, M.Tech',
                  prefixIcon: Icons.book_outlined,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: _pgPercentage,
                  label: 'Percentage / CGPA',
                  hint: 'e.g., 8.5',
                  prefixIcon: Icons.percent,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SurfaceCard(
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: isDark ? AppColors.primaryBright : AppColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You can skip optional sections. The more data you provide, the better your career recommendations will be.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarksField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _MarksField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      label: label,
      hint: 'Out of 100',
      prefixIcon: Icons.grade_outlined,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
        LengthLimitingTextInputFormatter(5),
      ],
      validator: Validators.marks,
    );
  }
}
