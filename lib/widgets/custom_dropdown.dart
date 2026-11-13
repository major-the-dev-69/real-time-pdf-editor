import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool isLoading;
  final String? Function(T?)? validator;
  final VoidCallback? onAddPressed;

  const CustomDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelText,
    this.hintText,
    this.prefixIcon,
    this.isLoading = false,
    this.validator,
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final colorScheme = theme.colorScheme;

    Widget dropdown = DropdownButtonFormField<T>(
      // ignore: deprecated_member_use
      value: value,
      isExpanded: true,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.keyboard_arrow_down_rounded),
      style: textTheme.bodyLarge?.copyWith(
        color: colorScheme.onSurface,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: theme.hintColor,
          fontSize: 14,
        ),
        filled: true,
        fillColor: colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colorScheme.primary, size: 20)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      items: items,
      validator: validator,
      onChanged: onChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: dropdown),
            if (onAddPressed != null) ...[
              const SizedBox(width: 12),
              Container(
                height: 52, // match typical height of text field
                width: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: IconButton(
                  onPressed: onAddPressed,
                  icon: Icon(Icons.add_rounded, color: colorScheme.primary),
                  tooltip: 'Add option',
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
