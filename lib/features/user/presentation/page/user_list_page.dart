import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sai_associates/app/app_routes.dart';
import 'package:sai_associates/core/utils/app_assets.dart';

import '../controller/user_controller.dart';
import '../../model/user_model.dart';

class UserListPage extends GetView<UserController> {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(AppAssets.backArrow),
        ),
        actions: [
          IconButton(
            tooltip: 'Add User',
            onPressed: () {
              Get.toNamed(AppRoutes.userForm);
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppAssets.icUserAdd,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Filter Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  // Search TextField
                  TextField(
                    onChanged: controller.updateSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'Search user by name, email or mobile...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Iconsax.search_normal_1_copy,
                        size: 20,
                      ),
                      suffixIcon: Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(
                              Iconsax.close_circle_copy,
                              size: 18,
                            ),
                            onPressed: () => controller.updateSearchQuery(''),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Role Filter Chips & Total Badge
                  Obx(() {
                    final currentRole = controller.selectedRoleFilter.value;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildRoleFilterChip(
                          context,
                          label: 'All',
                          roleKey: 'all',
                          isSelected: currentRole == 'all',
                        ),

                        const SizedBox(width: 6),
                        _buildRoleFilterChip(
                          context,
                          label: 'Admin',
                          roleKey: 'admin',
                          isSelected: currentRole == 'admin',
                        ),
                        const SizedBox(width: 6),
                        _buildRoleFilterChip(
                          context,
                          label: 'Viewer',
                          roleKey: 'viewer',
                          isSelected: currentRole == 'viewer',
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            // Users List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = controller.filteredUsers;

                if (users.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.people_copy,
                            size: 64,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Users Found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Try adjusting your search query or filter criteria.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () =>
                                controller.fetchUsers(isRefresh: true),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Refresh List'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchUsers(isRefresh: true),
                  child: ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        users.length + (controller.hasMorePages.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == users.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: controller.isMoreLoading.value
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : TextButton(
                                    onPressed: controller.loadMoreUsers,
                                    child: const Text('Load More Users'),
                                  ),
                          ),
                        );
                      }

                      final user = users[index];
                      return _buildUserCard(context, user);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.toNamed(AppRoutes.userForm);
        },
        backgroundColor: theme.colorScheme.primary,
        icon: const Icon(AppAssets.icUserAdd, color: Colors.white),
        label: const Text(
          'Add User',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRoleFilterChip(
    BuildContext context, {
    required String label,
    required String roleKey,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.filterByRole(roleKey);
        } else {
          controller.filterByRole('all');
        }
      },
      selectedColor: theme.colorScheme.primaryContainer,
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: theme.colorScheme.outline.withValues(alpha: 0.15),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildUserCard(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final initial = user.name.trim().isNotEmpty
        ? user.name.trim()[0].toUpperCase()
        : 'U';

    Color roleColor;
    switch (user.role.toLowerCase()) {
      case 'super-admin':
        roleColor = Colors.purple.shade600;
        break;
      case 'admin':
        roleColor = Colors.blue.shade600;
        break;
      default:
        roleColor = Colors.teal.shade600;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Initial Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: roleColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: roleColor.withValues(alpha: 0.4),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: user.status
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: user.status
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          user.status ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: user.status
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Role Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user.role.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: roleColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Email
                  Row(
                    children: [
                      Icon(
                        Iconsax.sms_copy,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),

                  // Mobile
                  Row(
                    children: [
                      Icon(
                        Iconsax.mobile_copy,
                        size: 14,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.mobile,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action Buttons (Edit & Delete)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Iconsax.edit_2_copy,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                  onPressed: () {
                    Get.toNamed(AppRoutes.userForm, arguments: user);
                  },
                  tooltip: 'Edit User',
                ),
                IconButton(
                  icon: Icon(
                    Iconsax.trash_copy,
                    color: Colors.red.shade600,
                    size: 18,
                  ),
                  onPressed: () {
                    controller.confirmDeleteUser(context, user);
                  },
                  tooltip: 'Delete User',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
