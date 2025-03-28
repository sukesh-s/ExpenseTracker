import 'package:flutter/material.dart';

class ExpenseDropdown extends StatelessWidget {
  final String? initialValue;
  final List<Map<String, String>> items;
  final String labelText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String?>? onChanged;

  const ExpenseDropdown({
    super.key,
    this.initialValue,
    required this.items,
    required this.labelText,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
      ),
      style: const TextStyle(
        color: Colors.white, // Set selected text color here
      ),
      dropdownColor: const Color(0xff2c2c2c),
      items: items.map((Map<String, String> category) {
        return DropdownMenuItem<String>(
          value: category['key'],
          child: Text(category['value']!),
        );
      }).toList(),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
