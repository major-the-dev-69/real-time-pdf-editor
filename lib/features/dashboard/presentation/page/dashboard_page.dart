import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/style/colors/app_colors.dart';
import '../../../../widgets/app_logo_widget.dart';
import '../../../../widgets/custom_snack_bar.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/business_graph_widget.dart';
import '../widgets/dashboard_skeleton_widget.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        titleSpacing: 16,
        toolbarHeight: 65,
        title: Row(
          children: [
            const AppLogoWidget(height: 38, width: 38, showShadow: false),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  final name =
                      controller.dashboardData.value?.agentName ??
                      'Acumen Infra';
                  final displayName = name.isNotEmpty ? name : 'Acumen Infra';
                  return Row(
                    children: [
                      Text(
                        'Hello, $displayName',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('👋', style: TextStyle(fontSize: 14)),
                    ],
                  );
                }),
                const SizedBox(height: 2),
                Text(
                  'Welcome back to Sai Associates',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.notifications),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Iconsax.notification_copy,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const DashboardSkeletonWidget();
        }

        final data = controller.dashboardData.value;
        final agentName = data?.agentName ?? '';
        final agentId = data?.agentId ?? '';
        final mobile = data?.mobile ?? '';
        final status = data?.status ?? 'Active';
        final regDate = data?.joinDate ?? '';
        final actDate = data?.activationDate ?? '';
        final address = data?.address ?? '';

        final referralLink =
            'https://software.acumeninfra.org/NewRegistration.aspx?Id=$agentId';

        // Date Components
        final regDateMap = _parseDateComponents(regDate);
        final actDateMap = _parseDateComponents(actDate);

        // Formatted Values
        final selfBusiness = '₹ ${_formatCurrency(data?.selfBusiness ?? 0.0)}';
        final teamBusiness = '₹ ${_formatCurrency(data?.teamBusiness ?? 0.0)}';
        final totalBusiness =
            '₹ ${_formatCurrency(data?.totalBusiness ?? 0.0)}';

        final sponsorshipIncome =
            '₹ ${_formatCurrency(data?.directIncome ?? 0.0)}';
        final levelPlanIncome =
            '₹ ${_formatCurrency(data?.levelIncome ?? 0.0)}';
        final dstPlanIncome = '₹ ${_formatCurrency(data?.levelIncomeP ?? 0.0)}';
        final rewardIncome = '₹ ${_formatCurrency(data?.rewardIncome ?? 0.0)}';
        final paidOut = '₹ ${_formatCurrency(data?.paidAmt ?? 0.0)}';
        final balance = '₹ ${_formatCurrency(data?.balance ?? 0.0)}';

        final directActive = '${data?.dActive ?? 0}';
        final directInactive = '${data?.dInActive ?? 0}';
        final teamActive = '${data?.tActive ?? 0}';
        final teamInactive = '${data?.tInActive ?? 0}';
        final currentRank = data?.rewardName.isNotEmpty == true
            ? data!.rewardName
            : 'N/A';
        final position = data?.position.isNotEmpty == true
            ? data!.position
            : '';

        return RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Profile Header Card (Primary Orange Background)
                Hero(
                  tag: 'app_dashboard_header_hero',
                  child: Material(
                    type: MaterialType.transparency,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFD84315),
                            Color(0xFFE65100),
                            Color(0xFFEF6C00),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFD84315,
                            ).withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Info & Active Status Pill
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            agentName.isNotEmpty
                                                ? agentName
                                                : 'Acumen Infra',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: $agentId  •  Mobile: $mobile${address.isNotEmpty ? '  •  $address' : ''}',
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.95,
                                              ),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (position.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.35),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Iconsax.award_copy,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Position: $position',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Active Status Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: Text(
                                  status,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Row 3: Key Dates (Activation, Join, Registration)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(
                                              Iconsax.calendar_1_copy,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Registration Date',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          regDateMap['formattedDate']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (regDateMap['dayName']!
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            regDateMap['dayName']!,
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  VerticalDivider(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    thickness: 1,
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(
                                              Iconsax.flash_1_copy,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              'Activation Date',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          actDateMap['formattedDate']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (actDateMap['dayName']!
                                            .isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            actDateMap['dayName']!,
                                            style: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Referral Link Box with Copy Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Iconsax.link_copy,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Your Referral Link',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        referralLink,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: referralLink),
                                    );
                                    CustomSnackBar.showSuccess(
                                      message:
                                          'Referral link copied to clipboard!',
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Iconsax.copy_copy,
                                          color: AppColors.primary,
                                          size: 14,
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Copy Link',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Business Growth Graph Section
                const BusinessGraphWidget(),
                const SizedBox(height: 24),

                // 2. Quick Actions Header & Grid
                Text(
                  'Quick Actions',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                  ),
                ),
                const SizedBox(height: 10),

                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: [
                    _buildModernActionCard(
                      context,
                      title: 'Plots',
                      subtitle: 'Manage & View',
                      icon: Iconsax.building,
                      color: const Color(0xFF8B5CF6), // Purple
                      onTap: () => Get.toNamed(AppRoutes.plots),
                    ),
                    _buildModernActionCard(
                      context,
                      title: 'Teams',
                      subtitle: 'Manage Teams',
                      icon: Iconsax.people,
                      color: const Color(0xFF3B82F6), // Blue
                      onTap: () => Get.toNamed(AppRoutes.team),
                    ),
                    _buildModernActionCard(
                      context,
                      title: 'Business',
                      subtitle: 'Business Overview',
                      icon: Iconsax.briefcase,
                      color: const Color(0xFF10B981), // Emerald Green
                      onTap: () => Get.toNamed(AppRoutes.business),
                    ),
                    _buildModernActionCard(
                      context,
                      title: 'Income',
                      subtitle: 'Track Income',
                      icon: Iconsax.wallet_2,
                      color: AppColors.primary, // Orange
                      onTap: () => Get.toNamed(AppRoutes.incomes),
                    ),
                    _buildModernActionCard(
                      context,
                      title: 'New Register',
                      subtitle: 'Create New',
                      icon: Iconsax.user_add,
                      color: const Color(0xFFEC4899), // Pink
                      onTap: () => Get.toNamed(AppRoutes.newRegister),
                    ),
                    _buildModernActionCard(
                      context,
                      title: 'KYC',
                      subtitle: 'Update KYC',
                      icon: Iconsax.shield_tick,
                      color: const Color(0xFF2563EB), // Royal Blue
                      onTap: () => Get.toNamed(AppRoutes.kyc),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Dashboard Overview Section Header
                Text(
                  'Dashboard Overview',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Total Business & Available Balance Gradient Banner Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildGradientOverviewCard(
                        context,
                        title: 'Total Business',
                        value: totalBusiness,
                        subtitle: 'All time business',
                        gradientColors: const [
                          Color(0xFF6366F1), // Indigo
                          Color(0xFF818CF8),
                        ],
                        icon: Iconsax.bag_2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGradientOverviewCard(
                        context,
                        title: 'Available Balance',
                        value: balance,
                        subtitle: 'Withdraw or transfer',
                        gradientColors: const [
                          Color(0xFF10B981), // Emerald Teal
                          Color(0xFF34D399),
                        ],
                        icon: Iconsax.wallet_money,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4. Business Details Section
                Text(
                  'Business Details',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Business Details Breakdown Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.1,
                  children: [
                    _buildStatTile(
                      context,
                      title: 'Self Business',
                      value: selfBusiness,
                      icon: Iconsax.dollar_circle,
                    ),
                    _buildStatTile(
                      context,
                      title: 'Team Business',
                      value: teamBusiness,
                      icon: Iconsax.money_send,
                    ),
                    _buildStatTile(
                      context,
                      title: 'Direct Active',
                      value: directActive,
                      icon: Iconsax.user_tick,
                    ),
                    _buildStatTile(
                      context,
                      title: 'Direct In-Active',
                      value: directInactive,
                      icon: Iconsax.user_remove,
                    ),
                    _buildStatTile(
                      context,
                      title: 'Team Active',
                      value: teamActive,
                      icon: Iconsax.profile_2user,
                    ),
                    _buildStatTile(
                      context,
                      title: 'Team In-Active',
                      value: teamInactive,
                      icon: Iconsax.user_remove,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 5. Income Breakdown Section
                Text(
                  'Income Breakdown',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                  ),
                ),
                const SizedBox(height: 10),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.1,
                  children: [
                    _buildStatTile(
                      context,
                      title: 'Sponsorship Income',
                      value: sponsorshipIncome,
                      icon: Iconsax.user_tag,
                    ),
                    _buildStatTile(
                      context,
                      title: 'Level Plan Income',
                      value: levelPlanIncome,
                      icon: Iconsax.hierarchy_2,
                    ),
                    _buildStatTile(
                      context,
                      title: 'DST Plan Income',
                      value: dstPlanIncome,
                      icon: Iconsax.chart_1,
                    ),
                    _buildStatTile(
                      context,
                      title: 'Reward Income',
                      value: rewardIncome,
                      icon: Iconsax.cup,
                    ),
                    _buildStatTile(
                      context,
                      title: 'Paid Out',
                      value: paidOut,
                      icon: Iconsax.card_tick,
                    ),
                    _buildStatTile(
                      context,
                      title: 'Current Rank',
                      value: currentRank,
                      icon: Iconsax.award,
                      highlight: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),

      // Floating Center Button Bottom Navigation Bar
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    index: 0,
                    label: 'Home',
                    icon: Iconsax.home_2,
                  ),
                  _buildNavItem(
                    context,
                    index: 1,
                    label: 'Business',
                    icon: Iconsax.chart_2,
                  ),

                  // Floating Center Action Button "+"
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.newRegister),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF6366F1,
                            ).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),

                  _buildNavItem(
                    context,
                    index: 3,
                    label: 'Income',
                    icon: Iconsax.wallet_2,
                  ),
                  _buildNavItem(
                    context,
                    index: 2,
                    label: 'Profile',
                    icon: Iconsax.user,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = controller.currentIndex.value == index;
    final color = isSelected ? AppColors.primary : context.theme.hintColor;

    return GestureDetector(
      onTap: () {
        controller.changeIndex(index);
        if (index == 1) Get.toNamed(AppRoutes.business);
        if (index == 2) Get.toNamed(AppRoutes.profile);
        if (index == 3) Get.toNamed(AppRoutes.incomes);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _parseDateComponents(String rawDate) {
    if (rawDate.isEmpty) {
      return {'dayName': '', 'formattedDate': 'N/A'};
    }
    if (rawDate.contains(',')) {
      final parts = rawDate.split(',');
      final dayName = parts[0].trim();
      final datePart = parts[1].trim();
      return {'dayName': dayName, 'formattedDate': datePart};
    }
    return {'dayName': '', 'formattedDate': rawDate};
  }

  String _formatCurrency(double amount) {
    final str = amount.toStringAsFixed(2);
    final parts = str.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    final buffer = StringBuffer();
    int count = 0;

    for (int i = intPart.length - 1; i >= 0; i--) {
      if (count == 3 || (count > 3 && (count - 3) % 2 == 0)) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
      count++;
    }

    final formattedInt = buffer.toString().split('').reversed.join('');
    return '$formattedInt.$decPart';
  }

  Widget _buildModernActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Icon Container on Left & Circular Arrow Button on Right
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ],
              ),

              // Bottom Section: Title & Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverviewCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required List<Color> gradientColors,
    required IconData icon,
  }) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.5,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 10.5,
                ),
              ),
            ],
          ),

          // Sparkline Decoration Graphic on Bottom Right
          Positioned(
            right: 0,
            bottom: 0,
            width: 60,
            height: 30,
            child: CustomPaint(
              painter: SparklinePainter(
                color: Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    bool highlight = false,
  }) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;

    final primaryColor = highlight ? colorScheme.secondary : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? colorScheme.secondary.withValues(alpha: 0.6)
              : colorScheme.outline,
          width: highlight ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withValues(alpha: 0.85),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14.5,
              color: highlight ? colorScheme.secondary : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class SparklinePainter extends CustomPainter {
  final Color color;

  SparklinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
      size.width * 0.25,
      size.height * 0.9,
      size.width * 0.4,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.5,
    );
    path.cubicTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width * 0.85,
      size.height * 0.1,
      size.width,
      size.height * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
