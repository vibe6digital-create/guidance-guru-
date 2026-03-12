import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'controllers/auth_controller.dart';
import 'controllers/theme_controller.dart';
import 'controllers/student_controller.dart';
import 'controllers/parent_controller.dart';
import 'controllers/counselor_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/otp_screen.dart';
import 'features/auth/role_selection_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/welcome_screen.dart';
import 'features/auth/select_counselor_signup_screen.dart';
import 'features/student/student_dashboard.dart';
import 'features/student/academic_form.dart';
import 'features/student/test_screen.dart';
import 'features/student/result_screen.dart';
import 'features/student/ai_report_screen.dart';
import 'features/student/remarks_screen.dart';
import 'features/student/test_history_screen.dart';
import 'features/student/reports_list_screen.dart';
import 'features/student/test_instructions_screen.dart';
import 'features/parent/parent_dashboard.dart';
import 'features/parent/link_student_screen.dart';
import 'features/parent/parent_report_view.dart';
import 'features/parent/counselling_proposal_screen.dart';
import 'features/parent/select_counselor_screen.dart';
import 'features/counselor/counselling_proposals_screen.dart';
import 'features/counselor/counselor_dashboard.dart';
import 'features/counselor/student_list.dart';
import 'features/counselor/student_detail.dart';
import 'features/counselor/add_remark_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/notifications/notification_screen.dart';
import 'features/notifications/notification_settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Use bundled fonts, don't fetch over network
  GoogleFonts.config.allowRuntimeFetching = false;

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style (dynamic based on theme handled by AppBarTheme)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(const GuidanceGuruApp());
}

class GuidanceGuruApp extends StatelessWidget {
  const GuidanceGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => StudentController()),
        ChangeNotifierProvider(create: (_) => ParentController()),
        ChangeNotifierProvider(create: (_) => CounselorController()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeCtrl, _) => MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeCtrl.themeMode,
          initialRoute: '/',
          onGenerateRoute: _generateRoute,
        ),
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case '/':
        page = const SplashScreen();
        break;
      case '/welcome':
        page = const WelcomeScreen();
        break;
      case '/login':
        page = const LoginScreen();
        break;
      case '/signup':
        page = const SignUpScreen();
        break;
      case '/otp':
        page = const OtpScreen();
        break;
      case '/role-selection':
        page = const RoleSelectionScreen();
        break;
      case '/select-counselor-signup':
        page = const SelectCounselorSignupScreen();
        break;
      // Student
      case '/student-dashboard':
        page = const StudentDashboard();
        break;
      case '/academic-form':
        page = const AcademicFormScreen();
        break;
      case '/test-instructions':
        page = const TestInstructionsScreen();
        break;
      case '/test':
        page = const TestScreen();
        break;
      case '/result':
        page = const ResultScreen();
        break;
      case '/ai-report':
        page = const AiReportScreen();
        break;
      case '/remarks':
        page = const RemarksScreen();
        break;
      case '/test-history':
        page = const TestHistoryScreen();
        break;
      case '/reports-list':
        page = const ReportsListScreen();
        break;
      // Parent
      case '/parent-dashboard':
        page = const ParentDashboard();
        break;
      case '/link-student':
        page = const LinkStudentScreen();
        break;
      case '/parent-report':
        page = const ParentReportView();
        break;
      case '/select-counselor':
        page = const SelectCounselorScreen();
        break;
      case '/counselling-proposal':
        page = const CounsellingProposalScreen();
        break;
      // Counselor
      case '/counselor-dashboard':
        page = const CounselorDashboard();
        break;
      case '/student-list':
        page = const StudentListScreen();
        break;
      case '/student-detail':
        page = const StudentDetailScreen();
        break;
      case '/add-remark':
        page = const AddRemarkScreen();
        break;
      case '/counselling-proposals':
        page = const CounsellingProposalsScreen();
        break;
      // Common
      case '/profile':
        page = const ProfileScreen();
        break;
      case '/notifications':
        page = const NotificationScreen();
        break;
      case '/edit-profile':
        page = const EditProfileScreen();
        break;
      case '/notification-settings':
        page = const NotificationSettingsScreen();
        break;
      default:
        page = const LoginScreen();
    }

    return _buildRoute(settings, page);
  }

  static const _authRoutes = {'/welcome', '/login', '/signup', '/otp', '/role-selection', '/select-counselor-signup'};
  static const _dashboardRoutes = {
    '/student-dashboard',
    '/parent-dashboard',
    '/counselor-dashboard',
  };
  static const _detailRoutes = {
    '/test',
    '/test-instructions',
    '/result',
    '/ai-report',
    '/student-detail',
    '/academic-form',
    '/remarks',
    '/parent-report',
    '/link-student',
    '/student-list',
    '/add-remark',
    '/notifications',
    '/test-history',
    '/reports-list',
    '/select-counselor',
    '/counselling-proposal',
    '/counselling-proposals',
  };
  static const _settingsRoutes = {
    '/profile',
    '/edit-profile',
    '/notification-settings',
  };

  Route<dynamic> _buildRoute(RouteSettings settings, Widget page) {
    final name = settings.name ?? '';

    // Splash — no transition
    if (name == '/') {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      );
    }

    // Auth flow — slide + fade from right
    if (_authRoutes.contains(name)) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      );
    }

    // Dashboards — fade-through (scale + fade)
    if (_dashboardRoutes.contains(name)) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      );
    }

    // Detail screens — bottom-to-top slide + fade
    if (_detailRoutes.contains(name)) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      );
    }

    // Settings — right-to-left slide
    if (_settingsRoutes.contains(name)) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          final curved =
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.15, 0),
              end: Offset.zero,
            ).animate(curved),
            child: FadeTransition(opacity: curved, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 250),
      );
    }

    // Default — slide + fade
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved =
            CurvedAnimation(parent: animation, curve: Curves.easeInOut);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
