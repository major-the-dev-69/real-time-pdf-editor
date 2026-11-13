import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:sai_associates/core/utils/app_assets.dart';
import 'package:sai_associates/widgets/custom_buttons.dart';

import '../controller/user_form_controller.dart';

class UserFormPage extends GetView<UserFormController> {
  const UserFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.isEditMode.value ? 'Edit User' : 'Add New User',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: Get.back,
          icon: const Icon(AppAssets.backArrow),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          AppAssets.icUserAdd,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.isEditMode.value
                                    ? 'Update Account Details'
                                    : 'Create New Account',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.isEditMode.value
                                    ? 'Modify role, contact info or account status.'
                                    : 'Enter details below to register a new user.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name Input
                Text(
                  'Full Name',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller.nameController,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  decoration: _buildInputDecoration(
                    context,
                    hintText: 'Enter full name (e.g. Rahul Sharma)',
                    prefixIcon: Iconsax.user_copy,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Email Input
                Text(
                  'Email Address',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _buildInputDecoration(
                    context,
                    hintText: 'Enter email address (e.g. rahul@example.com)',
                    prefixIcon: Iconsax.sms_copy,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email address is required';
                    }
                    if (!GetUtils.isEmail(val.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Mobile Number Input
                Text(
                  'Mobile Number',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: controller.mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration(
                    context,
                    hintText: 'Enter 10-digit mobile number',
                    prefixIcon: Iconsax.mobile_copy,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Mobile number is required';
                    }
                    if (val.trim().length < 10) {
                      return 'Mobile number must be at least 10 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Password Input
                Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Password',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          if (controller.isEditMode.value) ...[
                            const SizedBox(width: 6),
                            Text(
                              '(Leave blank to keep current password)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: controller.passwordController,
                        obscureText: !controller.isPasswordVisible.value,
                        decoration: _buildInputDecoration(
                          context,
                          hintText: controller.isEditMode.value
                              ? 'Enter new password (optional)'
                              : 'Enter account password',
                          prefixIcon: Iconsax.lock_copy,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Iconsax.eye_copy
                                  : Iconsax.eye_slash_copy,
                              size: 20,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                        validator: (val) {
                          if (!controller.isEditMode.value &&
                              (val == null || val.trim().isEmpty)) {
                            return 'Password is required for new accounts';
                          }
                          if (val != null &&
                              val.isNotEmpty &&
                              val.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Role Dropdown Selection
                Text(
                  'User Role',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => DropdownButtonFormField<String>(
                    initialValue: controller.selectedRole.value,
                    items: controller.roleOptions.map((role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Row(
                          children: [
                            Icon(
                              role == 'admin'
                                  ? Iconsax.user_tick_copy
                                  : Iconsax.user_copy,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              role.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        controller.selectedRole.value = val;
                      }
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Status Toggle Switch (Edit Mode)
                Obx(() {
                  if (!controller.isEditMode.value) {
                    return const SizedBox.shrink();
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account Status',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.status.value
                                  ? 'User can log in and access the system'
                                  : 'User account is suspended',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: controller.status.value,
                          onChanged: controller.toggleStatus,
                          activeTrackColor: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 32),

                // Submit Button
                Obx(
                  () => CustomButton(
                    title: controller.isEditMode.value
                        ? 'Update User'
                        : 'Create User',
                    onPressed: controller.saveUser,
                    isLoading: controller.isLoading.value,
                    borderRadius: 16,
                    height: 54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    BuildContext context, {
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hintText,
      hintStyle: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
      ),
      prefixIcon: Icon(prefixIcon, size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
    );
  }
}
