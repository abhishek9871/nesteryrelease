import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/utils/constants.dart';

class CustomTextField extends ConsumerWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final FocusNode? focusNode;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.focusNode,
    this.onEditingComplete,
    this.onChanged,
    this.textInputAction,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          onChanged: onChanged,
          textInputAction: textInputAction,
          autofocus: autofocus,
          readOnly: readOnly,
          onTap: onTap,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: enabled
                ? theme.colorScheme.surface
                : theme.colorScheme.surfaceVariant,
          ),
        ),
      ],
    );
  }
}

class SearchTextField extends ConsumerWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback? onSearch;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool readOnly;
  final VoidCallback? onTap;

  const SearchTextField({
    super.key,
    required this.controller,
    this.hint = 'Search',
    this.onSearch,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      focusNode: focusNode,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      onEditingComplete: onSearch,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  if (onClear != null) {
                    onClear!();
                  }
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
    );
  }
}

class DatePickerField extends ConsumerWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? Function(String?)? validator;
  final ValueChanged<DateTime?>? onDateSelected;
  final bool enabled;

  const DatePickerField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.validator,
    this.onDateSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          enabled: enabled,
          validator: validator,
          onTap: enabled
              ? () async {
                  final now = DateTime.now();
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate ?? now,
                    firstDate: firstDate ?? now,
                    lastDate: lastDate ?? now.add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Constants.primaryColor,
                            onPrimary: Colors.white,
                            surface: theme.colorScheme.surface,
                            onSurface: theme.colorScheme.onSurface,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null) {
                    controller.text = '${picked.day}/${picked.month}/${picked.year}';
                    if (onDateSelected != null) {
                      onDateSelected!(picked);
                    }
                  }
                }
              : null,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.calendar_today),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: enabled
                ? theme.colorScheme.surface
                : theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}
