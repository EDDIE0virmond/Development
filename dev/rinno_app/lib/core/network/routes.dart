// lib/core/network/routes.dart
import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/loading_entry_page.dart';
import '../../features/auth/presentation/pages/landing_page.dart';
import '../../features/auth/presentation/pages/leading_log_in_page.dart';
import '../../features/auth/presentation/pages/log_in_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/dashboard/presentation/pages/comon_user_page.dart';
import '../../features/dashboard/presentation/pages/master_user_page.dart';
import '../../features/dashboard/presentation/pages/admin_user_page.dart';
import '../../features/dashboard/presentation/pages/user_management_page.dart';

class AppRoutes {
  static const String loadingEntry = '/';
  static const String landing = '/landing';
  static const String leadingLogIn = '/leading-login';
  static const String logIn = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String comonUser = '/comon-user';
  static const String masterUser = '/master-user';
  static const String adminUser = '/admin-user';
  static const String userManagement = '/user-management';

  static Map<String, WidgetBuilder> get routes => {
    loadingEntry: (context) => const LoadingEntryPage(),
    landing: (context) => const LandingPage(),
    leadingLogIn: (context) => const LeadingLogInPage(),
    logIn: (context) => const LogInPage(),
    register: (context) => const RegisterPage(),
    forgotPassword: (context) => const ForgotPasswordPage(),
    resetPassword: (context) => ResetPasswordPage(
      token: ModalRoute.of(context)?.settings.arguments as String? ?? '',
    ),
    comonUser: (context) => const ComonUserPage(),
    masterUser: (context) => const MasterUserPage(),
    adminUser: (context) => const AdminUserPage(),
    userManagement: (context) => const UserManagementPage(),
  };
}