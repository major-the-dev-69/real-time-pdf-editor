import 'package:get/get.dart';

import '../features/dashboard/binding/dashboard_binding.dart';
import '../features/dashboard/presentation/page/dashboard_page.dart';

import '../features/login/binding/forgot_password_binding.dart';
import '../features/login/binding/login_binding.dart';
import '../features/login/binding/splash_binding.dart';
import '../features/login/presentation/page/forgot_password_page.dart';
import '../features/login/presentation/page/login_page.dart';
import '../features/login/presentation/page/reset_password_page.dart';
import '../features/login/presentation/page/splash_page.dart';
import '../features/notification/binding/notification_binding.dart';
import '../features/notification/presentation/page/notification_page.dart';

import '../features/pdf/binding/pdf_binding.dart';
import '../features/pdf/presentation/page/pdf_detail_page.dart';
import '../features/pdf/presentation/page/pdf_form_page.dart';
import '../features/pdf/presentation/page/pdf_open_page.dart';
import '../features/profile/binding/profile_binding.dart';
import '../features/profile/presentation/page/profile_page.dart';
import '../features/project/binding/project_binding.dart';
import '../features/project/presentation/page/my_project_list_page.dart';
import '../features/project/presentation/page/project_form_page.dart';
import '../features/site/binding/site_binding.dart';
import '../features/site/presentation/page/site_form_page.dart';
import '../features/site/presentation/page/site_list_page.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const dashboard = '/dashboard';
  static const profile = '/profile';
  static const addProject = '/add-project';
  static const editProject = '/edit-project';
  static const myProjectList = '/my-project-list';
  static const siteList = '/site-list';
  static const addSite = '/add-site';
  static const editSite = '/edit-site';
  static const addPdf = '/add-pdf';
  static const editPdf = '/edit-pdf';
  static const incomes = '/incomes';
  static const business = '/business';
  static const team = '/team';
  static const newRegister = '/new-register';
  static const kyc = '/kyc';
  static const notifications = '/notifications';
  static const pdfDetail = '/pdf-detail';
  static const pdfOpen = '/pdf-open';
  static const welcomeLetter = '/welcome-letter';
  static const plots = '/plots';
  static const rewardIncomeDetail = '/reward-income-detail';
  static const customerDashboard = '/customer-dashboard';
  static const customerLedgerReport = '/customer-ledger-report';
  static const customerProfile = '/customer-profile';
}

class AppPages {
  AppPages._();

  static final List<GetPage> getPages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.resetPassword,
      page: () => const ResetPasswordPage(),
      binding: ForgotPasswordBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: ProfileBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.addProject,
      page: () => const ProjectFormPage(),
      binding: ProjectBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.editProject,
      page: () => const ProjectFormPage(),
      binding: ProjectBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.myProjectList,
      page: () => const MyProjectListPage(),
      binding: ProjectBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.siteList,
      page: () => const SiteListPage(),
      binding: SiteBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.addSite,
      page: () => const SiteFormPage(),
      binding: SiteBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.editSite,
      page: () => const SiteFormPage(),
      binding: SiteBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.addPdf,
      page: () => const PdfFormPage(),
      binding: PdfBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.editPdf,
      page: () => const PdfFormPage(),
      binding: PdfBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationPage(),
      binding: NotificationBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.pdfDetail,
      page: () => const PdfDetailPage(),
      binding: PdfBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.pdfOpen,
      page: () => const PdfOpenPage(),
      binding: PdfBinding(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 500),
    ),
  ];
}
