import 'package:get/get.dart';

import '../features/dashboard/binding/dashboard_binding.dart';
import '../features/dashboard/presentation/page/dashboard_page.dart';

import '../features/login/binding/login_binding.dart';
import '../features/login/binding/splash_binding.dart';
import '../features/login/presentation/page/login_page.dart';
import '../features/login/presentation/page/splash_page.dart';
import '../features/notification/binding/notification_binding.dart';
import '../features/notification/presentation/page/notification_page.dart';

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const dashboard = '/dashboard';
  static const profile = '/profile';
  static const incomes = '/incomes';
  static const business = '/business';
  static const team = '/team';
  static const newRegister = '/new-register';
  static const kyc = '/kyc';
  static const notifications = '/notifications';
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
      name: AppRoutes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
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
  ];
}
