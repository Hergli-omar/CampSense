import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dropdown field styled consistently with [CsTextField].
class CsDropdown<T> extends StatelessWidget {
  final String? labelText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final FormFieldValidator<T>? validator;
  final Widget? prefixIcon;

  const CsDropdown({
    super.key,
    String? label,
    String? labelText,
    T? value,
    T? initialValue,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
  })  : labelText = labelText ?? label,
        value = value ?? initialValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ],
    );
  }
}
